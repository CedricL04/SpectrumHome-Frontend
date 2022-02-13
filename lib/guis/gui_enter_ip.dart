import 'package:flutter/material.dart';
import 'package:spectrum_home2/dialogs/bouncy_gesture_detector.dart';
import 'package:spectrum_home2/dialogs/overlay_page_base.dart';
import 'package:spectrum_home2/main.dart' as theme;
import 'package:spectrum_home2/settings/settings_button.dart';
import 'package:spectrum_home2/utils/hero_dialog_route.dart';
import 'package:spectrum_home2/utils/widgets/loading_animation.dart';
import 'package:spectrum_home2/utils/widgets/offset_animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:google_fonts/google_fonts.dart';

class GuiEnterIp extends StatefulWidget {
  @override
  _GuiEnterIpState createState() => _GuiEnterIpState();
}

class _GuiEnterIpState extends State<GuiEnterIp> {
  final List<String> images = [
    "assets/images/background/spectrum1.jpg",
    "assets/images/background/spectrum2.jpg",
    "assets/images/background/spectrum3.jpg"
  ];
  void submit() {
    theme.prefs.setString("lastIp", ipController.text);
    theme.prefs.setString("lastUser", userController.text);
    theme.prefs.setBool("autoconnect", true);
    Navigator.push(
        context,
        HeroDialogRoute(
            builder: (context) {
              return LoadingScreen(
                text: "Connecting to " + ipController.text,
                future: theme.server
                    .loadDeviceData(ipController.text, userController.text),
                callback: (dynamic value) {
                  Navigator.pushReplacement(
                      context,
                      HeroDialogRoute(
                          transparent: false,
                          builder: (context) => theme.MainScreen()));
                },
              );
            },
            transparent: true));
  }

  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  final TextEditingController ipController = new TextEditingController();
  final TextEditingController userController = new TextEditingController();

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  late String _lastIp;
  late String _lastUser;

  @override
  void initState() {
    _lastIp = theme.prefs.getString("lastIp") ?? "";
    _lastUser = theme.prefs.getString("lastUser") ?? "default";
    super.initState();

    Future.delayed(Duration(milliseconds: 100)).then((value) {
      if (_lastIp.isNotEmpty &&
          mounted &&
          (theme.prefs.getBool("autoconnect") ?? false)) submit();
    });
  }

  @override
  Widget build(BuildContext context) {
    ipController.text = _lastIp;
    userController.text = _lastUser;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: theme.backgroundColor,
        body: LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth > 800)
              return getLarge(context);
            else
              return getSmall(context);
          },
        ));
  }

  Widget getLarge(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: SizedBox(
              width: MediaQuery.of(context).size.height,
              child: CarouselSlider(
                items: images.map(getImage).toList(),
                options: CarouselOptions(
                    scrollDirection: Axis.vertical,
                    viewportFraction: .45,
                    aspectRatio: 8 / 12,
                    enlargeCenterPage: true,
                    autoPlay: true),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                color: theme.elevation1,
                borderRadius: BorderRadius.only(
                    topLeft: theme.radius, bottomLeft: theme.radius)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              child: getContent(),
            ),
          ),
        )
      ],
    );
  }

  Widget getSmall(BuildContext context) {
    // Widget slider = CarouselSlider(
    //   items: [
    //   ],
    //   options: CarouselOptions(
    //     enlargeCenterPage: true,
    //     aspectRatio: 2.5 / 1,
    //     viewportFraction: .62,
    //     autoPlay: true,
    //   ),
    // );

    return Container(
      color: theme.elevation1,
      constraints: BoxConstraints.expand(),
      child: SafeArea(
        child: SizedBox(
          child: getContent(),
          height: 500,
        ),
      ),
    );
  }

  Widget getImage(
    String path,
  ) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.transparent, borderRadius: theme.borderRadius),
        clipBehavior: Clip.antiAlias,
        child: Image(
          fit: BoxFit.cover,
          image: AssetImage(path),
        ),
      ),
    );
  }

  Widget getContent({Widget? child}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: "spectrum-logo",
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                            "assets/images/logo/logo2.png",
                          ))),
                          height: 64,
                          width: 130,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          "Spectrum",
                          style: GoogleFonts.orbitron(fontSize: 35),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              height: 64,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: TextField(
            decoration:
                theme.getTextFieldStyle(context, labelName: "Ip", filled: true),
            style: TextStyle(color: theme.foregroundColor),
            controller: ipController,
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: TextField(
            decoration: theme.getTextFieldStyle(context,
                labelName: "User", filled: true),
            style: TextStyle(color: theme.foregroundColor),
            controller: userController,
          ),
        ),
        Padding(
          child: StyledIconButton(
            onTap: submit,
            icon: Icon(
              Icons.check,
              color: theme.foregroundColor,
              size: 30,
            ),
          ),
          padding: EdgeInsets.only(bottom: 30),
        ),
        if (child != null) child,
        Expanded(
            child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                "Made with",
                style: TextStyle(
                    color: theme.foregroundColor.withOpacity(.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BouncyGestureDetector(
                onTap: () => _launchURL("https://www.java.com/de/"),
                child: Image(
                  image: AssetImage("assets/images/logo/credits/java.png"),
                  height: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BouncyGestureDetector(
                  onTap: () => _launchURL("https://flutter.dev"),
                  child: Image(
                    image: AssetImage("assets/images/logo/credits/flutter.png"),
                    height: 22,
                  )),
            )
          ],
        ))
      ],
    );
  }
}

class LoadingScreen<T> extends StatefulWidget {
  const LoadingScreen(
      {Key? key,
      this.text = "loading",
      required this.future,
      required this.callback})
      : super(key: key);

  final Future<T> future;
  final Function(T) callback;

  final String text;

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _execute();
  }

  void _execute() async {
    var value = await widget.future;
    if (mounted) {
      Navigator.maybePop(context);
      widget.callback(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPageBase(
      blur: false,
      slideIn: true,
      startOffset: Offset(0, .5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 500),
              child: AspectRatio(
                aspectRatio: 1,
                child: LoadingAnimation(),
              ),
            ),
            OffsetAnimation(
              builder: (builder, controller) => SlideTransition(
                position: Tween<Offset>(begin: Offset(0, 10), end: Offset.zero)
                    .animate(CurvedAnimation(
                        curve: theme.curve, parent: controller)),
                child: Text(
                  widget.text,
                  style: theme.h1,
                ),
              ),
              offset: Duration(milliseconds: 200),
              popOffset: Duration(milliseconds: 100),
            )
          ],
        ),
      ),
    );
  }
}
