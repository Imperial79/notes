import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import 'services/auth.dart';

class SignInUi extends StatefulWidget {
  const SignInUi({Key? key}) : super(key: key);

  @override
  _SignInUiState createState() => _SignInUiState();
}

class _SignInUiState extends State<SignInUi> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: isLoading == true
          ? Center(
              child: AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Redirecting',
                    cursor: '_',
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
                totalRepeatCount: 100,
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
              ),
            )
          : SafeArea(
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
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 30,
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      height: 100,
                      // color: Colors.yellow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text(
                              "continue with",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                              });
                              AuthMethods().signInWithgoogle(context);
                            },
                            color: Colors.blueGrey.shade800,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                            elevation: 0,
                            child: Container(
                              alignment: Alignment.topLeft,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 5,
                              ),
                              child: Image.asset(
                                'lib/assets/image/googleLogo.png',
                                height: 40,
                              ),
                              // Text(
                              //   'Google',
                              //   style: TextStyle(
                              //     color: Colors.white,
                              //     fontSize: 22,
                              //   ),
                              // ),
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
