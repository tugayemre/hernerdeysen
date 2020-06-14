import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hernerdeysen/models/address.dart';
import 'package:hernerdeysen/models/place.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hernerdeysen/constants.dart';

class NearbyPlacesSearchModel {
  Future<dynamic> searchForFiltered(Address address, String type) async {
    String url =
        '$kDefaultAddressNearBySearchURL${address.lat},${address.lng}&radius=500&type=$type&key=$kApiKey';
    print(url);
    http.Response response;

    try {
      response = await http.get(url);
    } catch (e) {
      print(e);
    }

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      return decodedData;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> searchForDefaultAddress(Address address) async {
    String url =
        '$kDefaultAddressNearBySearchURL${address.lat},${address.lng}&radius=500&key=$kApiKey';
    print(url);
    http.Response response;

    try {
      response = await http.get(url);
    } catch (e) {
      print(e);
    }

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);
      return decodedData;
    } else {
      throw Exception('Failed to load');
    }
  }

  Future<dynamic> searchForCurrentAddress(LatLng currentPosition) async {
    Set<Marker> markers = {};
    List<Place> nearbyPlaces = [];

    String url =
        '$kDefaultAddressNearBySearchURL${currentPosition.latitude},${currentPosition.longitude}&type=restaurant&radius=500&key=$kApiKey';
    http.Response response;
    print(url);
    try {
      response = await http.get(url);
    } catch (e) {
      print(e);
    }

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);

      for (Map<dynamic, dynamic> x in decodedData['results']) {
        try {
          nearbyPlaces.add(
            Place(
              name: x['name'],
              formattedAddress: x['vicinity'],
              lat: x['geometry']['location']['lat'],
              long: x['geometry']['location']['lng'],
              rating: x.containsKey('rating') ? x['rating'].toDouble() : 0.0,
            ),
          );
        } catch (e) {
          print(e);
        }
      }
      for (Place x in nearbyPlaces) {
        markers.add(
          Marker(
            markerId: MarkerId(x.lat.toString()),
            position: LatLng(x.lat, x.long),
            infoWindow: InfoWindow(title: x.name, snippet: x.rating.toString()),
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      }

      return markers;
    } else {
      throw Exception('Failed to load');
    }
  }
}
