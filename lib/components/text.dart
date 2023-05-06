import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Text smallFont(String text, {bool italic = false, bold = false}) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      fontStyle: italic ? FontStyle.italic : null,
    ),
  );
}

Text mediumFont(String text, {bool italic = false, bool bold = false}) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      fontStyle: italic ? FontStyle.italic : null,
    ),
  );
}

Text bigFont(String text, {bool italic = false}) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      fontStyle: italic ? FontStyle.italic : null,
    ),
  );
}
