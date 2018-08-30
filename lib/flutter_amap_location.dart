import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class FlutterAMapLocation {
  static final FlutterAMapLocation _instance = FlutterAMapLocation._internal();
  static const MethodChannel _channel =
      const MethodChannel('imenuo.com/flutter_amap_location');
  static const EventChannel _eventChannel =
      const EventChannel('imenuo.com/flutter_amap_location_events');

  final Stream<AMapLocation> onLocationChanged = _eventChannel
      .receiveBroadcastStream()
      .map((map) => AMapLocation._fromMap(map));

  FlutterAMapLocation._internal();

  factory FlutterAMapLocation() => _instance;

  static FlutterAMapLocation get() => _instance;

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<void> setExplanation(String explanation) async {
    await _channel.invokeMethod('setExplanation', explanation);
  }

  Future<bool> hasPermissions() => _channel.invokeMethod('hasPermissions');

  Future<bool> requestPermissions() =>
      _channel.invokeMethod('requestPermissions');

  Future<void> startLocation(AMapLocationClientOption option) async {
    await _channel.invokeMethod('startLocation', option._toMap());
  }

  Future<void> stopLocation() async {
    await _channel.invokeMethod('stopLocation');
  }
}

enum AMapLocationMode {
  Hight_Accuracy,
  Device_Sensors,
  Battery_Saving,
}

enum AMapLocationProtocol {
  HTTP,
  HTTPS,
}

enum AMapLocationPurpose {
  SignIn,
  Sport,
  Transport,
}

enum GeoLanguage {
  DEFAULT,
  EN,
  ZH,
}

class AMapLocationQualityReport {
  static const int GPS_STATUS_OK = 0;
  static const int GPS_STATUS_NOGPSPROVIDER = 1;
  static const int GPS_STATUS_OFF = 2;
  static const int GPS_STATUS_MODE_SAVING = 3;
  static const int GPS_STATUS_NOGPSPERMISSION = 4;

  final String adviseMessage;
  final int gpsSatellites;
  final int gpsStatus;
  final Duration netUseTime;
  final String networkType;
  final bool isWifiAble;

  AMapLocationQualityReport._internal({
    this.adviseMessage,
    this.gpsSatellites,
    this.gpsStatus,
    this.netUseTime,
    this.networkType,
    this.isWifiAble,
  });

  static AMapLocationQualityReport _fromMap(Map map) =>
      AMapLocationQualityReport._internal(
        adviseMessage: map['adviseMessage'],
        gpsSatellites: map['gpsSatellites'],
        gpsStatus: map['gpsStatus'],
        netUseTime: new Duration(milliseconds: map['netUseTime']),
        networkType: map['networkType'],
        isWifiAble: map['isWifiAble'],
      );

  @override
  String toString() {
    return 'AMapLocationQualityReport{adviseMessage: $adviseMessage, gpsSatellites: $gpsSatellites, gpsStatus: $gpsStatus, netUseTime: $netUseTime, networkType: $networkType, isWifiAble: $isWifiAble}';
  }
}

class AMapLocation {
  static const int LOCATION_SUCCESS = 0;

  static const int ERROR_CODE_INVALID_PARAMETER = 1;
  static const int ERROR_CODE_FAILURE_WIFI_INFO = 2;
  static const int ERROR_CODE_FAILURE_LOCATION_PARAMETER = 3;
  static const int ERROR_CODE_FAILURE_CONNECTION = 4;
  static const int ERROR_CODE_FAILURE_PARSER = 5;
  static const int ERROR_CODE_FAILURE_LOCATION = 6;
  static const int ERROR_CODE_FAILURE_AUTH = 7;
  static const int ERROR_CODE_UNKNOWN = 8;
  static const int ERROR_CODE_FAILURE_INIT = 9;
  static const int ERROR_CODE_SERVICE_FAIL = 10;
  static const int ERROR_CODE_FAILURE_CELL = 11;
  static const int ERROR_CODE_FAILURE_LOCATION_PERMISSION = 12;
  static const int ERROR_CODE_FAILURE_NOWIFIANDAP = 13;
  static const int ERROR_CODE_FAILURE_NOENOUGHSATELLITES = 14;
  static const int ERROR_CODE_FAILURE_SIMULATION_LOCATION = 15;
  static const int ERROR_CODE_AIRPLANEMODE_WIFIOFF = 18;
  static const int ERROR_CODE_NOCGI_WIFIOFF = 19;

  static const int LOCATION_TYPE_GPS = 1;
  static const int LOCATION_TYPE_SAME_REQ = 2;
  @deprecated
  static const int LOCATION_TYPE_FAST = 3;
  static const int LOCATION_TYPE_FIX_CACHE = 4;
  static const int LOCATION_TYPE_WIFI = 5;
  static const int LOCATION_TYPE_CELL = 6;
  static const int LOCATION_TYPE_AMAP = 7;
  static const int LOCATION_TYPE_OFFLINE = 8;
  static const int LOCATION_TYPE_LAST_LOCATION_CACHE = 9;

  static const int GPS_ACCURACY_GOOD = 1;
  static const int GPS_ACCURACY_BAD = 0;
  static const int GPS_ACCURACY_UNKNOWN = -1;

  final double accuracy;
  final String adCode;
  final String address;
  final double altitude;
  final String aoiName;
  final double bearing;
  final String buildingId;
  final String city;
  final String cityCode;
  final String country;
  final String description;
  final String district;
  final int errorCode;
  final String errorInfo;
  final String floor;
  final int gpsAccuracyStatus;
  final double latitude;
  final String locationDetail;
  final AMapLocationQualityReport locationQualityReport;
  final int locationType;
  final double longitude;
  final String poiName;
  final String provider;
  final String province;
  final int satellites;
  final double speed;
  final String street;
  final String streetNum;
  final bool isOffset;
  final bool isFixLastLocation;
  final DateTime time;

  /// use `street` property
  @deprecated
  final String road;

  AMapLocation._internal({
    this.accuracy,
    this.adCode,
    this.address,
    this.altitude,
    this.aoiName,
    this.bearing,
    this.buildingId,
    this.city,
    this.cityCode,
    this.country,
    this.description,
    this.district,
    this.errorCode,
    this.errorInfo,
    this.floor,
    this.gpsAccuracyStatus,
    this.latitude,
    this.locationDetail,
    this.locationQualityReport,
    this.locationType,
    this.longitude,
    this.poiName,
    this.provider,
    this.province,
    this.satellites,
    this.speed,
    this.street,
    this.streetNum,
    this.road,
    this.isOffset,
    this.isFixLastLocation,
    this.time,
  });

  static AMapLocation _fromMap(Map map) => AMapLocation._internal(
        accuracy: map['accuracy'],
        adCode: map['adCode'],
        address: map['address'],
        altitude: map['altitude'],
        aoiName: map['aoiName'],
        bearing: map['bearing'],
        buildingId: map['buildingId'],
        city: map['city'],
        cityCode: map['cityCode'],
        country: map['country'],
        description: map['description'],
        district: map['district'],
        errorCode: map['errorCode'],
        errorInfo: map['errorInfo'],
        floor: map['floor'],
        gpsAccuracyStatus: map['gpsAccuracyStatus'],
        latitude: map['latitude'],
        locationDetail: map['locationDetail'],
        locationQualityReport: map['locationQualityReport'] != null
            ? AMapLocationQualityReport._fromMap(map['locationQualityReport'])
            : null,
        locationType: map['locationType'],
        longitude: map['longitude'],
        poiName: map['poiName'],
        provider: map['provider'],
        province: map['province'],
        satellites: map['satellites'],
        speed: map['speed'],
        street: map['street'],
        streetNum: map['streetNum'],
        road: map['road'],
        isOffset: map['isOffset'],
        isFixLastLocation: map['isFixLastLocation'],
        time: map['time'] != null
            ? new DateTime.fromMillisecondsSinceEpoch(map['time'])
            : null,
      );

  @override
  String toString() {
    return 'AMapLocation{accuracy: $accuracy, adCode: $adCode, address: $address, altitude: $altitude, aoiName: $aoiName, bearing: $bearing, buildingId: $buildingId, city: $city, cityCode: $cityCode, country: $country, description: $description, district: $district, errorCode: $errorCode, errorInfo: $errorInfo, floor: $floor, gpsAccuracyStatus: $gpsAccuracyStatus, latitude: $latitude, locationDetail: $locationDetail, locationQualityReport: $locationQualityReport, locationType: $locationType, longitude: $longitude, poiName: $poiName, provider: $provider, province: $province, satellites: $satellites, speed: $speed, street: $street, streetNum: $streetNum, isOffset: $isOffset, isFixLastLocation: $isFixLastLocation, time: $time, road: $road}';
  }

  String toStr([int level = 1]) {
    return jsonEncode(toJson(level));
  }

  Map toJson([int level = 1]) {
    final obj = {
      'provider': provider,
      'lon': longitude,
      'lat': latitude,
      'accuracy': accuracy,
      'isOffset': isOffset,
      'isFixLastLocation': isFixLastLocation,
    };

    if (level <= 2) {
      obj.addAll({
        'time': time.millisecondsSinceEpoch,
      });
    }

    if (level <= 1) {
      obj.addAll({
        'altitude': altitude,
        'speed': speed,
        'bearing': bearing,
        'citycode': cityCode,
        'adcode': adCode,
        'country': country,
        'province': province,
        'city': city,
        'district': district,
        'road': road,
        'street': street,
        'number': streetNum,
        'poiname': poiName,
        'errorCode': errorCode,
        'errorInfo': errorInfo,
        'locationType': locationType,
        'locationDetail': locationDetail,
        'aoiname': aoiName,
        'address': address,
        'poiid': buildingId,
        'floor': floor,
        'description': description,
      });
    }

    return obj;
  }
}

abstract class AMapLocationListener {
  void onLocationChanged(AMapLocation location);
}

class AMapLocationClientOption {
  AMapLocationMode locationMode;
  bool isLocationCacheEnable;
  Duration interval;
  bool isOnceLocation;
  bool isOnceLocationLatest;
  bool isNeedAddress;
  bool isMockEnable;
  @deprecated
  bool isWifiActiveScan;
  bool isWifiScan;
  Duration httpTimeOut;
  AMapLocationProtocol locationProtocol;
  AMapLocationPurpose locationPurpose;
  GeoLanguage geoLanguage;
  bool isGpsFirst;
  bool isKillProcess;

  @override
  String toString() {
    return 'AMapLocationClientOption{locationMode: $locationMode, isLocationCacheEnable: $isLocationCacheEnable, interval: $interval, isOnceLocation: $isOnceLocation, isOnceLocationLatest: $isOnceLocationLatest, isNeedAddress: $isNeedAddress, isMockEnable: $isMockEnable, isWifiActiveScan: $isWifiActiveScan, isWifiScan: $isWifiScan, httpTimeOut: $httpTimeOut, locationProtocol: $locationProtocol, locationPurpose: $locationPurpose, geoLanguage: $geoLanguage, isGpsFirst: $isGpsFirst, isKillProcess: $isKillProcess}';
  }

  Map _toMap() => {
        'locationMode': locationMode?.index,
        'isLocationCacheEnable': isLocationCacheEnable,
        'interval': interval?.inMilliseconds,
        'isOnceLocation': isOnceLocation,
        'isOnceLocationLatest': isOnceLocationLatest,
        'isNeedAddress': isNeedAddress,
        'isMockEnable': isMockEnable,
        'isWifiActiveScan': isWifiActiveScan,
        'isWifiScan': isWifiScan,
        'httpTimeOut': httpTimeOut?.inMilliseconds,
        'locationProtocol': locationProtocol?.index,
        'locationPurpose': locationPurpose?.index,
        'geoLanguage': geoLanguage?.index,
        'isGpsFirst': isGpsFirst,
        'isKillProcess': isKillProcess,
      };
}
