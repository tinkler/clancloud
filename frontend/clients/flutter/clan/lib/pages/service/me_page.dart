import 'package:Clan/api/model/clans/clan.dart';
import 'package:Clan/const/hive.dart';
import 'package:Clan/providers/user_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../signin/signin_page.dart';
import 'me/clan_binding.dart';
import 'me/my_clan_tree.dart';

class MePage extends StatefulWidget {
  const MePage({super.key});

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  // User _user = User();

  // Future<void> _loadUser() async {
  //   var user = $mqttUser.User();
  //   await user.get();
  //   var clanUser = User()
  //     ..id = user.id
  //     ..username = user.username;
  //   await clanUser.load();
  //   setState(() {
  //     _user = clanUser;
  //   });
  // }

  _onLogout(BuildContext context) {
    var box = Hive.box<String>(boxSys);
    box.delete(boxValSysToken);
    box.close();
    Navigator.of(context).pushNamedAndRemoveUntil(
        SigninPage.routeName, (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();
    // _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: model.user.id.isEmpty
                    ? const CircularProgressIndicator()
                    : _UserInfoCard(
                        user: model.user,
                      ),
              ),
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  children: [
                    model.canAccess3()
                        ? ListTile(
                            title: const Text('文章管理'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {},
                          )
                        : Container(),
                    model.user.memberId != 0
                        ? ListTile(
                            title: const Text('查看我的族谱'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              var changed =
                                  await Navigator.of(context).pushNamed<bool>(
                                MyClanTree.routeName,
                                arguments: Member()..id = model.user.memberId,
                              );
                              if (changed == true) {
                                model.load();
                              }
                            },
                          )
                        : ListTile(
                            title: const Text('绑定族谱'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () async {
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return const ClanBinding();
                              }));
                              model.load();
                            },
                          ),
                    ListTile(
                      trailing: const Icon(Icons.logout),
                      title: const Text('退出登录'),
                      onTap: () {
                        _onLogout(context);
                      },
                    )
                  ],
                ),
              ))
            ],
          ),
        );
      },
    );
  }
}

class ClanPage {}

class _UserInfoCard extends StatelessWidget {
  final User user;
  const _UserInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.person,
          size: 56,
        ),
        Text(user.username),
      ],
    );
  }
}
