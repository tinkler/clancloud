import 'package:Clan/api/model/clans/clan.dart';
import 'package:flutter/material.dart';

import '../../../widgets/clan_tree.dart';
import '../../member/member_view.dart';

class MyClanTree extends StatefulWidget {
  final Member member;
  const MyClanTree({super.key, required this.member});

  @override
  State<MyClanTree> createState() => _MyClanTreeState();
}

class _MyClanTreeState extends State<MyClanTree> {
  int _currentMemberId = 0;
  bool _unbinding = false;

  Future<Member> _loadMember() async {
    Member req = Member()..id = _currentMemberId;
    await req.getById(-1, -1);
    return req;
  }

  @override
  void initState() {
    super.initState();
    _currentMemberId = widget.member.id;
  }

  _pop(bool changed) {
    Navigator.of(context).pop(changed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的族谱'),
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
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                          minWidth: MediaQuery.of(context).size.width),
                      child: FutureBuilder<Member>(
                          initialData: Member()..name = '中国',
                          future: _loadMember(),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              default:
                                if (snapshot.hasData) {
                                  return ClanTree(
                                    snapshot.data!,
                                    onTap: (m) async {
                                      int? id = await Navigator.of(context)
                                          .push<int>(MaterialPageRoute(
                                              builder: (context) {
                                        return MemberViewPage(member: m);
                                      }));
                                      if (id != null) {
                                        if (id == 0) {
                                          id = widget.member.id;
                                        }
                                        setState(() {
                                          _currentMemberId = id!;
                                        });
                                      }
                                    },
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                } else {
                                  return const CircularProgressIndicator();
                                }
                            }
                          })),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              color: Colors.white,
              child: ElevatedButton(
                  onPressed: _unbinding
                      ? null
                      : () async {
                          setState(() {
                            _unbinding = true;
                          });
                          var u = User();
                          await u.load();
                          if (u.id.isNotEmpty) {
                            u.memberId = 0;
                            await u.save();
                            _pop(true);
                          } else {
                            _pop(false);
                          }
                        },
                  child: _unbinding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('解除绑定')),
            )
          ],
        ),
      ),
    );
  }
}
