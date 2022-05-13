import 'package:flutter/material.dart';

class LightColors {
  Color customLightAccent = Color(0xFFD6E3FF);
  Color customDark = Color(0xFF2B3B96);
}

class DarkColors {
  Color darkAccent = Color(0xFFF1F6FF);
  Color darkBg = Color.fromARGB(255, 20, 20, 20);
}

class NoteColors {
  Map<String, dynamic> colorPallete = {
    'black': {
      'bg': Colors.grey.shade800,
      'text': Colors.white,
      'hintText': Colors.grey.shade600,
      'labelCard': Colors.blueGrey,
    },
    'green': {
      'bg': Color.fromARGB(255, 9, 58, 11),
      'text': Colors.white,
      'hintText': Colors.grey.shade600,
      'labelCard': Colors.green.shade600,
    },
    'orange': {
      'bg': Colors.orange,
      'text': Colors.black,
      'hintText': Colors.white.withOpacity(0.4),
      'labelCard': Colors.deepOrange,
    },
    'grey': {
      'bg': Color.fromARGB(255, 180, 180, 180),
      'text': Colors.black,
      'hintText': Colors.white.withOpacity(0.4),
      'labelCard': Colors.grey.shade700,
    },
    'blue': {
      'bg': Color.fromARGB(255, 0, 102, 150),
      'text': Colors.white,
      'hintText': Colors.white.withOpacity(0.4),
      'labelCard': Color.fromARGB(255, 0, 50, 92),
    },
    'white': {
      'bg': Colors.white,
      'text': Colors.black,
      'hintText': Colors.grey.shade400,
      'labelCard': Colors.black,
    },
  };
}
