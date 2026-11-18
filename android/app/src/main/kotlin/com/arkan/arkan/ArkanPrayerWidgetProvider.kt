package com.arkan.arkan

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import org.json.JSONObject

/**
 * Native Android home screen AppWidget showing today's prayer schedule
 * and upcoming prayer time synced from Flutter SharedPreferences.
 */
class ArkanPrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateSingleWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val FLUTTER_PREFS = "FlutterSharedPreferences"
        private const val WIDGET_KEY = "flutter.arkan_widget_prayers_v1"

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, ArkanPrayerWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            if (ids.isEmpty()) return
            for (id in ids) {
                updateSingleWidget(context, manager, id)
            }
        }

        private fun updateSingleWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val views = RemoteViews(context.packageName, R.layout.arkan_prayer_widget)
            val prefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            val rawJson = prefs.getString(WIDGET_KEY, null)

            if (!rawJson.isNullOrBlank()) {
                try {
                    val data = JSONObject(rawJson)
                    val location = data.optString("locationName", "أركان • مواقيت الصلاة")
                    val hijri = data.optString("hijriDate", "")
                    val nextName = data.optString("nextPrayerName", "الفجر")
                    val nextTime = data.optString("nextPrayerTime", "--:--")

                    views.setTextViewText(R.id.widget_location, location)
                    views.setTextViewText(R.id.widget_hijri, hijri)
                    views.setTextViewText(R.id.widget_next_prayer, nextName)
                    views.setTextViewText(R.id.widget_next_time, nextTime)
                    views.setTextViewText(R.id.widget_fajr, data.optString("fajr", "--:--"))
                    views.setTextViewText(R.id.widget_dhuhr, data.optString("dhuhr", "--:--"))
                    views.setTextViewText(R.id.widget_asr, data.optString("asr", "--:--"))
                    views.setTextViewText(R.id.widget_maghrib, data.optString("maghrib", "--:--"))
                    views.setTextViewText(R.id.widget_isha, data.optString("isha", "--:--"))
                } catch (_: Exception) {
                    // Keep default layout placeholders if stored JSON is malformed.
                }
            }

            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getActivity(context, 0, launchIntent, pendingFlags)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
