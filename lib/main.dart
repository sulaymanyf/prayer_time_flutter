import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/colors.dart';
import 'package:flutter_app/main_menu/main_menu.dart';
import 'bloc_provider.dart';

class TimelineApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return BlocProvider(

      child: MaterialApp(
        debugShowCheckedModeBanner:false,
        title: 'Prayer Times Assistant',
        theme: ThemeData(
            backgroundColor: background, scaffoldBackgroundColor: background),
        home: MenuPage(),
      ),
      platform: Theme.of(context).platform,
    );
  }
}

class MenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null, body: MainMenuWidget());
  }
}

void main() => runApp(TimelineApp());