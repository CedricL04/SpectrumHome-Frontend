import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';

class Room {
  Room(this.name);
  String name;
  List<Device> devices = [];

  void addDevice(Device d) {
    devices.add(d);
    d.room = this;
  }

  double get avgOpcaity {
    double avg = 0;
    for (Device d in devices) avg += d.brightness;
    return avg / devices.length;
  }

  FillData get avgFill =>
      FillData(devices.map((e) => e.fill.avgColor).toList());

  bool get toggleState {
    bool toggled = false;
    for (Device d in devices) {
      if (d.enabled) toggled = true;
    }
    return toggled;
  }
}
