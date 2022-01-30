import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/main.dart' as theme;

class NotConnectedPanel extends StatelessWidget {
  final void Function() onTap;

  const NotConnectedPanel({required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Disconnected",
            style: theme.h4,
          ),
          SizedBox(
            height: 10,
          ),
          BouncyGestureDetector(
              onTap: onTap,
              child: Icon(
                Icons.refresh,
                size: 30,
              ))
        ],
      ),
    );
  }
}
