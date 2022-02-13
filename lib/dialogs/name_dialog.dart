import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/overlay_page_base.dart';
import 'package:spectrum_home2/main.dart' as theme;

class NameDialog extends StatefulWidget {
  final Object? heroTag;
  final Widget child;
  final Future<String?> Function(String s) validator;
  final String? text;

  const NameDialog(
      {required this.child,
      required this.validator,
      this.text,
      this.heroTag,
      Key? key})
      : super(key: key);

  @override
  _NameDialogState createState() => _NameDialogState();
}

class _NameDialogState extends State<NameDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _textEditingController = TextEditingController();
  FocusNode _node = FocusNode();

  String? error;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    if (widget.text != null) _textEditingController.text = widget.text!;

    super.initState();
    _controller.forward();
    Future.delayed(_controller.duration!).then((value) {
      if (mounted) _node.requestFocus();
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
      child: OverlayPageBase(
          blur: true,
          child: Column(
            children: [
              if (widget.heroTag != null)
                Hero(tag: widget.heroTag!, child: widget.child)
              else
                widget.child,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                constraints: BoxConstraints(maxWidth: 600),
                child: FadeTransition(
                  opacity: _controller,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _textEditingController,
                      textCapitalization: TextCapitalization.words,
                      focusNode: _node,
                      decoration: theme.getTextFieldStyle(context),
                      onFieldSubmitted: (s) async {
                        error = await widget.validator(s);
                        if (error == null) Navigator.maybePop(context);
                        _formKey.currentState!.validate();
                      },
                      validator: (s) => error,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
