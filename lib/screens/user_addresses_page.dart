import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hernerdeysen/models/address.dart';
import 'package:hernerdeysen/screens/nearby_places_list_page.dart';
import 'package:hernerdeysen/user_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAddressesPage extends StatefulWidget {
  static const userAddressesPageRoute = '/userAddressesPageRoute';

  @override
  _UserAddressesPageState createState() => _UserAddressesPageState();
}

class _UserAddressesPageState extends State<UserAddressesPage> {
  final Firestore databaseReference = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map> addressesMapList = [];

  Future<void> getData() async {
    FirebaseUser user = await _auth.currentUser();
    print(user.uid);
    databaseReference
        .collection(user.uid)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((element) {
        setState(() {
          addressesMapList.add(element.data);
        });
      });
    });
  }

  void changeDefaultUserAddress(Map anotherAddress, UserData userData) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    Address address = Address(
        title: anotherAddress['addressTitle'],
        lat: anotherAddress['lat'],
        lng: anotherAddress['lng'],
        neighbourhood: anotherAddress['neighbourhood'],
        province: anotherAddress['province'],
        street: anotherAddress['street'],
        town: anotherAddress['town']);

    userData.setDefaultAddress(address);

    preferences.setStringList('default_address', [
      anotherAddress['addressTitle'],
      anotherAddress['lat'],
      anotherAddress['lng'],
      anotherAddress['neighbourhood'],
      anotherAddress['province'],
      anotherAddress['street'],
      anotherAddress['town']
    ]);
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserData userDataProviderObject = Provider.of<UserData>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Her Nerdeysen'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: addressesMapList.length,
          itemBuilder: (context, int index) {
            return ListTile(
              leading: Icon(Icons.home),
              title: Text(addressesMapList[index]['street']),
              subtitle: Text(addressesMapList[index]['addressTitle']),
              onTap: () {
                changeDefaultUserAddress(
                    addressesMapList[index], userDataProviderObject);
                Navigator.pushNamed(
                    context, NearbyPlacesPage.nearbyPlacesPageRoute);
              },
            );
          },
        ),
      ),
    );
  }
}
