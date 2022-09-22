import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'bloc/observer.dart';
import 'screens/landing/bloc/landing_bloc.dart';
import 'screens/landing/landing_page.dart';
import 'utils/app_methods.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  BlocOverrides.runZoned(
    () {
      runApp(const AgoraVideo());
    },
    blocObserver: AppObserver(),
  );
}

class AgoraVideo extends StatefulWidget {
  const AgoraVideo({Key? key}) : super(key: key);

  @override
  State<AgoraVideo> createState() => _AgoraVideoState();
}

class _AgoraVideoState extends State<AgoraVideo> {
  bool isLinkClicked = false;
  DocumentSnapshot? doc;

  @override
  void initState() {
    initBranchSDK();
    //FlutterBranchSdk.validateSDKIntegration();
    super.initState();
  }

  void initBranchSDK() {
    FlutterBranchSdk.initSession().listen((data) {
      if (data.containsKey("+clicked_branch_link") &&
          data["+clicked_branch_link"] == true) {
        //Link clicked. Add logic to get link data

        if (data.containsKey("channel_name")) {
          if (kDebugMode) {
            print('Link channel name: ${data["channel_name"]}');
            print('link user id: ${data["user_id"]}');
          }
          _openLiveStream(data);
        }
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      if (kDebugMode) {
        print(
            'InitSession error: ${platformException.code} - ${platformException.message}');
      }
    });
  }

  Future<void> _openLiveStream(Map<dynamic, dynamic> data) async {
    doc = await AppMethods.getStreamFromFirebase(
      channelName: data["channel_name"],
      userId: data["user_id"],
    );
    isLinkClicked = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LandingBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LandingPage(
          isLinkClicked: isLinkClicked,
          doc: doc,
        ),
      ),
    );
  }
}
