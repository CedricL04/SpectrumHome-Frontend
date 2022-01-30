import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/main.dart';
import 'package:spectrum_home2/panels/panel_base.dart';
import 'package:spectrum_home2/utils/utils.dart';

class ScenePanel extends StatelessWidget {
  const ScenePanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> colors = server.rooms[0].devices
        .map((d) => Utils.adjustColor(d.fill.avgColor))
        .toList();

    return BouncyGestureDetector(
      child: Panel(
          smallPanel: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: LayoutBuilder(builder: (context, c) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Row(
                      children: List.generate(colors.length, (index) {
                        Color c = colors[index];
                        return Expanded(
                          child: Container(
                              height: 10,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(color: c, blurRadius: 50),
                              ])),
                        );
                      }),
                    ),
                  ),
                  Center(
                    child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colors))),
                  ),
                  ...List.generate(
                      colors.length,
                      (i) => Positioned(
                            left: Utils.map(0, 1, 0, c.maxWidth,
                                    i / (colors.length - 1)) -
                                2,
                            top: c.maxHeight / 2 - 2,
                            child: Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: colors[i]),
                            ),
                          ))
                ],
              );
            }),
          )),
    );
  }
}
