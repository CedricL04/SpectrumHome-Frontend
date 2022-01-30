import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:spectrum_home2/main.dart' as theme;

class AddPresetDraggable<T> extends StatefulWidget {
  final void Function(dynamic)? onUpdate;
  final void Function(dynamic)? onDelete;

  const AddPresetDraggable({this.onUpdate, this.onDelete, Key? key})
      : super(key: key);

  @override
  _AddPresetDraggableState<T> createState() => _AddPresetDraggableState<T>();
}

class _AddPresetDraggableState<T> extends State<AddPresetDraggable> {
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onWillAccept: (e) => widget.onDelete != null && e is T,
      onAccept: (e) {
        widget.onDelete!(e);
      },
      builder: (context, candidateData, rejectedData) =>
          Draggable<Function(T callback)>(
        data: (callback) {
          if (widget.onUpdate != null) widget.onUpdate!(callback);
        },
        childWhenDragging: Container(
          width: 50,
          height: 50,
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              border: Border.all(width: 3, color: theme.foregroundColor),
              borderRadius:
                  theme.borderRadius - BorderRadius.all(Radius.circular(5))),
        ),
        dragAnchorStrategy: (draggable, context, position) => Offset.zero,
        feedback: Transform.translate(
          offset: Offset(-17, -17),
          child: DecoratedIcon(
            Icons.add,
            size: 35,
            color: theme.foregroundColor,
            shadows: theme.elevation1shadow,
          ),
        ),
        child: _getContent(),
      ),
    );
  }

  Container _getContent() {
    return Container(
      margin: EdgeInsets.all(5),
      width: 50,
      height: 50,
      child: Center(
          child: DecoratedIcon(
        Icons.add_rounded,
        shadows: theme.elevation1shadow,
        color: theme.foregroundColor,
        size: 35,
      )),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: theme.foregroundColor),
          borderRadius:
              theme.borderRadius - BorderRadius.all(Radius.circular(5))),
    );
  }
}
