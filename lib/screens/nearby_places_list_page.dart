import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hernerdeysen/models/address.dart';
import 'package:hernerdeysen/models/nearby_places_search_model.dart';
import 'package:hernerdeysen/models/place.dart';
import 'package:hernerdeysen/screens/address_enrollment_page.dart';
import 'package:hernerdeysen/screens/current_location_map_view.dart';
import 'package:hernerdeysen/screens/signIn_page.dart';
import 'package:hernerdeysen/screens/user_addresses_page.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../user_data.dart';

class NearbyPlacesPage extends StatefulWidget {
  static const String nearbyPlacesPageRoute = '/nearbyPlacesRoute';
  @override
  _NearbyPlacesPageState createState() => _NearbyPlacesPageState();
}

class _NearbyPlacesPageState extends State<NearbyPlacesPage> {
  GoogleMapController mapController;
  String type;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  NearbyPlacesSearchModel nearbyPlacesSearchModel = NearbyPlacesSearchModel();
  Address address;
  List<Place> _nearbyPlaces = [];
  Set<Marker> _markers = {};

  @override
  void initState() {
    getDefaultAddress().then((value) {
      setState(() {});
    });
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    await _auth.signOut();
    print("User Sign Out");
    Navigator.pushNamed(context, SignInPage.singInPageRoute);
  }

  void choiceAction(String choice) {
    if (choice == OverFlowMenuItems.credits) {
      print('Credits Page open');
    } else if (choice == OverFlowMenuItems.settings) {
      print('Settings page open');
    } else if (choice == OverFlowMenuItems.addNewAddress) {
      Navigator.pushNamed(
          context, AddressEnrollmentPage.addressEnrollmentPageRoute);
    } else if (choice == OverFlowMenuItems.signOut) {
      print('Sign Out!');
      signOutGoogle();
    }
  }

  Future<void> getFilteredNearbyPlaces(String type) async {
    _nearbyPlaces = [];
    var decodedData;
    try {
      decodedData =
          await nearbyPlacesSearchModel.searchForFiltered(address, type);
    } catch (e) {
      print(e);
    }
    if (decodedData['status'] == 'OVER_QUERY_LIMIT') {
      print(decodedData['status']);
      print('limit bitti');
    } else {
      for (Map<dynamic, dynamic> x in decodedData['results']) {
        try {
          _nearbyPlaces.add(
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
    }
    setState(() {});
  }

  Future<void> getDefaultAddressNearByPlaces() async {
    nearbyPlacesSearchModel = NearbyPlacesSearchModel();
    var decodedData;
    try {
      decodedData =
          await nearbyPlacesSearchModel.searchForDefaultAddress(address);
    } catch (e) {
      print(e);
    }
    if (decodedData['status'] == 'OVER_QUERY_LIMIT') {
      print(decodedData['status']);
      print('limit bitti');
    } else {
      for (Map<dynamic, dynamic> x in decodedData['results']) {
        try {
          _nearbyPlaces.add(
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
    }
    _nearbyPlaces.removeAt(0);
    _nearbyPlaces.removeLast();
    setState(() {});
  }

  Future<void> getDefaultAddress() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> defaultAddressSpecList =
        preferences.getStringList('default_address');
    print('it called');
    address = Address(
        title: defaultAddressSpecList[0],
        lat: defaultAddressSpecList[1],
        lng: defaultAddressSpecList[2],
        neighbourhood: defaultAddressSpecList[3],
        province: defaultAddressSpecList[4],
        street: defaultAddressSpecList[5],
        town: defaultAddressSpecList[6]);
    await getDefaultAddressNearByPlaces();
  }

  Color getRatingColor(double rating) {
    if (rating >= 4.0) {
      return Colors.deepOrange;
    } else if (rating >= 3.0) {
      return Colors.orange;
    } else {
      return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataProviderObject = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Her nerdeysen'),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: choiceAction,
            itemBuilder: (context) {
              return OverFlowMenuItems.kOverFlowMenuItems.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "cevremdeNeVar",
        tooltip: 'Cevremde ne var',
        child: Icon(Icons.location_searching),
        onPressed: () async {
          await Navigator.pushNamed(
              context, CurrentLocationMapView.currentLocationMapView);
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(border: Border.all()),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: (address == null)
                        ? CircularProgressIndicator()
                        : ListTile(
                            onTap: () {
                              Navigator.pushNamed(context,
                                  UserAddressesPage.userAddressesPageRoute);
                            },
                            leading: Icon(
                              Icons.home,
                              size: 30,
                              color: Colors.black,
                            ),
                            title: Text(
                              '(${address.neighbourhood ?? 'de'} - ${address.street ?? 'de'})',
                              style: TextStyle(color: Colors.teal),
                            ),
                            trailing: Icon(
                              CupertinoIcons.location_solid,
                              size: 25,
                            ),
                          ),
                  ),
                  Expanded(
                    flex: 1,
                    child: MaterialButton(
                      onPressed: () {
                        Alert(
                          closeFunction: () {
                            print('closed');
                          },
                          context: context,
                          title: "What are you looking for ? ",
                          content: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(20)),
                            child: CupertinoPicker.builder(
                                childCount: kPlaceTypeList.length,
                                itemExtent: 30,
                                onSelectedItemChanged: (index) {
                                  type = kPlaceTypeList[index];
                                  print(type);
                                },
                                itemBuilder: (context, index) {
                                  return Text(kPlaceTypeList[index]);
                                }),
                          ),
                          buttons: [
                            DialogButton(
                              child: Text(
                                "Filtrele",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              onPressed: () {
                                getFilteredNearbyPlaces(type);
                                Navigator.pop(context);
                              },
                              color: Colors.deepOrange,
                            ),
                          ],
                        ).show();
                      },
                      color: Colors.orange,
                      child: Icon(Icons.filter_list),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Container(
                    decoration: BoxDecoration(border: Border.all()),
                    child: ListTile(
                      onTap: () {
                        _markers = {};
                        _markers.add(Marker(
                          markerId:
                              MarkerId(_nearbyPlaces[index].lat.toString()),
                          position: LatLng(_nearbyPlaces[index].lat,
                              _nearbyPlaces[index].long),
                          infoWindow: InfoWindow(
                              title: _nearbyPlaces[index].name,
                              snippet: _nearbyPlaces[index].rating.toString()),
                          icon: BitmapDescriptor.defaultMarker,
                        ));
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) =>
                              SingleChildScrollView(
                            child: Container(
                              height: 500,
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: GoogleMap(
                                //onCameraMove: _onCameraMove,
                                markers: _markers,
                                //mapType: _currentMapType,
                                myLocationEnabled: true,
                                onMapCreated: _onMapCreated,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(_nearbyPlaces[index].lat,
                                      _nearbyPlaces[index].long),
                                  zoom: 19.0,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      leading: Container(
                        decoration: BoxDecoration(
                          color: getRatingColor(_nearbyPlaces[index].rating),
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              _nearbyPlaces[index].rating.toString() ?? 'N/A'),
                        ),
                      ),
                      title: Text(_nearbyPlaces[index].name),
                      trailing:
                          Text(_nearbyPlaces[index].rating.toString() ?? 'N/A'),
                    ),
                  ),
                );
              },
              itemCount: _nearbyPlaces.length,
            ),
          ),
        ],
      ),
    );
  }
}
