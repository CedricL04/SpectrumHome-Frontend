import 'package:flutter/material.dart';
import 'package:spectrum_home2/main.dart' as theme;

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

  // static void setData(String key, Map data) {
  //   cache[key] = data;
  // }
}

class _RequestHandlerState extends State<RequestHandler> {
  Map? data;

  @override
  void initState() {
    theme.system.addEvent("request-update", _onRequestUpdate);
    if (cache.containsKey(widget.id) && !widget.forceReload) {
      data = cache[widget.id];
    } else {
      _sendRequest();
    }
    super.initState();
  }

  @override
  void dispose() {
    theme.system.removeEvent(_onRequestUpdate);
    super.dispose();
  }

  void _onRequestUpdate(String id) {
    if (widget.id == id) {
      _sendRequest();
    }
  }

  void _sendRequest() {
    theme.server.sendRequest(widget.request).then((value) {
      if (widget.save) cache[widget.id] = value;
      if (mounted)
        setState(() {
          data = value;
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.save) data = cache[widget.id];
    if (data != null || widget.whileLoading == null)
      return widget.builder(context, data ?? {});
    else
      return widget.whileLoading!(context);
  }
}
