import 'package:flutter/material.dart';
import 'package:spectrum_home2/utils/widgets/loading_animation.dart';

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: LoadingAnimation(),
        height: 60,
      ),
    );
  }
}
