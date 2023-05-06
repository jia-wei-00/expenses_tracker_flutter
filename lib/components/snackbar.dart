import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void snackBar(
    String text, Color bgColor, Color txtColor, BuildContext context) {
  var snackBar = SnackBar(
    content: Row(
      children: [
        const Icon(Icons.warning_rounded),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.poppins(
              textStyle: TextStyle(color: txtColor),
              fontWeight: FontWeight.w500),
        ),
      ],
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: 'Dismiss',
      textColor: Colors.white,
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
