import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes/constants.dart';
import 'package:notes/services/auth.dart';
import 'homeUi.dart';
import 'logInUI.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
        overlays: [SystemUiOverlay.top]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      color: Colors.black,
      debugShowCheckedModeBanner: false,
      title: 'Notes.',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        textTheme: GoogleFonts.manropeTextTheme(),
        colorSchemeSeed: Colors.black,
        useMaterial3: true,
        scaffoldBackgroundColor: !isDark ? Colors.white : Colors.black,
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentuser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomeUi();
          } else {
            return LoginUI();
          }
        },
      ),
    );
  }
}
