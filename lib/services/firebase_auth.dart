// ignore_for_file: constant_identifier_names

import 'package:agora_video/models/app_user.dart';
import 'package:agora_video/services/auth_service.dart';
import 'package:agora_video/utils/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:google_sign_in/google_sign_in.dart';

enum AppLogin { FACEBOOK, GOOGLE, EMAIL, APPLE }

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  AppUser? appUser;
  UserCredential? _credential;
  static final FirebaseAuthService _singleton = FirebaseAuthService._internal();

  factory FirebaseAuthService() {
    return _singleton;
  }

  FirebaseAuthService._internal();

  GoogleSignIn googleSignIn = GoogleSignIn(
    signInOption: SignInOption.standard,
    scopes: ['email'],
  );

  @override
  Future<AppUser> currentUser() async {
    return AppUser.fromFirebase(_firebaseAuth.currentUser!);
  }

  @override
  AppUser? getAppUser() {
    return appUser;
  }

  @override
  Stream<AppUser> get onAuthStateChanged => _firebaseAuth
      .authStateChanges()
      .map((event) => AppUser.fromFirebase(event!));

  @override
  void setAppUser(AppUser user) {
    appUser = user;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await googleSignIn.signOut();
    if (googleSignIn.currentUser != null) {
      await googleSignIn.disconnect();
    }
  }

  Future<AppUser> linkAccounts(
      String socialId, String email, OAuthCredential credentialToLink) async {
    _credential = await _credential!.user!.linkWithCredential(credentialToLink);

    if (kDebugMode) {
      print('uid is ' + _credential!.user!.uid);
    }
    return AppUser.fromFirebase(
      _credential!.user!,
      id: socialId,
      logintype: AppLogin.GOOGLE,
    );
  }

  bool isUserLoggedIn() {
    return FirebaseAuthService().appUser!.id != null;
  }

  @override
  void dispose() {}

  @override
  Future<String> googleLogin({
    String? email,
    OAuthCredential? credentialToLink,
  }) async {
    try {
      final account = await googleSignIn.signIn();
      if (account != null) {
        final googleAuth = await account.authentication;
        final googleCredential = GoogleAuthProvider.credential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
        _credential =
            await _firebaseAuth.signInWithCredential(googleCredential);

        if (kDebugMode) {
          print(googleAuth.idToken);
          print('id in firebase auth service' + account.id);
        }

        try {
          await _credential!.user?.updateEmail(account.email);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }

        try {
          if (_credential!.user?.displayName != account.displayName) {
            await _credential?.user!.updateDisplayName(account.displayName);
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }

        return account.email;

        // return AppUser.fromFirebase(
        //   _credential!.user,
        //   id: account.id,
        //   logintype: AppLogin.GOOGLE,
        //   email: account.email,
        //   name: account.displayName,
        //   useUpdatedName: isNameUpdated,
        // );
      } else {
        throw Exception(AppStrings.loginError);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print(stackTrace);
        print('google login--> ${e.toString()}');
      }
      rethrow;
    }
  }

  //SIGN IN Using Email and Password
  Future<String> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }
}
