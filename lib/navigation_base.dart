import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/utils/widgets/offset_animation.dart';

class NavigationBase extends StatefulWidget {
  final int startPage = 0;

  final List<NavigationEntry> pages;
  final bool popButton;
  final void Function()? backAction;

  const NavigationBase(
      {required this.pages, this.popButton = false, this.backAction, Key? key})
      : super(key: key);

  @override
  _NavigationBaseState createState() => _NavigationBaseState();
}

class _NavigationBaseState extends State<NavigationBase>
    with SingleTickerProviderStateMixin {
  late int selectedIndex;

  late AnimationController _controller;

  bool _init = true;

  @override
  void initState() {
    _controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 400));
    this.selectedIndex = widget.startPage;
    super.initState();
    setState(() {
      _controller.forward().then((value) => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    bool small = theme.isSmall(context);
    bool init = _init;
    _init = false;

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _controller.reverse();
        });
        return true;
      },
      child: Scaffold(
        backgroundColor: _controller.isCompleted
            ? theme.backgroundColorDark
            : Colors.transparent,
        bottomNavigationBar: small ? _getSmallNavigation() : null,
        body: Row(
          children: [
            if (!small) _getLargeNavigation(),
            Expanded(
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(small ? -1 : 1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: _controller, curve: theme.curve)),
                child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: theme.radius,
                            bottomRight: small ? theme.radius : Radius.zero,
                            topLeft: small ? Radius.zero : theme.radius)),
                    child: widget.pages[selectedIndex].builder(context, init)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSmallNavigation() {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        color: theme.backgroundColorDark,
        width: double.infinity,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
              widget.pages.length,
              (index) => BouncyGestureDetector(
                    onTap: () => setState(() => selectedIndex = index),
                    child: Icon(
                      widget.pages[index].icon,
                      size: 30,
                      color: theme.foregroundColor
                          .withOpacity(index == selectedIndex ? 1 : .4),
                    ),
                  )),
        ),
      ),
    );
  }

  Widget _getLargeNavigation() {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: _controller, curve: theme.curve)),
      child: Container(
        color: theme.backgroundColorDark,
        width: 230,
        child: SafeArea(
          child: Stack(
            children: [
              AnimatedPositioned(
                top: selectedIndex * 50.0 + 100,
                child: Container(
                  width: 5,
                  height: 50,
                  decoration: BoxDecoration(
                      color: theme.foregroundColor,
                      borderRadius: BorderRadius.only(
                          topRight: theme.radius, bottomRight: theme.radius)),
                ),
                duration: Duration(milliseconds: 200),
                curve: theme.curve,
              ),
              Column(
                children: [
                  widget.popButton
                      ? BouncyGestureDetector(
                          onTap: widget.backAction ??
                              () => Navigator.maybePop(context),
                          child: Container(
                            height: 100,
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_rounded,
                                color: theme.foregroundColor,
                                size: 50,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          height: 100,
                          child: BouncyGestureDetector(
                            onTap: widget.backAction ??
                                () => Navigator.maybePop(context),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Hero(
                                tag: "spectrum-logo",
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/logo/logo2.png"))),
                                ),
                              ),
                            ),
                          ),
                        )
                ]..addAll(List.generate(widget.pages.length, (index) {
                    var page = widget.pages[index];
                    bool selected = index == selectedIndex;
                    return OffsetAnimation(
                        offset: Duration(milliseconds: index * 100 + 200),
                        builder: (context, parent) {
                          return SlideTransition(
                              position: Tween<Offset>(
                                      begin: Offset(-1, 0), end: Offset.zero)
                                  .animate(CurvedAnimation(
                                      parent: parent, curve: theme.curve)),
                              child: Container(
                                height: 50,
                                child: BouncyGestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () =>
                                      setState(() => selectedIndex = index),
                                  child: Row(
                                    children: [
                                      AnimatedPadding(
                                        curve: theme.curve,
                                        duration: Duration(milliseconds: 100),
                                        padding: EdgeInsets.only(
                                            left: (selected ? 15 : 10),
                                            right: 10),
                                        child: Icon(
                                          page.icon,
                                          size: 30,
                                          color: theme.foregroundColor
                                              .withOpacity(selected ? 1 : .5),
                                        ),
                                      ),
                                      Text(
                                        page.text,
                                        style: TextStyle(
                                            color: theme.foregroundColor
                                                .withOpacity(selected ? 1 : .5),
                                            fontSize: 17,
                                            fontWeight: selected
                                                ? FontWeight.normal
                                                : FontWeight.w300),
                                      )
                                    ],
                                  ),
                                ),
                              ));
                        });
                  })),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationEntry {
  final String text;
  final IconData icon;
  final Function(BuildContext contet, bool init) builder;
  final bool newPage;

  const NavigationEntry(this.text, this.icon, this.builder,
      {this.newPage = false});
}
