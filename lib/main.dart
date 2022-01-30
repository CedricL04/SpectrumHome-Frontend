import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spectrum_home2/dataObjects/setting.dart';
import 'package:spectrum_home2/eventsystem.dart';
import 'package:spectrum_home2/guis/gui_enter_ip.dart';
import 'package:spectrum_home2/navigation_base.dart';
import 'package:spectrum_home2/pages/room_page.dart';
import 'package:spectrum_home2/server.dart';
import 'package:spectrum_home2/settings/color_setting_gui.dart';
import 'package:spectrum_home2/settings/gradient_setting_gui.dart';
import 'package:spectrum_home2/utils/hero_dialog_route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  load().then((e) => runApp(App()));
}

Color backgroundColor = Color(0xff121212);
Color? backgroundColorDark = Color.lerp(Colors.black, backgroundColor, .8);
Color foregroundColor = Colors.white;
Color elevation1 = Color(0xff191919);
Color elevation2 = Color(0xff292929);
Color shadowColor = Color(0xff101010);

List<BoxShadow> elevation1shadow = [
  BoxShadow(blurRadius: 10, color: shadowColor)
];

TextStyle h1 = TextStyle(fontWeight: FontWeight.w300, fontSize: 30);
TextStyle h2 = TextStyle(fontWeight: FontWeight.w300, fontSize: 25);
TextStyle h3 = TextStyle(fontWeight: FontWeight.w300, fontSize: 20);
TextStyle h4 = TextStyle(fontWeight: FontWeight.w300, fontSize: 17);

Radius radius = Radius.circular(15);
BorderRadius borderRadius = BorderRadius.all(radius);

Curve curve = Curves.easeInOut;

EventSystem system = new EventSystem();
late SharedPreferences prefs;

Future load() async {
  prefs = await SharedPreferences.getInstance();
}

Server server = new Server();

//temp
// List<Device> devices = [
//   Device("Hexagon", ["color", "gradient", "animation"], Colors.red),
//   Device("Shelf", ["color"], Colors.purple),
//   Device("Table", ["color", "gradient"], Colors.green),
//   Device("Bed", ["gradient", "animation"], Colors.blue),
// ];

//temp
List<Setting> settings = [
  Setting("color", Icons.color_lens, (s, d) => ColorSettingGui(s, d)),
  Setting("gradient", Icons.gradient, (s, d) => GradientSettingGui(s, d)),
  Setting("animation", Icons.animation, (s, d) => Container())
];

bool isSmall(BuildContext context) {
  return MediaQuery.of(context).size.width < 700;
}

InputDecoration getTextFieldStyle(BuildContext context,
    {String? labelName, Widget? icon, bool filled = false}) {
  return InputDecoration(
      suffixIcon: icon,
      isDense: true,
      fillColor: Colors.white,
      // contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide:
              BorderSide(width: 2, color: foregroundColor.withOpacity(.8))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide:
              BorderSide(width: 2, color: foregroundColor.withOpacity(.5))),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      labelText: labelName ?? "Name",
      labelStyle: TextStyle(color: foregroundColor.withOpacity(.5)));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus!.unfocus();
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: backgroundColor,
            colorScheme: ColorScheme.dark(secondary: Colors.deepOrange)),
        home: GuiEnterIp(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //todo: minimize app kek
        return false;
      },
      child: NavigationBase(
        pages: [
          NavigationEntry("Rooms", Icons.home_outlined, RoomPage()),
          NavigationEntry("Dashboard", Icons.dashboard_outlined, Container()),
          NavigationEntry("Settings", Icons.settings_outlined, Container())
        ],
        backAction: () =>
            Navigator.pushReplacement(context, new HeroDialogRoute(
          builder: (context) {
            prefs.setBool("autoconnect", false);
            return GuiEnterIp();
          },
        )),
      ),
    );
  }
}
