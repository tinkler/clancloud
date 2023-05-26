import 'dart:async';

import 'package:Clan/api/model/clans/clan.dart';
import 'package:Clan/pages/member/member_detail.dart';
import 'package:Clan/providers/user_provider.dart';
import 'package:Clan/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MemberViewPage extends StatefulWidget {
  final Member member;
  const MemberViewPage({super.key, required this.member});

  @override
  State<MemberViewPage> createState() => _MemberViewPageState();
}

class _MemberViewPageState extends State<MemberViewPage> {
  late FToast fToast;

  bool _canEdit = false;

  _checkPermission() async {
    var canEdit = await UserProvider.of(context).canEdit(widget.member.id);
    setState(() {
      _canEdit = canEdit;
    });
  }

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _checkPermission();
  }

  _showToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.redAccent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock),
          const SizedBox(
            width: 12,
          ),
          Text(msg, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('族人信息'),
        actions: [
          if (_canEdit)
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    MemberDetailPage.routeName,
                    arguments: widget.member,
                  );
                },
                icon: const Icon(Icons.edit))
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 15, 15, 15),
            child: Column(
              children: [
                Row(
                  children: [
                    Card(
                      child: _AvatarFutureBuilder(
                        widget.member.profilePicture,
                        sex: widget.member.sex,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MemberField(
                          label: '名字:',
                          value: widget.member.name,
                        ),
                        _MemberField(
                          label: '性别:',
                          value: widget.member.sex == 0
                              ? '保密'
                              : widget.member.sex == 1
                                  ? '男'
                                  : '女',
                        ),
                        _MemberField(
                            label: '配偶姓名:',
                            value: widget.member.spouse != null
                                ? widget.member.spouse!.surname +
                                    widget.member.spouse!.name
                                : '未填写')
                      ],
                    )
                  ],
                ),
                _Button(
                    buttonText: '详细信息',
                    onPressed: () {
                      if (UserProvider.of(context).canAccess4()) {
                        Navigator.of(context).pushNamed(
                            MemberDetailPage.routeName,
                            arguments: widget.member);
                      } else {
                        _showToast('请先绑定族谱');
                      }
                    }),
                _Button(
                    buttonText: '追溯定位',
                    onPressed: () {
                      Navigator.of(context).pop<int>(widget.member.id);
                    }),
                _Button(
                    buttonText: '增加子女',
                    onPressed: () {
                      _showToast('未登录');
                    }),
                _Button(
                    buttonText: '删除改节点',
                    onPressed: () {
                      _showToast('未登录');
                    })
              ],
            ),
          )
        ]),
      ),
    );
  }
}

class _AvatarFutureBuilder extends StatelessWidget {
  final int sex;
  final String profilePicture;
  const _AvatarFutureBuilder(this.profilePicture, {this.sex = 0});

  /// 头像
  Widget _getAvatar(String profilePicture) {
    if (profilePicture.isEmpty) {
      return Container(
        color: Colors.white,
        child: Container(
          height: 120,
          width: 80,
          color: sex == 2 ? const Color(0xffFF9966) : const Color(0xff6699CC),
          child: const Icon(
            Icons.account_circle,
            size: 80,
            color: Colors.white,
          ),
        ),
      );
    }
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          image: DecorationImage(
            image: NetworkImage(profilePicture),
            fit: BoxFit.cover,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getAvatar(profilePicture);
  }
}

class _MemberField extends StatelessWidget {
  final TextStyle textStyle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 18.0, color: Color(0xff333333));
  final String label;
  final String value;
  const _MemberField({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          width: 100.0,
          child: Text(
            label,
            style: textStyle,
            textAlign: TextAlign.right,
          ),
        ),
        Text(
          value,
          style: textStyle,
        )
      ],
    );
  }
}

class _Button extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  const _Button({required this.buttonText, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Container(
          height: 45,
          margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: Text(buttonText),
          ),
        ))
      ],
    );
  }
}
