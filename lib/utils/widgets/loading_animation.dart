import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:spectrum_home2/main.dart' as theme;

// ignore: implementation_imports
import 'package:flutter/src/painting/gradient.dart' as grad;

class LoadingAnimation extends StatefulWidget {
  @override
  _LoadingAnimationState createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation> {
  Artboard? _artboard;
  @override
  void initState() {
    rootBundle.load("assets/rive/loading.riv").then((data) async {
      final file = RiveFile.import(data);
      final artboard = file.mainArtboard;

      artboard.addController(
          StateMachineController.fromArtboard(artboard, "State Machine")!);
      if (mounted) setState(() => _artboard = artboard);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) return Container();
    Color color = theme.foregroundColor;
    return ShaderMask(
      shaderCallback: (bounds) =>
          grad.LinearGradient(colors: [color, color]).createShader(bounds),
      child: Rive(
        artboard: _artboard!,
      ),
    );
  }
}
