import 'dart:math';
import 'package:flutter/material.dart';

Color fromInt(int c){
  int r = c & 0xFF;
  int g = (c >> 8) & 0xFF;
  int b = (c >> 16) & 0xFF;
  return Color.fromRGBO(r, g, b, 1.0);
}



Color fromHSL(h, s, l){
  var r;
  var g;
  var b;
  if (s == 0)
  {
    r = l * 255;
    g = l * 255;
    b = l * 255;
  }
  else
  {
    var t2 = (l < .5)? (l * (1 + s)) : ((l + s) - (s * l));
    var t1 = (2 * l) - t2;
    r = 255 * hueToDouble(t1, t2, h + (1 / 3));
    g = 255 * hueToDouble(t1, t2, h);
    b = 255 * hueToDouble(t1, t2, h - (1 / 3));
  }

  return Color.fromRGBO(r.round(), g.round(), b.round(), 1.0);
}

double hueToDouble(pT1, pT2, pH){
  if (pH < 0)
    pH++;
  else if (pH > 1)
    pH--;
  if ((6 * pH) < 1)
    return (pT1 + (pT2 - pT1) * 6 * pH);
  if ((2 * pH) < 1)
    return pT2;
  if ((3 * pH) < 2)
    return (pT1 + (pT2 - pT1) * ((2 / 3) - pH) * 6);
  return pT1;
}

HSLColor fromColor(Color color){

  var l;
  var s;
  var h;

  final r = color.red / 255;
  final g = color.green / 255;
  final b = color.blue / 255;

  var minVal = min(r, g);
  minVal = min(minVal, b);
  var maxVal = max(r, g);
  maxVal = max(maxVal, b);
  var d = maxVal - minVal;
  l = (minVal + maxVal) / 2;

  if (d==0)
    h = s = 0.0
  ;
  else
  {
    s = l < .5?(d / (maxVal + minVal)):(d / (2 - maxVal - minVal));

    var dr = (((maxVal - r) / 6) + (d / 2)) / d;
    var dg = (((maxVal - g) / 6) + (d / 2)) / d;
    var db = (((maxVal - b) / 6) + (d / 2)) / d;

    if(maxVal == r){
      h = db - dg;
    }
    else if(maxVal == g){
      h = (1 / 3) + (dr - db);
    }
    else if(maxVal == b){
      h = (2 / 3) + dg - dr;
    }
  }

  return HSLColor(h, s, l);
}

class HSLColor
{
  double h;
  double s;
  double l;

  HSLColor(this.h, this.s, this.l);


}