import 'package:Clan/api/model/clans/clan.dart';
import 'package:Clan/providers/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProvider extends StatefulWidget {
  final Widget? child;
  final TransitionBuilder? builder;
  const UserProvider({super.key, this.child, this.builder})
      : assert(child != null || builder != null,
            'child or builder must be provided');

  @override
  State<UserProvider> createState() => _UserProviderState();

  static UserModel of(BuildContext context) {
    return Provider.of<UserModel>(context, listen: false);
  }
}

class _UserProviderState extends State<UserProvider> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (context) => UserModel(User()),
      builder: widget.builder,
      child: widget.child,
    );
  }
}
