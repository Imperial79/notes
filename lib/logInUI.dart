import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:notes/sdp.dart';

import 'constants.dart';
import 'services/auth.dart';

class LoginUI extends StatefulWidget {
  const LoginUI({Key? key}) : super(key: key);

  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: !isDark ? Colors.white : Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Notes.',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        "continue with",
                        style: TextStyle(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (!isLoading) {
                          setState(() {
                            isLoading = true;
                          });
                          AuthMethods().signInWithgoogle(context);
                        }
                      },
                      child: Container(
                        // width: double.infinity,
                        alignment:
                            isLoading ? Alignment.center : Alignment.topLeft,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.blueGrey.shade800
                              : Colors.blueGrey.shade200,
                        ),
                        child: isLoading
                            ? Transform.scale(
                                scale: 0.5,
                                child: CircularProgressIndicator(
                                  color: isDark ? Colors.white : Colors.black,
                                  strokeWidth: 5,
                                ),
                              )
                            : isDark
                                ? Image.asset(
                                    'lib/assets/image/googleLogo.png',
                                    height: 40,
                                  )
                                : Text(
                                    'Google',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: sdp(context, 17),
                                      fontWeight: FontWeight.w600,
                                      height: 2,
                                    ),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
