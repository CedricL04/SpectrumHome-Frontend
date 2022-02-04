import 'package:flutter/material.dart';
import 'package:spectrum_home2/main.dart' as theme;

class PanelLayout extends StatelessWidget {
  final Map<String, dynamic> data;
  const PanelLayout({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool small = theme.isSmall(context);
    return SafeArea(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: small ? _getSmall(context) : _getLarge(context),
        ),
      ),
    );
  }

  Widget _getLarge(BuildContext context) {
    List<Widget> children = [];
    for (String title in data.keys) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 20, top: 10),
        child: Text(
          title,
          style: theme.h2,
        ),
      ));
      dynamic w = data[title]!;
      if (w is List) {
        children.add(Wrap(
          children: w
              .map((e) => Padding(
                    child: e,
                    padding: EdgeInsets.all(8),
                  ))
              .toList(),
        ));
      } else if (w is Widget) {
        children.add(w);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _getSmall(BuildContext context) {
    List<Widget> children = [];

    for (String title in data.keys) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 20, top: 5),
        child: Text(
          title,
          style: theme.h2,
        ),
      ));
      dynamic w = data[title]!;
      if (w is List) {
        children.addAll((data[title]! as List)
            .map((e) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: e,
                ))
            .toList());
      } else if (w is Widget) {
        children.add(w);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
