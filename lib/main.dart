import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/services/auth.dart';
import 'package:page_route_transition/page_route_transition.dart';
import 'homeUi.dart';
import 'signInUi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top]);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PageRouteTransition.effect = TransitionEffect.rightToLeft;
    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      title: 'Notes.',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        textTheme: GoogleFonts.manropeTextTheme(),
        colorSchemeSeed: Colors.black,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentuser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeUi();
          } else {
            return SignInUi();
          }
        },
      ),
    );
  }
}
