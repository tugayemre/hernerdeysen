import 'package:geolocator/geolocator.dart';

class LocationGeocodeModel {
  Position _position;
  String _lat;
  String _lng;

  Future<void> getCurrentPosition() async {
    try {
      _position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _lat = _position.latitude.toString();
      _lng = _position.longitude.toString();
    } catch (e) {
      print(e);
      _position = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      if (_position == null) {
        _lat = 'LATLocationError';
        _lng = 'LNGLocationError';
      } else {
        _lat = _position.latitude.toString();
        _lng = _position.longitude.toString();
      }
    }
    print(_lat);
    print(_lng);
  }

  String get stringLat => _lat;
  String get stringLng => _lng;
  double get doubleLat => double.parse(_lat);
  double get doubleLng => double.parse(_lng);
}
