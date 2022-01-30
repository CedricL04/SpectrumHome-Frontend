import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/dataObjects/setting.dart';
import 'package:spectrum_home2/panels/panel_device.dart';
import 'package:spectrum_home2/dialogs/overlay_page_base.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/settings/settings_button.dart';

class DevicePanelDialog extends StatefulWidget {
  final Device device;
  final double startHeight;

  const DevicePanelDialog(
      {required this.device, this.startHeight = 100, Key? key})
      : super(key: key);

  @override
  _DevicePanelDialogState createState() => _DevicePanelDialogState();
}

class _DevicePanelDialogState extends State<DevicePanelDialog>
    with SingleTickerProviderStateMixin {
  late List<Setting> settings;

  @override
  void initState() {
    settings = widget.device.settings;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPageBase(
        child: WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
          child: Stack(
            children: [
              Positioned(
                top: (widget.startHeight - 5)
                    .clamp(30, MediaQuery.of(context).size.height - 200)
                    .toDouble(),
                left: 0,
                right: 0,
                bottom: 0,
                child: Stack(
                  children: [
                    Positioned(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        child: Row(
                          children: List.generate(settings.length, (index) {
                            return OffsetFadeAnimationWrapper(
                              offset: Duration(milliseconds: 200 + 50 * index),
                              child: SettingsButton(
                                devices: widget.device.room!.devices,
                                onTap: () async {
                                  Future.delayed(Duration(milliseconds: 100))
                                      .then((value) => theme.system.call(
                                          "device-selected", widget.device));
                                  // Navigator.pop(context);
                                  // await Future.delayed(Duration(milliseconds: 100));
                                  return false;
                                },
                                setting: settings[index],
                              ),
                            );
                          }),
                        ),
                      ),
                      top: 120,
                      left: 0,
                      right: 0,
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Container(
                          height: 120,
                          child: DevicePanel(
                            device: widget.device,
                            panelHero: true,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class OffsetFadeAnimationWrapper extends StatefulWidget {
  final Duration offset;
  final Widget child;

  const OffsetFadeAnimationWrapper(
      {required this.offset, required this.child, Key? key})
      : super(key: key);

  @override
  _OffsetFadeAnimationWrapperState createState() =>
      _OffsetFadeAnimationWrapperState();
}

class _OffsetFadeAnimationWrapperState extends State<OffsetFadeAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 250));
    super.initState();
    Future.delayed(widget.offset).then((value) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _controller.reverse();
        return true;
      },
      child: FadeTransition(
        opacity: CurvedAnimation(curve: theme.curve, parent: _controller),
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, -1), end: Offset.zero)
              .animate(
                  CurvedAnimation(parent: _controller, curve: theme.curve)),
          child: widget.child,
        ),
      ),
    );
  }
}
