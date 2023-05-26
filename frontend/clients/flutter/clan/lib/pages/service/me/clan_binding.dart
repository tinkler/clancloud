import 'package:Clan/widgets/clan_tree.dart';
import 'package:flutter/material.dart';

import '../../../api/model/clans/clan.dart';

class ClanBinding extends StatefulWidget {
  const ClanBinding({super.key});

  @override
  State<ClanBinding> createState() => _ClanBindingState();
}

class _ClanBindingState extends State<ClanBinding> {
  Member _member = Member();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('族谱绑定'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: ClanTree(_member, onTap: (m) {
                    return 0;
                  }),
                ),
              ),
            )),
            _BindingInput(
              onChange: (m) async {
                if (m != _member) {
                  _member = m;
                }
                if (_member.id != 0) {
                  var u = User();
                  await u.load();
                  if (u.id.isNotEmpty) {
                    u.memberId = _member.id;
                    await u.save();
                  }
                }
                setState(() {});
              },
              member: _member,
            )
          ],
        ),
      ),
    );
  }
}

enum _InputStep {
  MyName,
  FatherName,
  GrandFatherName,
  Sumit,
  Pedding,
}

class _BindingInput extends StatefulWidget {
  final ValueChanged<Member> onChange;
  final Member member;
  final _InputStep step;
  _BindingInput(
      {required this.onChange,
      required this.member,
      this.step = _InputStep.MyName});

  @override
  State<_BindingInput> createState() => __BindingInputState();
}

class __BindingInputState extends State<_BindingInput> {
  late _InputStep _step;
  late Member _member;
  bool _found = false;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _step = widget.step;
    _member = widget.member;
  }

  @override
  Widget build(BuildContext context) {
    switch (_step) {
      case _InputStep.MyName:
        return _NameInput(
            hintText: '我的名字',
            btnText: '保存我的名字',
            onChange: (name) {
              _member.name = name;
              widget.onChange(_member);
              _step = _InputStep.FatherName;
            },
            name: _member.name);
      case _InputStep.FatherName:
        return _NameInput(
            hintText: '父亲名字',
            btnText: '保存父亲名字',
            onBack: () {
              _step = _InputStep.MyName;
              setState(() {});
            },
            onChange: _searching
                ? null
                : (name) async {
                    _member.father ??= Member()..name = name;
                    _searching = true;
                    widget.onChange(_member);
                    var req = Member();
                    var res = await req.searchMember(
                        '${_member.name} ${_member.father!.name}');
                    if (res.length == 1) {
                      _found = true;
                      var resMember = res[0];
                      await resMember.getById(3, 1);
                      for (var m in resMember.children) {
                        if (m.name == _member.name) {
                          m.father = resMember;
                          m.father!.children = [];
                          _member = m;
                          break;
                        }
                      }
                      widget.onChange(_member);
                      _step = _InputStep.Sumit;
                      return;
                    }
                    _searching = false;
                    widget.onChange(_member);
                    _step = _InputStep.GrandFatherName;
                  },
            name: _member.father?.name ?? '');
      case _InputStep.GrandFatherName:
        return _NameInput(
          hintText: '祖父名字',
          btnText: '保存祖父名字',
          onBack: () {
            _step = _InputStep.FatherName;
            setState(() {});
          },
          onChange: _searching
              ? null
              : (name) async {
                  _member.father!.father ??= Member()..name = name;
                  _searching = true;
                  widget.onChange(_member);
                  var req = Member();
                  var res = await req.searchMember(
                      '${_member.name} ${_member.father!.name} ${_member.father!.father!.name}');
                  if (res.length == 1) {
                    _found = true;
                    _member = res[0];
                    await _member.getById(3, 1);
                    _searching = false;
                    widget.onChange(_member);
                    _step = _InputStep.Sumit;
                    return;
                  }
                  _searching = false;
                  widget.onChange(_member);
                  _step = _InputStep.Sumit;
                },
          name: _member.father!.father?.name ?? '',
        );
      default:
        return Container();
    }
  }
}

class _NameInput extends StatefulWidget {
  final String hintText;
  final String btnText;
  final TextEditingController _controller = TextEditingController();
  final String name;
  final ValueChanged<String>? onChange;
  final VoidCallback? onBack;
  _NameInput(
      {required this.hintText,
      required this.btnText,
      required this.onChange,
      required this.name,
      this.onBack});
  @override
  _NameInputState createState() {
    return _NameInputState();
  }
}

class _NameInputState extends State<_NameInput> {
  String _errMsg = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  decoration: InputDecoration(hintText: widget.hintText),
                  controller: widget._controller,
                ),
              ),
              ElevatedButton(
                onPressed: widget.onChange == null
                    ? null
                    : () {
                        String value = widget._controller.value.text;
                        if (value == '') {
                          setState(() {
                            _errMsg = '名字不能为空';
                          });
                          return;
                        }
                        widget.onChange!(value);
                      },
                child: Text(widget.btnText),
              ),
              widget.onBack != null
                  ? ElevatedButton(
                      onPressed: widget.onChange == null ? null : widget.onBack,
                      child: const Text('返回'))
                  : Container()
            ],
          ),
          Container(
            child: _errMsg == ''
                ? null
                : Text(_errMsg,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary)),
          ),
        ],
      ),
    );
  }
}
