import 'package:flutter/material.dart';
import 'package:spectrum_home2/dataObjects/device.dart';
import 'package:spectrum_home2/main.dart' as theme;

class RawDeviceItem<T extends Object> extends StatefulWidget {
  final Device? device;
  final Widget child;

  final void Function(T value) onValueUpdate;
  final T Function() onValueRequest;

  const RawDeviceItem(
      {Key? key,
      required this.device,
      required this.onValueRequest,
      required this.child,
      required this.onValueUpdate})
      : super(key: key);

  @override
  RawDeviceItemState<T> createState() => RawDeviceItemState<T>();
}

class RawDeviceItemState<T extends Object> extends State<RawDeviceItem<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool? selected;

  void _onDeviceSelected(Device d) {
    if (d == widget.device) {
      _controller.animateTo(1);
      selected = true;
    } else {
      _controller.animateTo(0);
      selected = false;
    }
  }

  // void _onDeviceUpdate(Device d) {
  //   if (d == widget.device) setState(() {});
  // }

  @override
  void initState() {
    _controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 100));
    theme.system.addEvent("device-selected", _onDeviceSelected);
    // theme.system.addEvent("device-update-finished", _onDeviceUpdate);
    super.initState();
  }

  @override
  void dispose() {
    theme.system.removeEvent(_onDeviceSelected);
    // theme.system.removeEvent(_onDeviceUpdate);
    _controller.dispose();
    super.dispose();
  }

  //List<Color> _fill;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1, end: 1.2)
          .animate(CurvedAnimation(parent: _controller, curve: theme.curve)),
      //to get the value by AddPresetDraggable()
      child: DragTarget<void Function(T)>(
        onWillAccept: (e) => true,
        onAccept: (func) => func(widget.onValueRequest()),
        builder: (context, candidateData, rejectedData) {
          //To set the value by dragging a field on it
          return DragTarget<T>(
              onWillAccept: (c) => true,
              onAccept: (c) {
                theme.system.call("device-selected", widget.device);
                widget.onValueUpdate(c);
              },
              builder: (context, colors, dynamics) {
                return widget.child;
              });
        },
      ),
    );
  }

  bool? isSelected() {
    return selected;
  }
}
