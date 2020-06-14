import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hernerdeysen/models/location_geocode_model.dart';
import 'package:hernerdeysen/models/nearby_places_search_model.dart';
import 'package:hernerdeysen/models/place.dart';
import 'package:hernerdeysen/screens/nearby_places_list_page.dart';
import 'package:provider/provider.dart';

import '../user_data.dart';

class CurrentLocationMapView extends StatefulWidget {
  static const String currentLocationMapView = '/currentLocationMapView';

  @override
  _CurrentLocationMapViewState createState() => _CurrentLocationMapViewState();
}

class _CurrentLocationMapViewState extends State<CurrentLocationMapView> {
  LocationGeocodeModel locationGeocodeModel = LocationGeocodeModel();
  static LatLng atam = LatLng(39.924939, 32.836899);
  LatLng initialLatLng = atam;
  List<Place> _nearbyPlaces = [];
  // Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLatLng();
  }

  void getCurrentLatLng() async {
    await locationGeocodeModel.getCurrentPosition();
    initialLatLng =
        LatLng(locationGeocodeModel.doubleLat, locationGeocodeModel.doubleLng);
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: initialLatLng, zoom: 18.0),
      ),
    );
    NearbyPlacesSearchModel nearbyPlacesSearchModel = NearbyPlacesSearchModel();

    _markers =
        await nearbyPlacesSearchModel.searchForCurrentAddress(initialLatLng);
    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onAddMarkerButtonPressed() {
    for (Place x in _nearbyPlaces) {
      _markers.add(
        Marker(
          markerId: MarkerId(x.lat.toString()),
          position: LatLng(x.lat, x.long),
          infoWindow:
              InfoWindow(title: 'Really Cool Place', snippet: '5 starr rating'),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userDataProviderObject = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Her Nerdeysen'),
        backgroundColor: Colors.green[700],
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            //onCameraMove: _onCameraMove,
            markers: _markers,
            mapType: _currentMapType,
            myLocationEnabled: true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialLatLng,
              zoom: 100.0,
            ),
          ),
        ],
      ),
    );
  }
}
