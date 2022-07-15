import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homeUi.dart';
import 'database.dart';
import 'globalVariable.dart';

//creating an instance of Firebase Authentication
class AuthMethods {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentuser() async {
    return await auth.currentUser;
  }

  signInWithgoogle(context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await _googleSignIn.signIn();

    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication!.idToken,
      accessToken: googleSignInAuthentication.accessToken,
    );

    UserCredential result =
        await _firebaseAuth.signInWithCredential(credential);

    User? userDetails = result.user;

    final SharedPreferences prefs = await _prefs;

    prefs.setString('USERKEY', userDetails!.uid);
    prefs.setString(
        'USERNAMEKEY', userDetails.email!.replaceAll("@gmail.com", ""));
    prefs.setString('USERDISPLAYNAMEKEY', userDetails.displayName!);
    prefs.setString('USEREMAILKEY', userDetails.email!);
    prefs.setString('USERPROFILEKEY', userDetails.photoURL!);

    UserName.userEmail = userDetails.email!;
    UserName.userDisplayName = userDetails.displayName!;
    UserName.userName = userDetails.email!.replaceAll("@gmail.com", "");
    UserName.userId = userDetails.uid;
    UserName.userProfilePic = userDetails.photoURL!;

    Map<String, dynamic> userInfoMap = {
      "email": userDetails.email,
      "username": userDetails.email!.replaceAll("@gmail.com", ""),
      "name": userDetails.displayName,
      "imgUrl": userDetails.photoURL,
    };

    DatabaseMethods().updatelabel(['All']);

    databaseMethods
        .addUserInfoToDB(
            userDetails.email!.replaceAll("@gmail.com", ""), userInfoMap)
        .then((value) {
      PageRouteTransition.pushReplacement(context, HomeUi());
    });
  }

  signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await auth.signOut();
  }
}
