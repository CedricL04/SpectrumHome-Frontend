import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/panels/panel_base.dart';
import 'package:spectrum_home2/utils/data/fill_data.dart';
import 'package:spectrum_home2/utils/utils.dart';
import 'package:spectrum_home2/main.dart' as theme;

class ScenePanel extends StatelessWidget {
  const ScenePanel({required this.fill, required this.sceneName, Key? key})
      : super(key: key);

  final FillData fill;
  final String sceneName;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = fill.colors;

    return BouncyGestureDetector(
      onTap: () async {
        Map json = await theme.server.sendRequest({
          "type": "scene",
          "action": "apply",
          "values": {"name": sceneName}
        });
        print(json.toString());
      },
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
