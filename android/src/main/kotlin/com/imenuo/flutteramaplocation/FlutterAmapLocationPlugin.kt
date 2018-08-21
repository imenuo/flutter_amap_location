package com.imenuo.flutteramaplocation

import android.Manifest
import android.app.AlertDialog
import android.content.pm.PackageManager
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import com.amap.api.location.AMapLocation
import com.amap.api.location.AMapLocationClient
import com.amap.api.location.AMapLocationClientOption
import com.amap.api.location.AMapLocationQualityReport
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar


private fun AMapLocationQualityReport.toFlutterMap(): MutableMap<String, Any?> {
    return mutableMapOf(
            "adviseMessage" to adviseMessage,
            "gpsSatellites" to gpsSatellites,
            "gpsStatus" to gpsStatus,
            "netUseTime" to netUseTime,
            "networkType" to networkType,
            "isWifiAble" to isWifiAble
    );
}


private fun AMapLocation.toFlutterMap(): MutableMap<String, Any?> {
    return mutableMapOf(
            "accuracy" to accuracy,
            "adCode" to adCode,
            "address" to address,
            "altitude" to altitude,
            "aoiName" to aoiName,
            "bearing" to bearing,
            "buildingId" to buildingId,
            "city" to city,
            "cityCode" to cityCode,
            "country" to country,
            "description" to description,
            "district" to district,
            "errorCode" to errorCode,
            "errorInfo" to errorInfo,
            "floor" to floor,
            "gpsAccuracyStatus" to gpsAccuracyStatus,
            "latitude" to latitude,
            "locationDetail" to locationDetail,
            "locationQualityReport" to locationQualityReport.toFlutterMap(),
            "locationType" to locationType,
            "longitude" to longitude,
            "poiName" to poiName,
            "provider" to provider,
            "province" to province,
            "satellites" to satellites,
            "speed" to speed,
            "street" to street,
            "streetNum" to streetNum,
            "road" to road,
            "isOffset" to isOffset,
            "isFixLastLocation" to isFixLastLocation,
            "time" to time
    )
}

fun parseAMapLocationClientOption(map: MutableMap<*, *>): AMapLocationClientOption {
    val option = AMapLocationClientOption()

    if (map["locationMode"] != null) {
        option.locationMode = when (map["locationMode"] as Int) {
            0 -> AMapLocationClientOption.AMapLocationMode.Hight_Accuracy
            1 -> AMapLocationClientOption.AMapLocationMode.Device_Sensors
            2 -> AMapLocationClientOption.AMapLocationMode.Battery_Saving
            else -> throw IllegalArgumentException()
        }
    }
    if (map["isLocationCacheEnable"] != null) {
        option.isLocationCacheEnable = map["isLocationCacheEnable"] as Boolean
    }
    if (map["interval"] != null) {
        val interval = map["interval"]
        if (interval is Long)
            option.interval = interval
        else
            option.interval = (interval as Int).toLong()
    }
    if (map["isOnceLocation"] != null) {
        option.isOnceLocation = map["isOnceLocation"] as Boolean
    }
    if (map["isOnceLocationLatest"] != null) {
        option.isOnceLocationLatest = map["isOnceLocationLatest"] as Boolean
    }
    if (map["isNeedAddress"] != null) {
        option.isNeedAddress = map["isNeedAddress"] as Boolean
    }
    if (map["isMockEnable"] != null) {
        option.isMockEnable = map["isMockEnable"] as Boolean
    }
    if (map["isWifiActiveScan"] != null) {
        option.isWifiActiveScan = map["isWifiActiveScan"] as Boolean
    }
    if (map["isWifiScan"] != null) {
        option.isWifiScan = map["isWifiScan"] as Boolean
    }
    if (map["httpTimeOut"] != null) {
        val httpTimeOut = map["httpTimeOut"]
        if (httpTimeOut is Long)
            option.httpTimeOut = httpTimeOut
        else
            option.httpTimeOut = (httpTimeOut as Int).toLong()
    }
    if (map["locationProtocol"] != null) {
        AMapLocationClientOption.setLocationProtocol(when (map["locationProtocol"]) {
            0 -> AMapLocationClientOption.AMapLocationProtocol.HTTP
            1 -> AMapLocationClientOption.AMapLocationProtocol.HTTPS
            else -> throw IllegalArgumentException()
        })
    }
    if (map["locationPurpose"] != null) {
        option.locationPurpose = when (map["locationPurpose"]) {
            0 -> AMapLocationClientOption.AMapLocationPurpose.SignIn
            1 -> AMapLocationClientOption.AMapLocationPurpose.Sport
            2 -> AMapLocationClientOption.AMapLocationPurpose.Transport
            else -> throw IllegalArgumentException()
        }
    }
    if (map["geoLanguage"] != null) {
        option.geoLanguage = when (map["geoLanguage"]) {
            0 -> AMapLocationClientOption.GeoLanguage.DEFAULT
            1 -> AMapLocationClientOption.GeoLanguage.EN
            2 -> AMapLocationClientOption.GeoLanguage.ZH
            else -> throw IllegalArgumentException()
        }
    }
    if (map["isGpsFirst"] != null) {
        option.isGpsFirst = map["isGpsFirst"] as Boolean
    }
    if (map["isKillProcess"] != null) {
        option.isKillProcess = map["isKillProcess"] as Boolean
    }

    return option
}


class FlutterAmapLocationPlugin(
        registrar: Registrar
) : MethodCallHandler, EventChannel.StreamHandler, PluginRegistry.RequestPermissionsResultListener {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            FlutterAmapLocationPlugin(registrar)
        }

        var requestCode = 9999
    }

    private val permissions: Array<String> by lazy {
        val allPermissions = setOf(
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                Manifest.permission.READ_EXTERNAL_STORAGE,
                Manifest.permission.READ_PHONE_STATE)
        activity.packageManager
                .getPackageInfo(activity.packageName, PackageManager.GET_PERMISSIONS)
                .requestedPermissions
                .filter { allPermissions.contains(it) }
                .toTypedArray()
    }
    private val locationClient = AMapLocationClient(registrar.activity())
    private val eventChannel: EventChannel = EventChannel(registrar.messenger(),
            "imenuo.com/flutter_amap_location_events")
    private val channel = MethodChannel(registrar.messenger(),
            "imenuo.com/flutter_amap_location")
    private val activity = registrar.activity()
    private var sink: EventChannel.EventSink? = null
    private var pendingAction: ((Boolean) -> Unit)? = null
    private var explanation: String? = null

    init {
        channel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        registrar.addViewDestroyListener {
            onDestroy()
            return@addViewDestroyListener true
        }
        registrar.addRequestPermissionsResultListener(this)
    }

    private fun onDestroy() {
        locationClient.stopLocation()
        eventChannel.setStreamHandler(null)
        channel.setMethodCallHandler(null)
        sink = null
        pendingAction = null
        locationClient.onDestroy()
    }

    private fun checkSelfPermissions(): Boolean {
        return permissions.all {
            ContextCompat.checkSelfPermission(activity, it) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun shouldShowRequestPermissionsRationale(): Boolean {
        return explanation != null && permissions.any {
            ActivityCompat.shouldShowRequestPermissionRationale(activity, it)
        }
    }

    private fun showPermissionsRationale() {
        AlertDialog.Builder(activity)
                .setCancelable(false)
                .setMessage(explanation)
                .setPositiveButton(android.R.string.yes) { _, _ -> requestPermissions() }
                .setNegativeButton(android.R.string.no) { _, _ -> onRequestDenied() }
                .create()
                .show()
    }

    private fun requestPermissions() {
        ActivityCompat.requestPermissions(activity, permissions, requestCode)
    }

    private fun onRequestDenied() {
        if (shouldShowRequestPermissionsRationale()) {
            showPermissionsRationale()
        } else {
            pendingAction?.invoke(false)
            pendingAction = null
        }
    }

    private fun onRequestGranted() {
        pendingAction?.invoke(true)
        pendingAction = null
    }

    override fun onRequestPermissionsResult(
            requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        if (requestCode != FlutterAmapLocationPlugin.requestCode) return false
        if (grantResults.size == permissions.size) {
            val granted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
            if (granted) {
                onRequestGranted()
            } else {
                onRequestDenied()
            }
        } else {
            onRequestDenied()
        }
        return true
    }

    override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
        this.sink = sink
    }

    override fun onCancel(arguments: Any?) {
        this.sink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments
        when (call.method) {
            "setExplanation" -> {
                explanation = arguments as String?
                result.success(null)
            }
            "hasPermissions" -> {
                result.success(checkSelfPermissions())
            }
            "requestPermissions" -> {
                if (checkSelfPermissions()) {
                    result.success(true)
                } else {
                    pendingAction = {
                        result.success(it)
                    }
                    requestPermissions()
                }
            }
            "startLocation" -> {
                if (checkSelfPermissions()) {
                    startLocation(arguments)
                    result.success(null)
                } else {
                    pendingAction = {
                        if (it) {
                            startLocation(arguments)
                            result.success(null)
                        } else {
                            result.error("ERROR", "permissions denied", null)
                        }
                    }
                    requestPermissions()
                }
            }
            "stopLocation" -> {
                locationClient.stopLocation()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startLocation(arguments: Any) {
        locationClient.stopLocation()
        if (arguments !is MutableMap<*, *>) throw IllegalArgumentException()
        locationClient.setLocationOption(parseAMapLocationClientOption(arguments))
        locationClient.setLocationListener {
            sink?.success(it.toFlutterMap())
        }
        locationClient.startLocation()
    }
}
