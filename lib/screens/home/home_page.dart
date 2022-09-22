import 'package:flutter/material.dart';

import '../../utils/app_methods.dart';
import '../../utils/late_class.dart';
import '../../widgets/loading.dart';
import 'agent_home/agent_home.dart';
import 'user_home/user_home.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Late<bool> isAgent = Late();

  @override
  void initState() {
    _checkUserType();
    super.initState();
  }

  Future<void> _checkUserType() async {
    isAgent.val = await AppMethods.checkUserType();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isAgent.isInitialized
        ? isAgent.val == true
            ? const AgentHomePage()
            : const UserHomePage()
        : const LoadingWidget();
  }
}
