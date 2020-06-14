import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hernerdeysen/constants.dart';
import 'package:hernerdeysen/models/address.dart';
import 'package:hernerdeysen/models/location_geocode_model.dart';
import 'package:hernerdeysen/screens/nearby_places_list_page.dart';
import 'package:hernerdeysen/screens/signIn_page.dart';
import 'package:hernerdeysen/user_data.dart';
import 'package:hernerdeysen/widgets/address_info_text_form_field.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressEnrollmentPage extends StatefulWidget {
  static const String addressEnrollmentPageRoute = '/addressEnrollmentPage';
  @override
  _AddressEnrollmentPageState createState() => _AddressEnrollmentPageState();
}

class _AddressEnrollmentPageState extends State<AddressEnrollmentPage>
    with SingleTickerProviderStateMixin {
  final Firestore _firestore = Firestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  LatLng initialAddressLatLng;
  String provinceStoreText;
  String townStoreText;
  String neighbourhoodStoreText;
  String streetStoreText;
  String sLat;
  String sLng;
  bool userWantChangeDefaultAddress = false;

  TextEditingController provinceTextController = TextEditingController();
  TextEditingController townTextController = TextEditingController();
  TextEditingController neighbourhoodTextController = TextEditingController();
  TextEditingController streetTextController = TextEditingController();
  TextEditingController addressTitleTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AnimationController _animationController;
  Animation _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  bool userInitialAddressGotten = false;

  @override
  void initState() {
    getAddressFromLatLng();
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(end: 1, begin: 0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
  }

  void getAddressFromLatLng() async {
    LocationGeocodeModel locationGeocodeModel = LocationGeocodeModel();
    var decodedData;
    await locationGeocodeModel.getCurrentPosition();
    sLat = locationGeocodeModel.stringLat;
    sLng = locationGeocodeModel.stringLng;
    String url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${locationGeocodeModel.doubleLat},${locationGeocodeModel.doubleLng}&key=$kApiKey';
    print(url);
    try {
      http.Response response = await http.get(url);
      decodedData = jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
    try {
      provinceTextController.text =
          decodedData['results'][0]['address_components'][4]['long_name'];
      provinceStoreText = provinceTextController.text;
    } catch (e) {
      print(e);
      provinceTextController.clear();
    }
    try {
      townTextController.text =
          decodedData['results'][0]['address_components'][3]['long_name'];
      townStoreText = townTextController.text;
    } catch (e) {
      print(e);
      townTextController.clear();
    }
    try {
      neighbourhoodTextController.text =
          decodedData['results'][0]['address_components'][2]['long_name'];
      neighbourhoodStoreText = neighbourhoodTextController.text;
    } catch (e) {
      print(e);
      neighbourhoodTextController.clear();
    }
    try {
      streetTextController.text =
          decodedData['results'][0]['address_components'][1]['long_name'];
      streetStoreText = streetTextController.text;
    } catch (e) {
      print(e);
      streetTextController.clear();
    }
    setState(() {
      initialAddressLatLng = LatLng(
          locationGeocodeModel.doubleLat, locationGeocodeModel.doubleLng);
      _markers.add(Marker(
        markerId: MarkerId(initialAddressLatLng.latitude.toString()),
        position: LatLng(
            initialAddressLatLng.latitude, initialAddressLatLng.longitude),
        icon: BitmapDescriptor.defaultMarker,
      ));
      userInitialAddressGotten = true;
    });
  }

  @override
  void dispose() {
    provinceTextController.dispose();
    townTextController.dispose();
    neighbourhoodTextController.dispose();
    streetTextController.dispose();
    addressTitleTextController.dispose();
    super.dispose();
  }

  void _onCameraMove(CameraPosition position) {
    initialAddressLatLng = position.target;
    print(initialAddressLatLng);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(initialAddressLatLng.latitude.toString()),
        position: LatLng(
            initialAddressLatLng.latitude, initialAddressLatLng.longitude),
        infoWindow:
            InfoWindow(title: 'Really Cool Place', snippet: '5 starr rating'),
        icon: BitmapDescriptor.defaultMarker,
      ));
      var m = _markers.last;
      _markers = {};
      _markers.add(m);
    });
  }

  void enrollUserAddressWithUID(UserData userData) async {
    FirebaseUser user = await _auth.currentUser();
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String uid = user.uid;
    bool isFormValid = await getAddress();
    if (isFormValid == true) {
      await _firestore
          .collection(uid)
          .document(addressTitleTextController.text)
          .setData({
        'lat': sLat,
        'lng': sLng,
        'addressTitle': addressTitleTextController.text,
        'province': provinceTextController.text,
        'town': townTextController.text,
        'neighbourhood': neighbourhoodTextController.text,
        'street': streetTextController.text,
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NearbyPlacesPage()),
      );
    }

    Address address = Address(
        title: addressTitleTextController.text,
        lat: sLat,
        lng: sLng,
        neighbourhood: neighbourhoodTextController.text,
        province: provinceTextController.text,
        street: streetTextController.text,
        town: townTextController.text);

    userData.setDefaultAddress(address);

    preferences.setStringList('default_address', [
      addressTitleTextController.text,
      sLat,
      sLng,
      neighbourhoodTextController.text,
      provinceTextController.text,
      streetTextController.text,
      townTextController.text,
    ]);
  }

  Future<bool> getAddress() async {
    if (_formKey.currentState.validate()) {
      if (userWantChangeDefaultAddress == true) {
        String province =
            provinceTextController.text.toLowerCase().replaceAll(' ', '+');
        String town =
            townTextController.text.toLowerCase().replaceAll(' ', '+');
        String neighbourhood =
            neighbourhoodTextController.text.toLowerCase().replaceAll(' ', '+');
        String street =
            streetTextController.text.toLowerCase().replaceAll(' ', '+');

        String url =
            'https://maps.googleapis.com/maps/api/geocode/json?address=$street,$neighbourhood,$town,$province&key=$kApiKey';
        http.Response response;
        try {
          response = await http.get(url);
        } catch (e) {
          print(e);
        }
        if (response.statusCode == 200) {
          var decodedData = jsonDecode(response.body);
          double lat = decodedData['results'][0]['geometry']['location']['lat'];
          double lng = decodedData['results'][0]['geometry']['location']['lng'];
          sLat = lat.toString();
          sLng = lng.toString();
        } else {
          throw Exception('Failed to load');
        }
      }
      return true;
    }
    return false;
  }

  Set<Marker> _markers = {};
  @override
  Widget build(BuildContext context) {
    final UserData userDataProviderObject = Provider.of<UserData>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_animationStatus == AnimationStatus.dismissed) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        },
        child: Icon(Icons.location_on),
      ),
      appBar: AppBar(
        title: Text('Her Nerdeysen'),
      ),
      body: userInitialAddressGotten
          ? Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(pi * _animation.value),
              child: _animation.value <= 0.5
                  ? SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  InfoTextFormField(
                                    enabled: userWantChangeDefaultAddress,
                                    controller: provinceTextController,
                                    hint: 'İstanbul',
                                    label: 'İlinizi giriniz',
                                  ),
                                  InfoTextFormField(
                                    enabled: userWantChangeDefaultAddress,
                                    controller: townTextController,
                                    hint: 'Sisli',
                                    label: 'İlçe giriniz',
                                  ),
                                  InfoTextFormField(
                                    enabled: userWantChangeDefaultAddress,
                                    controller: neighbourhoodTextController,
                                    hint: 'Fulya mahallesi',
                                    label: 'Mahalle giriniz',
                                  ),
                                  InfoTextFormField(
                                    enabled: userWantChangeDefaultAddress,
                                    controller: streetTextController,
                                    hint: 'Akatlar sokak',
                                    label: 'Sokak giriniz',
                                  ),
                                  InfoTextFormField(
                                    enabled: true,
                                    controller: addressTitleTextController,
                                    hint: 'Ev Adresim',
                                    label: 'Adres Başlığı',
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: RaisedButton(
                                    onPressed: () {
                                      enrollUserAddressWithUID(
                                          userDataProviderObject);
                                    },
                                    color: Colors.blue,
                                    child: Text('Adresi kaydet'),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                                Text('Farklı adres girmek istiyorum.'),
                                CupertinoSwitch(
                                    activeColor: Colors.blueAccent,
                                    value: userWantChangeDefaultAddress,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          provinceTextController.clear();
                                          townTextController.clear();
                                          neighbourhoodTextController.clear();
                                          streetTextController.clear();
                                        } else {
                                          provinceTextController.text =
                                              provinceStoreText;
                                          townTextController.text =
                                              townStoreText;
                                          neighbourhoodTextController.text =
                                              neighbourhoodStoreText;
                                          streetTextController.text =
                                              streetStoreText;
                                        }
                                        userWantChangeDefaultAddress = value;
                                      });
                                    })
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(pi),
                            child: GoogleMap(
                              onCameraMove: _onCameraMove,
                              //mapType: _currentMapType,
                              markers: _markers,
                              myLocationEnabled: false,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: initialAddressLatLng,
                                zoom: 19.0,
                              ),
                            ),
                          ),
                        ),
                        Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(pi),
                            child: InfoTextFormField(
                              enabled: true,
                              controller: addressTitleTextController,
                              hint: 'Ev Adresim',
                              label: 'Adres Başlığı',
                            )),
                      ],
                    ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
