import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/room.dart';
import 'package:spectrum_home2/panels/panel_scene.dart';
import 'package:spectrum_home2/utils/utils.dart';
import 'package:spectrum_home2/utils/widgets/panel_layout.dart';
import 'package:spectrum_home2/main.dart' as theme;

class ScenePage extends StatefulWidget {
  final Room room;

  const ScenePage({required this.room, Key? key}) : super(key: key);

  @override
  _ScenePageState createState() => _ScenePageState();
}

class _ScenePageState extends State<ScenePage> {
  @override
  Widget build(BuildContext context) {
    List<Device> devs = widget.room.devices;
    double iconPadding = 20;
    double iconSize = 30;
    double height = 150;
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: height,
            constraints: BoxConstraints(maxWidth: 600),
            child: LayoutBuilder(builder: (context, c) {
              return Stack(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      width: double.infinity,
                      height: 1,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: widget.room.avgFill.colors)),
                    ),
                  ),
                  ...List.generate(devs.length, (index) {
                    Device dev = devs[index];
                    Color avg = dev.fill.avgColor;
                    return Positioned(
                      top: (height - iconSize) / 2,
                      left: index /
                              (devs.length - 1) *
                              (c.maxWidth - iconSize - iconPadding * 2) +
                          iconPadding,
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                            color: theme.backgroundColor,
                            border: Border.all(color: avg),
                            shape: BoxShape.circle),
                        child: Center(
                          child: SvgPicture.asset(
                            dev.iconPath!,
                            width: iconSize - 10,
                            height: iconSize - 10,
                            color: Utils.adjustColor(avg),
                          ),
                        ),
                      ),
                    );
                  })
                ],
              );
            }),
          ),
          // Expanded(
          //   child: PanelLayout(data: {
          //     "Snapshots": List.generate(10, (index) => ScenePanel([Colors.red]))
          //   }),
          // ),
        ],
      ),
    );
  }
}
