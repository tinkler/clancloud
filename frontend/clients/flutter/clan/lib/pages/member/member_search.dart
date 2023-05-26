import 'package:Clan/api/model/clans/clan.dart';
import 'package:Clan/api/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../widgets/clan_tree.dart';
import 'member_view.dart';

class MemberSearchPage extends StatefulWidget {
  const MemberSearchPage({super.key});

  @override
  State<MemberSearchPage> createState() => _MemberSearchPageState();
}

class _MemberSearchPageState extends State<MemberSearchPage> {
  Future<Member> _getMember() async {
    Member req = Member()..id = _currentMemberId;
    await req.getById(-1, 3);
    return req;
  }

  int _currentMemberId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: TypeAheadFormField<Member>(
            textFieldConfiguration: const TextFieldConfiguration(
              autofocus: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '子 父',
              ),
            ),
            suggestionsCallback: (pattern) async {
              var req = Member();
              return req.searchMember(pattern);
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                leading: Text(suggestion.surname),
                title: Text(suggestion.name),
                subtitle: suggestion.father != null
                    ? Text(suggestion.father!.name)
                    : null,
                onTap: () {
                  setState(() {
                    _currentMemberId = suggestion.id;
                  });
                },
              );
            },
            onSuggestionSelected: (suggestion) {},
            noItemsFoundBuilder: (context) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '没有相关族谱信息!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).disabledColor, fontSize: 18.0),
                ),
              );
            },
          )),
      body: _currentMemberId == 0
          ? Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/bgImage.png'),
                fit: BoxFit.cover,
              )),
            )
          : Container(
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
                            if (snapshot.hasData) {
                              return ClanTree(
                                snapshot.data!,
                                onTap: (m) async {
                                  int? id = await Navigator.of(context)
                                      .push<int>(
                                          MaterialPageRoute(builder: (context) {
                                    return MemberViewPage(member: m);
                                  }));
                                  if (id != null) {
                                    setState(() {
                                      _currentMemberId = id;
                                    });
                                  }
                                },
                              );
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            } else {
                              return const CircularProgressIndicator();
                            }
                          })),
                ),
              ),
            ),
    );
  }
}
