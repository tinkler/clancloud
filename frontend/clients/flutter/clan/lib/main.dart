import 'dart:io';

import 'package:Clan/const/text.dart';
import 'package:Clan/pages/home/home_page.dart';
import 'package:Clan/pages/member/member_detail.dart';
import 'package:Clan/pages/service/diagram/diagram.dart';
import 'package:Clan/pages/service/service_page.dart';
import 'package:Clan/pages/signin/signin_page.dart';
import 'package:Clan/pages/signup_page/signup_page.dart';
import 'package:Clan/pages/welcome/welcome_page.dart';
import 'package:Clan/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';

import 'api/http.dart';
import 'api/model/clans/clan.dart';

void main() async {
  var path = '${Directory.current.path}/hive_data/';
  Hive.init(path);
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  D.instance.initErrorInterceptor(navigatorKey);
  runApp(MainApp(navigatorKey: navigatorKey));
}

class MainApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  const MainApp({super.key, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return UserProvider(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        builder: FToastBuilder(),
        debugShowCheckedModeBanner: false,
        title: userAgreementMain,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff801C1C)),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xffa7535a),
              titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            )),
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) {
            switch (settings.name) {
              case DiagramPage.routeName:
                return const DiagramPage();
              case ServicePage.routeName:
                return const ServicePage();
              case SigninPage.routeName:
                return const SigninPage();
              case SignupPage.routeName:
                return const SignupPage();
              case HomePage.routeName:
                return const HomePage();
              case MemberDetailPage.routeName:
                if (settings.arguments is Member) {
                  return MemberDetailPage(member: settings.arguments as Member);
                }
                throw Exception('MemberDetailPage arguments is not Member');
              default:
                return const WelcomePage();
            }
          });
        },
      ),
    );
  }
}
