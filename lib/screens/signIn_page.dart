import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hernerdeysen/screens/address_enrollment_page.dart';
import 'package:hernerdeysen/screens/nearby_places_list_page.dart';

class SignInPage extends StatefulWidget {
  static const String singInPageRoute = '/';
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isUserLoggedIn = false;

  void checkUserLoggedIn() async {
    FirebaseUser firebaseUser = await _auth.currentUser();

    if (firebaseUser != null) {
      Navigator.pushNamed(context, NearbyPlacesPage.nearbyPlacesPageRoute);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    checkUserLoggedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Her Nerdeysen"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(
              size: 150,
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: OutlineButton(
                onPressed: () async {
                  try {
                    var x = await signInWithGoogle();
                    Navigator.pushNamed(context,
                        AddressEnrollmentPage.addressEnrollmentPageRoute);
                  } catch (e) {
                    print(e);
                  }
                },
                borderSide: BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                splashColor: Colors.lightBlueAccent,
                highlightColor: Colors.lightBlueAccent,
                child: Row(
                  children: [
                    Image(
                      image: Image.asset(
                        'assets/google_logo.png',
                      ).image,
                      height: 55,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Sign In with Google',
                        style: TextStyle(fontSize: 25, color: Colors.grey[600]),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    final AuthResult authResult = await _auth.signInWithCredential(credential);

    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);

    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();

    assert(user.uid == currentUser.uid);

    return 'Signed In';
  }
}
