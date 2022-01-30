import 'package:flutter/material.dart';
import 'package:spectrum_home2/panels/panel_room.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/widgets/panel_layout.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({Key? key}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  @override
  Widget build(BuildContext context) {
    return PanelLayout(data: {
      "Rooms": theme.server.rooms
          .map((e) => RoomPanel(
                room: e,
              ))
          .toList()
    });
  }
}
