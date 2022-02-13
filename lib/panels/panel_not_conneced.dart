import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/main.dart' as theme;

class NotConnectedPanel extends StatelessWidget {
  final void Function() onTap;
  final Device device;

  const NotConnectedPanel({required this.onTap, required this.device, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            device.name,
            style: theme.h3,
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
