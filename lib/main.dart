// import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/Widgets/HomePage.dart';
import 'package:pokedex/Widgets/News.dart';
import 'package:pokedex/Widgets/Search.dart';
import 'package:pokedex/Widgets/Generations.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeDex',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        // primarySwatch: Colors.red,
        colorScheme: ColorScheme(outlineVariant: Colors.red, scrim: Colors.red, background: Colors.red, brightness: Brightness.light, primary: Colors.white, secondary: Colors.redAccent, error: Colors.redAccent, onSecondary: Colors.green, onBackground: Color.fromRGBO(99, 118, 184, 1), surface: Colors.red, onError: Colors.redAccent, onSurface: Colors.white, onPrimary: Colors.white,),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(title: 'PokeDex',),
        '/search': (context) => Search(),
        '/generations': (context) => Generations(),
        '/news': (context) => News(),
        // When navigating to the "/second" route, build the SecondScreen widget.
      },

    );
  }
}

class Home extends StatefulWidget {

  const Home({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 0;

  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      primary: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
        child: Center(
          child: _getPage(currentPage),
        ),
      ),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(
              iconData: Icons.home,
              title: "Home",
              onclick: () {
                final FancyBottomNavigationState fState = bottomNavigationKey
                    .currentState as FancyBottomNavigationState;
                fState.setPage(2);
              }),
          TabData(
              iconData: Icons.search,
              title: "Search",
              onclick: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Search()))),
          TabData(
              iconData: Icons.category,
              title: "Generations",
              onclick: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Generations()))),
          TabData(
              iconData: Icons.newspaper,
              title: "News",
              onclick: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const News()))),
        ],
        activeIconColor: Theme.of(context).colorScheme.secondary,
        inactiveIconColor: Theme.of(context).colorScheme.primary,
        circleColor: Theme.of(context).colorScheme.primary,
        barBackgroundColor: Theme.of(context).colorScheme.background,
        initialSelection: 0,
        key: bottomNavigationKey,
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
      ),
    );
  }

  _getPage(int page) {
    switch (page) {
      case 0:
        return Column(
          children: <Widget>[
            HomePage(),
          ],
        );
      case 1:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
           Search(),
          ],
        );
      case 2:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Generations(),
          ],
        );
      default:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            News(),
          ],
        );
    }
  }
}