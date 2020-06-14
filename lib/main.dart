import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hernerdeysen/screens/address_enrollment_page.dart';
import 'package:hernerdeysen/screens/current_location_map_view.dart';
import 'package:hernerdeysen/screens/nearby_places_list_page.dart';
import 'package:hernerdeysen/screens/signIn_page.dart';
import 'package:hernerdeysen/screens/signIn_page.dart';
import 'package:hernerdeysen/screens/user_addresses_page.dart';
import 'package:hernerdeysen/user_data.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserData(),
      child: MaterialApp(
        title: 'Her Nerdeysen',
        initialRoute: SignInPage.singInPageRoute,
        routes: {
          SignInPage.singInPageRoute: (context) => SignInPage(),
          AddressEnrollmentPage.addressEnrollmentPageRoute: (context) =>
              AddressEnrollmentPage(),
          NearbyPlacesPage.nearbyPlacesPageRoute: (context) =>
              NearbyPlacesPage(),
          UserAddressesPage.userAddressesPageRoute: (context) =>
              UserAddressesPage(),
          CurrentLocationMapView.currentLocationMapView: (context) =>
              CurrentLocationMapView(),
        },
      ),
    );
  }
}
