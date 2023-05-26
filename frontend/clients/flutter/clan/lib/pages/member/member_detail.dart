import 'package:Clan/api/model/clans/clan.dart';
import 'package:flutter/material.dart';

class MemberDetailPage extends StatefulWidget {
  final Member member;
  const MemberDetailPage({super.key, required this.member});

  static const routeName = '/member/detail';

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.member.name),
      ),
    );
  }
}
