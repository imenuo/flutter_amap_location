import Flutter
import UIKit
import AMapFoundationKit
import AMapLocationKit
import CoreLocation


public class SwiftFlutterAMapLocationPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "imenuo.com/flutter_amap_location", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAMapLocationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: "imenuo.com/flutter_amap_location_events", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
    }

    private var locationManager: AMapLocationManager? = nil
    private var sink: FlutterEventSink? = nil

    private func initLocationManager() {
        if locationManager != nil {
            return
        }

        locationManager = AMapLocationManager()
    }

    private func checkPermissions() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            let clLocationManager = CLLocationManager()
            if Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil {
                clLocationManager.requestWhenInUseAuthorization()
            } else if Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysUsageDescription") != nil {
                clLocationManager.requestAlwaysAuthorization()
            }
        }
        return CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied
    }

    private func getLocation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.locationTimeout = 3
        locationManager?.requestLocation(withReGeocode: false) { [weak self] (location: CLLocation?,
                                                                              reGeocode: AMapLocationReGeocode?, error: Error?) in
            if let error = error {
                let error = error as NSError

                result(FlutterError(code: "ERROR", message: "requestLocation failed", details: error.code))
            } else {
                let data: [String: Any?] = [
                    "errorCode": 0,
                    "longitude": location?.coordinate.longitude,
                    "latitude": location?.coordinate.latitude,
                ]
                self?.sink?(data)
            }
        }
        result(nil)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        initLocationManager()
        switch call.method {
        case "startLocation":
            if checkPermissions() {
                getLocation(call: call, result: result)
            } else {
                result(FlutterError(code: "PERMISSION_DENIED", message: "permission denied", details: nil))
            }
        case "stopLocation":
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
