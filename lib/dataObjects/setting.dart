import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';

class Setting {
  final String name;
  final IconData icon;
  final Widget Function(Setting s, List<Device> devices) _getWidget;

  Setting(this.name, this.icon, this._getWidget);

  Widget getWidget(List<Device> devices) {
    return _getWidget(this, devices);
  }
}
