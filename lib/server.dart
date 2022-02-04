import 'dart:async';
import 'dart:convert';

import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/widgets/request_handler.dart' as req;

class Server {
  List<Room> rooms = [];

  String? ip;
  late User user;
  Map<String, dynamic>? userData, publicData;

  Future<bool> loadDeviceData(String ip, String username) async {
    this.ip = ip;
    this.user = User(username);
    _clearData();

    //authenticate user
    if (!await user.authenticate()) return false;
    //request data to sync with the storage api
    userData = await requestUserdata(false);
    publicData = await requestUserdata(true);

    //load the device data
    var response = await http.post(Uri.parse(_getURL()),
        body: jsonEncode({"type": "device-management", "action": "get"}));

    //Room room = Room("Default");

    Map json = jsonDecode(response.body);

    json.forEach((key, value) {
      String roomName = value["room"] ?? "Default";
      Device device = Device(key, value);

      for (Room r in rooms) {
        if (r.name.toLowerCase() == roomName.toLowerCase()) {
          r.addDevice(device);
          break;
        }
      }

      if (device.room == null) {
        Room room = new Room(roomName);
        room.addDevice(device);
        rooms.add(room);
      }
    });

    rooms.forEach((r) => r.devices.forEach((d) => checkConnection(d)));

    return true;
  }

  Future<bool> checkConnection(Device device) async {
    var js = {
      "type": "device-management",
      "action": "check",
      "device": device.id
    };

    var response = await http.post(Uri.parse(_getURL()), body: jsonEncode(js));
    var body = jsonDecode(response.body);

    bool connected = body["connected"] ?? false;

    device.connectionState = connected
        ? DeviceConnectionState.connected
        : DeviceConnectionState.disconnected;

    theme.system.call("update-connection", device);

    return connected;
  }

  String _getURL() {
    return 'http://$ip:6917/package';
  }

  Future<Map<String, dynamic>> sendRequest(Map<String, dynamic> data) async {
    data["user"] = user.name;
    var body = jsonEncode(data);
    var request = await http.post(Uri.parse(_getURL()), body: body);
    return jsonDecode(request.body);
  }

  void updateState(
      {required Device device,
      required String name,
      String? type,
      required String value}) async {
    try {
      var data = await sendRequest({
        "type": "device-update",
        "action": "update",
        "device": "${device.id}",
        "values": {
          "state-name": name,
          "value-type": type ?? name,
          "value": value
        }
      });
      device.updateStateJson(data);
    } catch (ex) {
      print(ex);
    }
  }

  Future<Map<String, dynamic>?> requestUserdata(bool public) async {
    var data = await (sendRequest({
      "type": "storage",
      "action": "load",
      "values": {"public": public, "path": ""}
    }));
    if (data["error"]) return {};
    return data["data"];
  }

  Future syncedUpdate(dynamic data, String path, {bool public = false}) async {
    Utils.write(public ? publicData : userData, data, path);
    await sendRequest({
      "type": "storage",
      "action": "save",
      "values": {"public": public, "path": path, "data": data}
    });
  }

  void _clearData() {
    rooms.clear();
    req.cache.clear();
  }
}

class User {
  final String name;

  User(this.name);

  Future<bool> authenticate() async {
    var data = await (theme.server.sendRequest({
      "type": "user",
      "action": "verify",
      "values": {"name": this.name}
    }));
    return data["verified"];
  }
}
