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

  static showErr(String msg, {Icon? icon, Color? backgroundColor}) {
    if (!_init) init();
    _fToast!.init(_navigatorKey!.currentContext!);
    final iconSet = icon ??
        Icon(
          Icons.build,
          color: Theme.of(_navigatorKey!.currentContext!).primaryColor,
          size: 15,
        );
    final backgroundColorSet = backgroundColor ??
        Theme.of(_navigatorKey!.currentContext!).primaryColor;
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: backgroundColorSet,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconSet,
          const SizedBox(
            width: 12,
          ),
          Text(
            msg,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
          ),
        ],
      ),
    );

    _fToast!.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  static show(String msg,
      {Icon? icon, IconData? iconData, Color? backgroundColor}) {
    assert(
        icon == null || iconData == null, 'only icon or IconData can modify');
    if (!_init) init();
    _fToast!.init(_navigatorKey!.currentContext!);
    final iconSet = icon ??
        Icon(
          iconData ?? Icons.info_outline_rounded,
          color: Colors.white,
          size: 15,
        );
    final backgroundColorSet = backgroundColor ??
        Theme.of(_navigatorKey!.currentContext!).colorScheme.secondary;
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: backgroundColorSet,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconSet,
          const SizedBox(
            width: 12,
          ),
          Text(
            msg,
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
          ),
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
