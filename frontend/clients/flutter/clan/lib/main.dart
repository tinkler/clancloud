import 'package:Clan/api/model/memorial/memorial.dart';
import 'package:Clan/const/text.dart';
import 'package:Clan/pages/home/home_page.dart';
import 'package:Clan/pages/member/member_detail.dart';
import 'package:Clan/pages/member/member_view.dart';
import 'package:Clan/pages/service/diagram/diagram.dart';
import 'package:Clan/pages/service/me/my_clan_tree.dart';
import 'package:Clan/pages/service/memorial/memorial_edit.dart';
import 'package:Clan/pages/service/memorial/memorial_page.dart';
import 'package:Clan/pages/service/memorial/memorial_view.dart';
import 'package:Clan/pages/service/service_page.dart';
import 'package:Clan/pages/signin/signin_page.dart';
import 'package:Clan/pages/signup_page/signup_page.dart';
import 'package:Clan/pages/welcome/welcome_page.dart';
import 'package:Clan/providers/user_provider.dart';
import 'package:Clan/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import 'api/http.dart';
import 'api/model/clans/clan.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String directory = '';
  if (!kIsWeb) {
    directory = (await getApplicationDocumentsDirectory()).path;
  }
  var path = '$directory/hive_data/';
  Hive.init(path);
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  D.instance.initErrorInterceptor(navigatorKey);
  CToast.setGlobalKey(navigatorKey);
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
          switch (settings.name) {
            case ServicePage.routeName:
              return MaterialPageRoute(builder: (context) {
                return const ServicePage();
              });
            case DiagramPage.routeName:
              return MaterialPageRoute(builder: (context) {
                return const DiagramPage();
              });
            case MemorialPage.routeName:
              return MaterialPageRoute(builder: (context) {
                return const MemorialPage();
              });
            case MemorialViewPage.routeName:
              if (settings.arguments is Memorial) {
                return MaterialPageRoute(builder: (context) {
                  return MemorialViewPage(
                      memorial: settings.arguments as Memorial);
                });
              }
              throw Exception('MemberDetailPage arguments is not Memorial');
            case MemorialEditPage.routeName:
              if (settings.arguments is Memorial) {
                return MaterialPageRoute(builder: (context) {
                  return MemorialEditPage(
                      memorial: settings.arguments as Memorial);
                });
              }
              throw Exception('MemberEditPage arguments is not Memorial');
            case SigninPage.routeName:
              return MaterialPageRoute(builder: (context) {
                return const SigninPage();
              });
            case SignupPage.routeName:
              return MaterialPageRoute(builder: (context) {
                return const SignupPage();
              });
            case HomePage.routeName:
              return MaterialPageRoute(builder: (context) {
                return const HomePage();
              });
            case MemberDetailPage.routeName:
              return MaterialPageRoute(builder: (context) {
                if (settings.arguments is Member) {
                  return MemberDetailPage(member: settings.arguments as Member);
                } else if (settings.arguments is Map<String, dynamic>) {
                  var args = settings.arguments as Map<String, dynamic>;
                  return MemberDetailPage(
                      member: args['member'] as Member,
                      editable: args['editable'] as bool);
                }
                throw Exception('MemberDetailPage arguments is not Member');
              });
            case MyClanTree.routeName:
              return MaterialPageRoute<bool>(builder: (context) {
                if (settings.arguments is Member) {
                  return MyClanTree(member: settings.arguments as Member);
                }
                throw Exception('MyClanTree arguments is not Member');
              });
            case MemberViewPage.routeName:
              return MaterialPageRoute<int>(builder: (context) {
                if (settings.arguments is Member) {
                  return MemberViewPage(member: settings.arguments as Member);
                }
                throw Exception('MemberViewPage arguments is not Member');
              });
            default:
              return MaterialPageRoute(builder: (context) {
                return const WelcomePage();
              });
          }
        },
      ),
    );
  }
}
