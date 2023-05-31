import 'dart:async';

import 'package:Clan/api/http_config.dart';
import 'package:Clan/api/model/clans/clan.dart';
import 'package:Clan/pages/member/member_detail.dart';
import 'package:Clan/providers/user_provider.dart';
import 'package:Clan/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MemberViewPage extends StatefulWidget {
  final Member member;
  const MemberViewPage({super.key, required this.member});

  static const routeName = '/member/view';

  @override
  State<MemberViewPage> createState() => _MemberViewPageState();
}

class _MemberViewPageState extends State<MemberViewPage> {
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
    _checkPermission();
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
                    arguments: {'member': widget.member, 'editable': true},
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
                        widget.member.memberProfile?.picPath ?? '',
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
                        CToast.show('请先绑定族谱');
                      }
                    }),
                _Button(
                    buttonText: '追溯定位',
                    onPressed: () {
                      Navigator.of(context).pop<int>(widget.member.id);
                    }),
                _canEdit
                    ? _Button(
                        buttonText: '增加子女',
                        onPressed: () {
                          Member child = Member();
                          child.father = widget.member;
                          Navigator.of(context).pushNamed(
                              MemberDetailPage.routeName,
                              arguments: {'member': child, 'editable': true});
                        })
                    : Container(),
                _canEdit
                    ? _Button(
                        buttonText: '删除该节点',
                        onPressed: () {
                          if (widget.member.id ==
                              UserProvider.of(context).user.memberId) {
                            CToast.show('不能删除自己');

                            return;
                          }
                          if (widget.member.children.isNotEmpty) {
                            CToast.show('该节点有子节点，该权限不能删除');
                            return;
                          }
                          widget.member.delete().then((value) {
                            if (widget.member.id == 0) {
                              UserProvider.of(context).loadEditList().then((e) {
                                Navigator.of(context).pop();
                              });
                            } else {
                              Fluttertoast.showToast(msg: '删除失败');
                            }
                          });
                        })
                    : Container()
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
            image: NetworkImage(basePicUrl + profilePicture),
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

class _Button extends StatefulWidget {
  final String buttonText;
  final VoidCallback onPressed;
  const _Button({required this.buttonText, required this.onPressed});

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  bool _onPressed = false;

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
            onPressed: () async {
              if (_onPressed) {
                return;
              }
              setState(() {
                _onPressed = true;
              });
              widget.onPressed();
              setState(() {
                _onPressed = false;
              });
            },
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _onPressed
                    ? Container(
                        margin: const EdgeInsets.only(right: 10),
                        height: 20,
                        width: 20,
                        child: const CircularProgressIndicator(),
                      )
                    : Container(),
                Text(widget.buttonText)
              ],
            ),
          ),
        ))
      ],
    );
  }
}
