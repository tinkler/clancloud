import 'dart:async';

import 'package:Clan/providers/user_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../api/model/mqtt/user.dart';
import '../../const/hive.dart';
import '../home/home_page.dart';
import '../signin/signin_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String _message = '加载网络中...';
  bool _loading = false;
  String? _error;

  Widget _getContent() {
    if (_error != null) return Text(_error!);
    return Text(_message);
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      _error = 'Couldn\'t check connectivity status';
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    // if (!mounted) {
    //   return Future.value(null);
    // }

    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) async {
    if (_loading) {
      return;
    }
    _loading = true;
    if (result == ConnectivityResult.none) {
      setState(() {
        _error = '没有网络连接';
      });
    }
    var sysBox = await Hive.openBox<String>(boxSys);
    var token = sysBox.get(boxValSysToken);
    var deviceToken = sysBox.get(boxValSysDeviceToken);
    if (deviceToken != null &&
        deviceToken.isNotEmpty &&
        token != null &&
        token.isNotEmpty) {
      var auth = Auth()
        ..deviceToken = deviceToken
        ..token = token;
      try {
        await auth.quickSignin();
        await Hive.openBox<String>(boxSys).then((value) {
          value.put(boxValSysToken, auth.token);
          value.put(boxValSysDeviceToken, auth.deviceToken);
        });
        _loading = false;
        toHome();
        return;
      } catch (e) {
        print(e);
      }
    }
    _loading = false;
    toSigin();
  }

  toHome() {
    UserProvider.of(context).setSignedIn(true).then((value) {
      Navigator.pushReplacementNamed(context, HomePage.routeName);
    }, onError: (e) {
      toSigin();
    });
  }

  toSigin() {
    UserProvider.of(context).setSignedIn(false).then((value) {
      Navigator.pushReplacementNamed(context, SigninPage.routeName);
    });
  }

  Future<void> _init() async {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SizedBox(
          width: 200,
          height: 100,
          child: Column(
            children: <Widget>[
              const Text('欢迎访问覃氏族谱'),
              const Spacer(),
              const CircularProgressIndicator(),
              const Spacer(),
              _getContent(),
            ],
          )),
    ));
  }
}
