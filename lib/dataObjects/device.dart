import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/dataObjects/setting.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/data/fill_data.dart';
import 'package:spectrum_home2/utils/utils.dart';

class Device {
  static const Color def = Colors.white;
  final String id;

  Map json;
  Room? room;

  DeviceConnectionState connectionState = DeviceConnectionState.unknown;

  late List<String> _settings;

  Device(this.id, this.json) {
    _updateData();
  }

  void updateJson(Map<String, dynamic> json) {
    this.json = json;
    _updateData();
  }

  void updateStateJson(Map<String, dynamic>? json) {
    this.json["states"] = json;
    _updateData();
    theme.system.call("device-update-finished", this);
  }

  void _updateData() {
    List<String> settings = [];
    Map? display = json["states"]["display"];
    if (display != null) {
      var entries = display["entries"];
      entries.forEach((key, value) {
        settings.add(key);
      });
    }
    _settings = settings;
  }

  String? get activeDisplay => json["states"]["display"]["active"];
  String? get colorString => json["states"]["display"]["entries"]["color"];
  String? get gradientString =>
      json["states"]["display"]["entries"]["gradient"];
  String? get icon => json["icon"];
  String? get iconPath => "assets/images/icons/${icon}.svg";

  String get name => json["name"] ?? id.substring(0, 10);

  bool get enabled =>
      json["states"]["toggle-state"]["entries"]["toggle-state"] == "true";

  Color get color =>
      colorString == null ? def : Utils.stringToColor(colorString!);

  double get brightness =>
      double.parse(json["states"]["brightness"]["entries"]["brightness"]);

  FillData get gradient => gradientString == "null" || gradientString == null
      ? FillData([Colors.white, Colors.black])
      : Utils.stringToGradient(gradientString!);

  FillData get fill {
    switch (activeDisplay) {
      case "color":
        Color color = this.color;
        return FillData([color]);
      case "gradient":
        return gradient;
    }
    return FillData([def]);
  }

  List<Setting> get settings {
    List<Setting> settings = [];
    for (Setting s in theme.settings) {
      if (_settings.contains(s.name)) settings.add(s);
    }
    return settings;
  }
}

enum DeviceConnectionState { disconnected, connected, unknown }

// 0 = connnected; 1 = unknown; 2 = disconnected;
extension DeviceConnectionStateExtension on DeviceConnectionState {
  int get val {
    switch (this) {
      case DeviceConnectionState.connected:
        return 0;
      case DeviceConnectionState.disconnected:
        return 2;
      default:
        return 1;
    }
  }
}
