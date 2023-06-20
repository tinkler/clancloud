import 'package:Clan/api/model/clans/clan.dart';
import 'package:Clan/pages/member/member_search.dart';
import 'package:Clan/widgets/clan_tree.dart';
import 'package:flutter/material.dart';

import '../../member/member_view.dart';

class DiagramPage extends StatefulWidget {
  const DiagramPage({super.key});

  static const String routeName = '/service/diagram';

  @override
  State<DiagramPage> createState() => _DiagramPageState();
}

class _DiagramPageState extends State<DiagramPage> {
  static int rootMemberId = 138789;
  int _currentMemberId = rootMemberId;

  Future<Member> _getMember() async {
    Member req = Member()..id = _currentMemberId;
    await req.getById(-1, 3);
    return req;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('吊线图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const MemberSearchPage();
              }));
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bgImage.png'),
            fit: BoxFit.cover,
          ),
        ),
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
                    future: _getMember(),
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
                                int? id = await Navigator.of(context).push<int>(
                                    MaterialPageRoute(builder: (context) {
                                  return MemberViewPage(member: m);
                                }));
                                if (id != null) {
                                  if (id == 0) {
                                    id = rootMemberId;
                                  }
                                  setState(() {
                                    _currentMemberId = id!;
                                  });
                                }
                                return null;
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
    );
  }
}
