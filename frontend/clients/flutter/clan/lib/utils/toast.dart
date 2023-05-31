import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CToast {
  static FToast? _fToast;
  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _init = false;

  static setGlobalKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  static init() {
    if (_init) return;
    _fToast = FToast();
    _init = true;
  }

  static show(String msg) {
    if (!_init) init();
    _fToast!.init(_navigatorKey!.currentContext!);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(_navigatorKey!.currentContext!).primaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.build,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(
            width: 12,
          ),
          Text(msg, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );

    _fToast!.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}

class ToastUtil {
  static showInfo(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
    );
  }
}

extension ShowToast on FToast {
  showCustomToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(context!).primaryColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.build,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(
            width: 12,
          ),
          Text(msg, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );

    showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }
}
