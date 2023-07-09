import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class Location {
  static final Location _singleton = new Location._internal();

  factory Location() {
    return _singleton;
  }

  Location._internal();

  StreamSubscription<Position>? _positionStreamSubscription;
  double _traveledDistance = 0.0;
  double _relativeAltitudeGain = 0.0;
  double _relativeAltitudeLoss = 0.0;
  double? _lastLatitude;
  double? _lastLongitude;
  double? _lastAltitude;

  late int accuracyFilter;
  late int distanceFilter;

  List<double> _lastAltitudes = [];

  StreamController<PositionEvent>? _accuracyStreamController;
  StreamController<DistanceEvent>? _traveledDistanceStreamController;

  void setAccuracyFilter(int accuracy) {
    accuracyFilter = accuracy;
  }

  void setDistanceFilter(int distance) {
    distanceFilter = distance;
  }

  void _initiatePositionStream() {
    _handlePermission();
    LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.best, distanceFilter: distanceFilter);
    final Stream<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings);
    _positionStreamSubscription = positionStream.listen((Position position) {
      print("Position Stream ${position.latitude} ${position.longitude}");
      if (_accuracyStreamController != null &&
          _accuracyStreamController!.hasListener) {
        _accuracyStreamController!.sink.add(PositionEvent(position.accuracy,
            position.latitude, position.longitude, position.altitude));
      } else if (_accuracyStreamController != null) {
        _accuracyStreamController!.close();
        _accuracyStreamController = null;
      }

      if (_traveledDistanceStreamController != null &&
          _traveledDistanceStreamController!.hasListener) {
        if (position.accuracy <= accuracyFilter) {
          _updateRelativeAltitudes(position.altitude);
          _updateTraveledDistance(position.latitude, position.longitude);
        }
      } else if (_traveledDistanceStreamController != null) {
        _traveledDistanceStreamController!.close();
        _traveledDistanceStreamController = null;
        _traveledDistance = 0.0;
        _relativeAltitudeGain = 0.0;
        _relativeAltitudeLoss = 0.0;
        _lastLatitude = null;
        _lastLongitude = null;
        _lastAltitude = null;
        _lastAltitudes.clear();
      }

      if (_accuracyStreamController == null &&
          _traveledDistanceStreamController == null) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }

      if (position.accuracy <= accuracyFilter ||
          _traveledDistanceStreamController == null) {
        _lastLatitude = position.latitude;
        _lastLongitude = position.longitude;
      }
    });
  }

  _handlePermission() async {
    await Permission.activityRecognition.request().isGranted;

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  cancelPositionStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  _updateTraveledDistance(currentLatitude, currentLongitude) async {
    if (_lastLatitude == null || _lastLongitude == null) {
      return;
    }

    _traveledDistance += Geolocator.distanceBetween(
        _lastLatitude!, _lastLongitude!, currentLatitude, currentLongitude);
    _traveledDistanceStreamController?.sink.add(DistanceEvent(
        _traveledDistance, _relativeAltitudeGain, _relativeAltitudeLoss));
  }

  _updateRelativeAltitudes(currentAltitude) {
    final int _smoothingThreshold = 5;

    _lastAltitudes.add(currentAltitude);

    if (_lastAltitudes.length == _smoothingThreshold) {
      double _sumAltitudes = 0.0;
      double _sumDiffAltitudes = 0.0;
      for (var i = 0; i < _smoothingThreshold - 1; i++) {
        _sumAltitudes += _lastAltitudes[i];
        _sumDiffAltitudes += (_lastAltitudes[i + 1] - _lastAltitudes[i]).abs();
      }
      _sumAltitudes += _lastAltitudes[_smoothingThreshold - 1];
      _lastAltitudes.removeAt(0);
      if (_sumDiffAltitudes >= 1) {
        return;
      }
      currentAltitude = _sumAltitudes / _smoothingThreshold;
      if (_lastAltitude == null) {
        _lastAltitude = currentAltitude;
      }
    }

    if (_lastAltitude == null) {
      return;
    }

    double _relativeAltitude = currentAltitude - _lastAltitude;
    if (_relativeAltitude >= 0.1) {
      _relativeAltitudeGain += _relativeAltitude;
    } else if (_relativeAltitude <= -0.1) {
      _relativeAltitudeLoss += _relativeAltitude;
    }

    _lastAltitude = currentAltitude;
  }

  Stream<PositionEvent> getAccuracyStream() {
    if (_positionStreamSubscription == null) {
      _initiatePositionStream();
    }

    if (_accuracyStreamController == null) {
      _accuracyStreamController = StreamController.broadcast();
    }

    return _accuracyStreamController!.stream;
  }

  Stream<DistanceEvent> getTraveledDistanceStream() {
    if (_positionStreamSubscription == null) {
      _initiatePositionStream();
    }

    if (_traveledDistanceStreamController == null) {
      _traveledDistanceStreamController = StreamController.broadcast();
    }

    return _traveledDistanceStreamController!.stream;
  }
}

class PositionEvent {
  final double accuracy;
  final double latitude;
  final double longitude;
  final double altitude;

  PositionEvent(this.accuracy, this.latitude, this.longitude, this.altitude);
}

class DistanceEvent {
  final double traveledDistance;
  final double relativeAltitudeGain;
  final double relativeAltitudeLoss;

  DistanceEvent(this.traveledDistance, this.relativeAltitudeGain,
      this.relativeAltitudeLoss);
}
