import 'package:flutter/material.dart';

Color fromInt(int c){
  int r = c & 0xFF;
  int g = (c >> 8) & 0xFF;
  int b = (c >> 16) & 0xFF;
  return Color.fromRGBO(r, g, b, 1.0);
}