import 'package:agora_video/utils/app_colors.dart';
import 'package:agora_video/utils/app_methods.dart';
import 'package:agora_video/utils/app_strings.dart';
import 'package:agora_video/widgets/app_drawer.dart';
import 'package:agora_video/widgets/appbar.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(hasTabs: false),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 42, left: 22, right: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTitleText(),
                buildUsernameText(),
                const SizedBox(height: 32),
                buildExperienceText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildExperienceText() {
    return Text(
      AppStrings.linkText,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
    );
  }

  Widget buildTitleText() {
    return Text(
      AppStrings.welcome,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
    );
  }

  Widget buildUsernameText() {
    return Text(
      AppMethods.getUsername()!,
      style: TextStyle(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 36,
      ),
    );
  }
}
