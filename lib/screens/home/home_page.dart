import 'package:agora_video/screens/home/agent_home/agent_home.dart';
import 'package:agora_video/screens/home/user_home/user_home.dart';
import 'package:agora_video/utils/app_methods.dart';
import 'package:agora_video/utils/late_class.dart';
import 'package:agora_video/widgets/loading.dart';
import 'package:flutter/material.dart';

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
