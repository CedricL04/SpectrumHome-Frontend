import 'package:flutter/material.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';

class Utils {
  static String colorToString(Color c) {
    int rgb = c.value;

    return rgb.toRadixString(16).substring(2);
  }

  static List<String> splitNth(String str, int n) {
    List<String> toReturn = [];
    int length = str.length;

    int cur = 0;

    while (cur < length) {
      String s;
      if (cur + n <= length) {
        s = str.substring(cur, cur + n);
      } else {
        s = str.substring(cur, length);
      }
      toReturn.add(s);
      cur += n;
    }

    return toReturn;
  }

  static Color stringToColor(String s, {Color def = Colors.black}) {
    try {
      return Color(int.parse(s, radix: 16)).withAlpha(255);
    } catch (ex) {
      return def;
    }
  }

  static FillData stringToGradient(String last) {
    List<Color> colors = [];
    List<double> stops = [];

    for (String stop in last.split(";")) {
      List<String> parts = stop.split("-");
      if (parts.length < 2) continue;
      colors.add(stringToColor(parts[0]));
      stops.add(double.parse(parts[1]));
    }

    return FillData(colors, stops);
  }

  static double map(double fromMin, double fromMax, double toMin, double toMax,
      double value) {
    return (value - fromMin) / (fromMax - fromMin) * (toMax - toMin) + toMin;
  }

  static bool compareLists(List l1, List l2) {
    if (l1.length != l2.length) return false;

    for (int i = 0; i < l1.length; i++) {
      if (l1[i] != l2[i]) return false;
    }
    return true;
  }

  static Color getAvgColor(List<Color> fill) {
    int r = 0, g = 0, b = 0, a = 0;
    int size = fill.length;
    for (Color c in fill) {
      r += c.red;
      g += c.green;
      b += c.blue;
      a += c.alpha;
    }
    r ~/= size;
    g ~/= size;
    b ~/= size;
    a ~/= size;
    return Color.fromARGB(a, r, g, b);
  }

  static List<Color> adjustFill(List<Color> fill) {
    return fill.map((e) {
      return adjustColor(e);
    }).toList();
  }

  static Color adjustColor(Color color) {
    var c = HSVColor.fromColor(color);
    return c
        .withSaturation(c.saturation.clamp(0, .7))
        .withValue(c.value.clamp(.7, 1))
        .toColor();
  }

  static void write(Map<String, dynamic>? obj, Object? data, String path) {
    Map<String, dynamic>? o = obj;

    List<String> parts = path.replaceAll("\\", "/").split("/");

    int count = 0;
    for (String s in parts) {
      count++;
      if (s.trim().isEmpty) continue;
      if (!o!.containsKey(s)) o[s] = Map<String, dynamic>();
      if (count == parts.length)
        o[s] = data;
      else
        o = o[s];
    }
  }

  static dynamic load(Map<String, dynamic>? obj, String path) {
    dynamic data = obj;

    List<String> parts = path.replaceAll("\\", "/").split("/");

    for (String s in parts) {
      if (s.trim().isEmpty) continue;
      if (data.containsKey(s)) {
        data = data[s];
      } else
        return null;
    }
    return data;
  }
}
