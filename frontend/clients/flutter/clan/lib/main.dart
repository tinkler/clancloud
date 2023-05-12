import 'package:Clan/const/text.dart';
import 'package:Clan/pages/home/home_page.dart';
import 'package:Clan/pages/service/diagram/diagram.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: FToastBuilder(),
      debugShowCheckedModeBanner: false,
      title: userAgreementMain,
      home: const HomePage(),
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 159, 112, 0),
          )),
      routes: {
        '/service/diagram': (context) {
          return const DiagramPage();
        }
      },
    );
  }
}
