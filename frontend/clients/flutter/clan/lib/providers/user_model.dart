import 'package:Clan/api/model/clans/clan.dart';
import 'package:flutter/material.dart';
import 'package:Clan/api/model/mqtt/user.dart' as $mqtt_user;

class UserModel extends ChangeNotifier {
  User _user;

  User get user => _user;

  bool _signedIn = false;

  bool get signedIn => _signedIn;

  final _allowedRoles4 = {
    'clans_level_4',
    'clans_level_3',
    'clans_level_2',
    'admin'
  };
  final _allowedRoles3 = {'clans_level_3', 'clans_level_2', 'admin'};
  final _allowedRoles2 = {'clans_level_2', 'admin'};
  final _allowedRoles1 = {'admin'};

  Set<int> _canEditList = {};

  Future<void> load() async {
    if (!_signedIn) {
      return;
    }
    await _load();
    notifyListeners();
  }

  _load() async {
    var user = $mqtt_user.User();
    await user.get();
    var clanUser = User()
      ..id = user.id
      ..username = user.username;
    await clanUser.load();
    _user = clanUser;
  }

  resetUser() {
    _user = User();
    _signedIn = false;
  }

  Future<void> setSignedIn(bool signedIn) async {
    _signedIn = signedIn;
    if (signedIn) {
      await _load();
    }
  }

  bool canAccess4() {
    return _user.roles.any(_allowedRoles4.contains);
  }

  bool canAccess3() {
    return _user.roles.any(_allowedRoles3.contains);
  }

  bool canAccess2() {
    return _user.roles.any(_allowedRoles2.contains);
  }

  bool canAccess1() {
    return _user.roles.any(_allowedRoles1.contains);
  }

  Future<bool> canEdit(int id) async {
    if (!canAccess4()) {
      return false;
    }
    if (_canEditList.isEmpty && _user.memberId > 0 && _signedIn) {
      await loadEditList();
    }
    return _canEditList.contains(id);
  }

  Future<void> loadEditList() async {
    _canEditList.clear();
    _canEditList.add(_user.memberId);
    var member = Member()..id = _user.memberId;
    await member.getById(3, -1);
    for (var father = member.father; father != null; father = father.father) {
      _canEditList.add(father.id);
    }
    List<Member> children = member.children;
    while (children.isNotEmpty) {
      for (var child in children) {
        _canEditList.add(child.id);
      }
      children = children.expand((element) => element.children).toList();
    }
  }

  UserModel([User? user]) : _user = user ?? User();
}
