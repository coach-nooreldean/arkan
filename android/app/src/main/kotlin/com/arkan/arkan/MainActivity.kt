package com.arkan.arkan

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.os.SystemClock
import android.view.Surface
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val COMPASS_CHANNEL = "com.arkan.arkan/compass"
        private const val WIDGET_CHANNEL = "com.arkan.arkan/widget"
        private const val COMPASS_UPDATE_INTERVAL_MS = 32L
        private const val SENSOR_FILTER_ALPHA = 0.25f
    }

    private var compassStreamHandler: CompassStreamHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val handler = CompassStreamHandler(sensorManager)
        compassStreamHandler = handler
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, COMPASS_CHANNEL)
            .setStreamHandler(handler)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "updatePrayerWidget") {
                    ArkanPrayerWidgetProvider.updateAllWidgets(this)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        compassStreamHandler?.stopListening()
        compassStreamHandler = null
        super.onDestroy()
    }

    private inner class CompassStreamHandler(
        private val sensorManager: SensorManager,
    ) : EventChannel.StreamHandler, SensorEventListener {

        private var eventSink: EventChannel.EventSink? = null
        private val rotationVectorSensor: Sensor? =
            sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR)
        private val accelerometerSensor: Sensor? =
            sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        private val magneticFieldSensor: Sensor? =
            sensorManager.getDefaultSensor(Sensor.TYPE_MAGNETIC_FIELD)

        private val rotationMatrix = FloatArray(9)
        private val remappedRotationMatrix = FloatArray(9)
        private val orientationAngles = FloatArray(3)
        private val gravity = FloatArray(3)
        private val geomagnetic = FloatArray(3)

        private var hasGravity = false
        private var hasGeomagnetic = false
        private var lastAccuracy = SensorManager.SENSOR_STATUS_ACCURACY_MEDIUM
        private var lastEmitTimeMs = 0L

        override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
            eventSink = events
            hasGravity = false
            hasGeomagnetic = false
            lastEmitTimeMs = 0L

            if (rotationVectorSensor != null) {
                sensorManager.registerListener(
                    this,
                    rotationVectorSensor,
                    SensorManager.SENSOR_DELAY_UI,
                )
            } else if (accelerometerSensor != null && magneticFieldSensor != null) {
                sensorManager.registerListener(
                    this,
                    accelerometerSensor,
                    SensorManager.SENSOR_DELAY_UI,
                )
                sensorManager.registerListener(
                    this,
                    magneticFieldSensor,
                    SensorManager.SENSOR_DELAY_UI,
                )
            } else {
                events?.success(mapOf("available" to false))
            }
        }

        override fun onCancel(arguments: Any?) {
            stopListening()
        }

        fun stopListening() {
            sensorManager.unregisterListener(this)
            eventSink = null
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            if (sensor?.type == Sensor.TYPE_ROTATION_VECTOR ||
                sensor?.type == Sensor.TYPE_MAGNETIC_FIELD
            ) {
                lastAccuracy = accuracy
            }
        }

        override fun onSensorChanged(event: SensorEvent?) {
            val sink = eventSink ?: return
            if (event == null) return

            var ready = false
            when (event.sensor.type) {
                Sensor.TYPE_ROTATION_VECTOR -> {
                    val values = if (event.values.size > 4) {
                        event.values.copyOf(4)
                    } else {
                        event.values
                    }
                    SensorManager.getRotationMatrixFromVector(rotationMatrix, values)
                    ready = true
                }

                Sensor.TYPE_ACCELEROMETER -> {
                    for (i in 0..2) {
                        gravity[i] = if (hasGravity) {
                            gravity[i] + SENSOR_FILTER_ALPHA * (event.values[i] - gravity[i])
                        } else {
                            event.values[i]
                        }
                    }
                    hasGravity = true
                    if (hasGeomagnetic) {
                        ready = SensorManager.getRotationMatrix(
                            rotationMatrix,
                            null,
                            gravity,
                            geomagnetic,
                        )
                    }
                }

                Sensor.TYPE_MAGNETIC_FIELD -> {
                    for (i in 0..2) {
                        geomagnetic[i] = if (hasGeomagnetic) {
                            geomagnetic[i] + SENSOR_FILTER_ALPHA * (event.values[i] - geomagnetic[i])
                        } else {
                            event.values[i]
                        }
                    }
                    hasGeomagnetic = true
                    if (hasGravity) {
                        ready = SensorManager.getRotationMatrix(
                            rotationMatrix,
                            null,
                            gravity,
                            geomagnetic,
                        )
                    }
                }
            }

            if (!ready) return

            val nowMs = SystemClock.elapsedRealtime()
            if (nowMs - lastEmitTimeMs < COMPASS_UPDATE_INTERVAL_MS) return
            lastEmitTimeMs = nowMs

            val displayRotation = getCurrentDisplayRotation()
            val remapped = when (displayRotation) {
                Surface.ROTATION_90 -> SensorManager.remapCoordinateSystem(
                    rotationMatrix,
                    SensorManager.AXIS_Y,
                    SensorManager.AXIS_MINUS_X,
                    remappedRotationMatrix,
                )
                Surface.ROTATION_180 -> SensorManager.remapCoordinateSystem(
                    rotationMatrix,
                    SensorManager.AXIS_MINUS_X,
                    SensorManager.AXIS_MINUS_Y,
                    remappedRotationMatrix,
                )
                Surface.ROTATION_270 -> SensorManager.remapCoordinateSystem(
                    rotationMatrix,
                    SensorManager.AXIS_MINUS_Y,
                    SensorManager.AXIS_X,
                    remappedRotationMatrix,
                )
                else -> {
                    System.arraycopy(rotationMatrix, 0, remappedRotationMatrix, 0, 9)
                    true
                }
            }

            val matrixToUse = if (remapped) remappedRotationMatrix else rotationMatrix
            SensorManager.getOrientation(matrixToUse, orientationAngles)
            val azimuthDeg = (Math.toDegrees(orientationAngles[0].toDouble()) + 360.0) % 360.0

            sink.success(
                mapOf(
                    "available" to true,
                    "heading" to azimuthDeg,
                    "accuracy" to lastAccuracy.toDouble(),
                ),
            )
        }

        private fun getCurrentDisplayRotation(): Int {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                this@MainActivity.display?.rotation ?: Surface.ROTATION_0
            } else {
                @Suppress("DEPRECATION")
                this@MainActivity.windowManager.defaultDisplay.rotation
            }
        }
    }
}
