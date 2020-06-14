import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hernerdeysen/models/address.dart';
import 'package:hernerdeysen/models/location_geocode_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData extends ChangeNotifier {
  List<String> defaultUserAddress;
  Address defaultAddress;
  LatLng currentLatLng;

  void setDefaultAddress(Address address) {
    defaultUserAddress = [
      address.title,
      address.lat,
      address.lng,
      address.neighbourhood,
      address.province,
      address.street,
      address.town
    ];
    defaultAddress = address;
    notifyListeners();
  }

  void getDefaultUserAddress() async {
    notifyListeners();
  }

  Future<void> getCurrentLatLng() async {
    LocationGeocodeModel locationGeocodeModel = LocationGeocodeModel();
    await locationGeocodeModel.getCurrentPosition();
    currentLatLng =
        LatLng(locationGeocodeModel.doubleLat, locationGeocodeModel.doubleLng);
    notifyListeners();
  }

  void changeUserDefaultAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> defaultAddressSpecList =
        preferences.getStringList('default_address');
    defaultUserAddress = defaultAddressSpecList;
    defaultAddress = Address(
        title: defaultAddressSpecList[0],
        lat: defaultAddressSpecList[1],
        lng: defaultAddressSpecList[2],
        neighbourhood: defaultAddressSpecList[3],
        province: defaultAddressSpecList[4],
        street: defaultAddressSpecList[5],
        town: defaultAddressSpecList[6]);

    notifyListeners();
  }
}
