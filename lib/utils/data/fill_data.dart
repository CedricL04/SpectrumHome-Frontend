import 'package:flutter/material.dart';
import 'package:spectrum_home2/utils/utils.dart';

class FillData {
  List<FillDataEntry> _entries = [];

  FillData(List<Color> colors, [List<double>? stops]) {
    assert(colors.isNotEmpty);
    if (colors.length == 1) {
      colors.add(colors[0]);
      stops = [0, 1];
    }
    if (stops == null || colors.length != stops.length) {
      stops = List.generate(
          colors.length, (index) => 1 / (colors.length - 1) * index);
    }
    _entries = List.generate(
        colors.length, (i) => FillDataEntry(colors[i], stops![i]));
    _sort();
  }

  List<Color> get colors => _entries.map((e) => e.color).toList();
  List<double> get stops => _entries.map((e) => e.stop).toList();
  List<double> get partBoundings {
    List<double> partBoundings = [0];
    for (int i = 0; i < stops.length - 1; i++) {
      partBoundings.add((stops[i] + stops[i + 1]) / 2);
    }
    partBoundings.add(1);
    return partBoundings;
  }

  int get length => _entries.length;

  String get formatted {
    String grad = "";
    for (int i = 0; i < _entries.length; i++) {
      FillDataEntry en = _entries[i];
      grad += Utils.colorToString(en.color);
      grad += "-";
      grad += en.stop.toStringAsFixed(3);
      if (i != _entries.length - 1) grad += ";";
    }
    return grad;
  }

  LinearGradient get gradient => LinearGradient(colors: colors, stops: stops);
  LinearGradient get adjustedGradient =>
      LinearGradient(colors: Utils.adjustFill(colors), stops: stops);

  Color get first => colors[0];

  Color get avgColor {
    double red = 0;
    double green = 0;
    double blue = 0;

    List<double> bounds = partBoundings;

    for (int i = 0; i < _entries.length; i++) {
      FillDataEntry e = _entries[i];
      Color c = e.color;
      double flex = bounds[i + 1] - bounds[i];

      red += c.red * flex;
      green += c.green * flex;
      blue += c.blue * flex;
    }
    return Color.fromARGB(255, red.round(), green.round(), blue.round());
  }

  void _sort() {
    _entries.sort((e1, e2) => e1.stop > e2.stop ? 1 : -1);
  }

  // void adjustFill() {
  //   _entries.forEach((e) => e.color = Utils.adjustColor(e.color));
  // }

  FillDataType get type {
    if (_entries.length < 2 ||
        (_entries.length == 2 && _entries[0] == _entries[1]))
      return FillDataType.solid;
    return FillDataType.gradient;
  }

  BoxDecoration createDecoration(
      {BorderRadiusGeometry? borderRadius,
      List<BoxShadow> shadow = const [],
      BoxBorder? border}) {
    return BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadow,
        border: border,
        color: type == FillDataType.solid ? first : null,
        gradient: type == FillDataType.gradient ? adjustedGradient : null);
  }

  operator ==(dynamic other) {
    if (other is FillData) {
      return Utils.compareLists(_entries, other._entries);
    }
    return false;
  }
}

class FillDataEntry extends Object {
  Color color;
  double stop;

  FillDataEntry(this.color, this.stop);

  operator ==(dynamic other) {
    if (other is FillDataEntry) {
      return color == other.color && stop == other.stop;
    }
    return false;
  }
}

enum FillDataType { solid, gradient }
