import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../services/firebase_auth.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_extras.dart';
import '../../utils/app_methods.dart';
import '../../utils/app_strings.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _service = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPrefs();
  }

  Future<void> _initializeSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _handleAgentSignIn(BuildContext context) async {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      AppExtras.showLoaderDialog(
          context: context, text: AppStrings.loaderLoggingIn);
      await _service
          .signIn(
              email: _emailController.text, password: _passwordController.text)
          .then((value) async {
        if (value == "Success") {
          await AppMethods.setUserTypePrefs(prefs: _prefs, isAgent: true);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AgoraVideo(),
            ),
          );
        } else {
          Navigator.of(context).pop();
          AppExtras.showLoaderDialog(
            context: context,
            text: value,
            isLoading: false,
            isBarrierDismissible: true,
          );
        }
      });
    }
  }

  Future<void> _handleUserSignIn(BuildContext context) async {
    try {
      await _service.googleLogin().then((value) async {
        await AppMethods.setUserTypePrefs(prefs: _prefs, isAgent: false);
        await AppMethods.addUserToFirebase(value);
      });
    } catch (e) {
      AppExtras.showLoaderDialog(
        context: context,
        text: e.toString(),
        isLoading: false,
        isBarrierDismissible: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(top: 42, left: 22, right: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTitleText(),
              const SizedBox(height: 32),
              buildExperienceText(),
              buildBottomSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBottomSection(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildLetsGoText(),
              const SizedBox(height: 12),
              buildGetStartedButton(context),
              buildAgentButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAgentButton(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () => showAgentLoginSheet(context),
        child: Text(
          AppStrings.textAgent,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black54,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        onPressed: () => _handleUserSignIn(context),
        text: AppStrings.getStartedButton,
      ),
    );
  }

  Widget buildLetsGoText() {
    return Text(
      AppStrings.letsGo,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 22,
      ),
    );
  }

  Widget buildExperienceText() {
    return Text(
      AppStrings.startExperience,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
      ),
    );
  }

  Widget buildTitleText() {
    return Text(
      AppStrings.appName,
      style: TextStyle(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 36,
      ),
    );
  }

  void showAgentLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      builder: (context) {
        return buildContent(context);
      },
    );
  }

  Padding buildContent(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(22),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildLoginText(),
            buildEmailField(),
            buildPasswordField(),
            buildLoginButton(context),
          ],
        ),
      ),
    );
  }

  SizedBox buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: AppStrings.loginButton,
        onPressed: () => _handleAgentSignIn(context),
      ),
    );
  }

  Widget buildPasswordField() {
    return CustomTextField(
      hintText: AppStrings.textPassword,
      obscureText: true,
      autoCorrect: false,
      enableSuggestions: false,
      controller: _passwordController,
      minLines: 1,
      maxLines: 1,
    );
  }

  Widget buildEmailField() {
    return CustomTextField(
      hintText: AppStrings.textEmail,
      controller: _emailController,
    );
  }

  Widget buildLoginText() {
    return Text(
      AppStrings.textLogin,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 22,
      ),
    );
  }
}
