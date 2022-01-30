import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/setting.dart';
import 'package:spectrum_home2/panels/panel_device.dart';
import 'package:spectrum_home2/dialogs/overlay_page_base.dart';
import 'package:spectrum_home2/main.dart' as theme;

class SettingDialog extends StatefulWidget {
  final Widget child;
  final Setting setting;
  //final SettingController controller;

  const SettingDialog({required this.child, required this.setting, Key? key})
      : super(key: key);

  @override
  _SettingDialogState createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog>
    with SingleTickerProviderStateMixin {
  final int _animationLength = 300;

  late AnimationController _controller;

  @override
  void initState() {
    _controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: _animationLength));

    theme.system.addEvent("device-selected", _selectDevice);

    // if (widget.controller != null) {
    //   widget.controller.getActive = () => currentDevice;
    // }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    theme.system.removeEvent(_selectDevice);
    super.dispose();
  }

  Device? currentDevice;
  Device? _animateBackCache;

  void _selectDevice(Device? d) async {
    if (d == null) return;
    if (d == currentDevice) return;
    if (currentDevice != null) {
      await _controller.animateTo(0,
          duration: Duration(milliseconds: _animationLength ~/ 2));
    }
    if (mounted) {
      setState(() {
        currentDevice = d;
        _controller.animateTo(1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPageBase(
        slideIn: true,
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints(maxWidth: 450),
            child: Stack(
              children: [
                AnimatedPositioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: (currentDevice) == null ? 0 : 140,
                  child: Container(
                    margin: EdgeInsets.all(20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: theme.elevation1,
                        borderRadius: theme.borderRadius),
                    child: widget.child,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: theme.curve,
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
                            .animate(CurvedAnimation(
                                parent: _controller, curve: theme.curve)),
                    child: Container(
                      height: 120,
                      margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: (_animateBackCache ?? currentDevice) != null
                          ? DevicePanel(
                              key: ValueKey<Device?>(
                                  _animateBackCache ?? currentDevice),
                              device: _animateBackCache ?? currentDevice!)
                          : Container(),
                    ),
                  ),
                  bottom: 0,
                )
              ],
            ),
          ),
        ));
  }
}

@deprecated
class SettingController {
  Device Function()? getActive;

  SettingController();
}
