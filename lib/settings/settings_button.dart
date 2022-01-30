import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/setting.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/utils/hero_dialog_route.dart';
import '../main.dart' as theme;

class SettingsButton extends StatelessWidget {
  final Color? color;
  final Setting setting;
  final List<Device> devices;

  final Future<bool> Function()? onTap;

  const SettingsButton(
      {required this.setting,
      required this.devices,
      this.color,
      this.onTap,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StyledIconButton(
      color: color,
      icon: Icon(
        setting.icon,
        size: 30,
        color: theme.foregroundColor.withOpacity(.5),
      ),
      onTap: () async {
        if (onTap != null) if (await onTap!()) return;

        Navigator.push(context, HeroDialogRoute(builder: (context) {
          List<Device> devices = [];

          for (Device device in this.devices)
            if (device.settings.contains(setting) &&
                device.connectionState == DeviceConnectionState.connected)
              devices.add(device);
          return setting.getWidget(devices);
        }));
      },
    );
  }
}

class StyledIconButton extends StatelessWidget {
  const StyledIconButton({this.color, this.onTap, Key? key, this.icon})
      : super(key: key);

  final Color? color;
  final void Function()? onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return BouncyGestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(5),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: color ?? theme.elevation2,
            boxShadow: theme.elevation1shadow,
            borderRadius: theme.borderRadius),
        child: icon,
      ),
    );
  }
}
