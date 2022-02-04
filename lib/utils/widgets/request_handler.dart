import 'package:flutter/material.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/server.dart';

Map cache = {};

class RequestHandler extends StatefulWidget {
  final Map<String, dynamic> request;
  final bool save;
  final bool forceReload;
  final String id;

  final Widget Function(BuildContext context, Map data) builder;
  final Widget Function(BuildContext context)? whileLoading;

  const RequestHandler(
      {required this.request,
      required this.builder,
      this.whileLoading,
      required this.id,
      this.save = true,
      this.forceReload = false,
      Key? key})
      : super(key: key);

  @override
  _RequestHandlerState createState() => _RequestHandlerState();
}

class _RequestHandlerState extends State<RequestHandler> {
  Map? data;

  @override
  void initState() {
    if (cache.containsKey(widget.id) && !widget.forceReload) {
      data = cache[widget.id];
    } else {
      theme.server.sendRequest(widget.request).then((value) {
        if (widget.save) cache[widget.id] = value;
        setState(() {
          data = value;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (data != null || widget.whileLoading == null)
      return widget.builder(context, data ?? {});
    else
      return widget.whileLoading!(context);
  }
}
