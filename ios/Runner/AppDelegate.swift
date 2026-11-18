import CoreLocation
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, FlutterStreamHandler, CLLocationManagerDelegate {
  private var compassSink: FlutterEventSink?
  private var locationManager: CLLocationManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let compassChannel = FlutterEventChannel(
      name: "com.arkan.arkan/compass",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    compassChannel.setStreamHandler(self)
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    compassSink = events
    guard CLLocationManager.headingAvailable() else {
      events(["available": false])
      return nil
    }

    let manager = CLLocationManager()
    manager.delegate = self
    manager.headingFilter = 1
    manager.startUpdatingHeading()
    locationManager = manager
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    locationManager?.stopUpdatingHeading()
    locationManager?.delegate = nil
    locationManager = nil
    compassSink = nil
    return nil
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    guard let sink = compassSink else { return }
    if newHeading.headingAccuracy < 0 {
      return
    }
    let heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    sink([
      "available": true,
      "heading": heading,
      "accuracy": newHeading.headingAccuracy,
    ])
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    // Keep stream alive; transient heading failures shouldn't kill the compass UI.
  }
}
