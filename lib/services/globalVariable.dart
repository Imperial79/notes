import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserName {
  static String userName = '';
  static String userEmail = '';
  static String userDisplayName = '';
  static String userId = '';
  static String userProfilePic = '';
}

NavPush(context, screen) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

NavPushRepacement(context, screen) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (context) => screen));
}
