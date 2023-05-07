import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Text smallFont(String text,
    {bool italic = false, bool bold = false, Color color = Colors.white}) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      fontStyle: italic ? FontStyle.italic : null,
      color: color,
    ),
  );
}

Text mediumFont(String text,
    {bool italic = false, bool bold = false, Color color = Colors.white}) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      fontStyle: italic ? FontStyle.italic : null,
      color: color,
    ),
  );
}

Text bigFont(String text,
    {bool italic = false, bool bold = false, Color color = Colors.white}) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      fontStyle: italic ? FontStyle.italic : null,
      color: color,
    ),
  );
}
