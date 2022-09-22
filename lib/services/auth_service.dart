import 'package:agora_video/models/app_user.dart';

abstract class AuthService{
  Future<AppUser> currentUser();

  Future<void> signOut();

  void setAppUser(AppUser user);

  AppUser? getAppUser();

  Stream<AppUser> get onAuthStateChanged;

  void dispose();

  Future<String> googleLogin();

}