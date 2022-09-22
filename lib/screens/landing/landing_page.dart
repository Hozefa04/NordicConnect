import 'package:agora_video/screens/details_page/stream_details.dart';
import 'package:agora_video/screens/home/home_page.dart';
import 'package:agora_video/screens/landing/bloc/landing_bloc.dart';
import 'package:agora_video/screens/login/login_page.dart';
import 'package:agora_video/utils/app_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LandingPage extends StatefulWidget {
  final bool isLinkClicked;
  final DocumentSnapshot? doc;

  const LandingPage({Key? key, this.isLinkClicked = false, this.doc})
      : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    _checkLinkClick();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LandingPage oldWidget) {
    _checkLinkClick();
    super.didUpdateWidget(oldWidget);
  }

  void _checkLinkClick() {
    if (widget.isLinkClicked && AppMethods.getUid() != null) {
      if (kDebugMode) {
        print("Called link event");
      }
      BlocProvider.of<LandingBloc>(context).add(LinkClickEvent(widget.doc!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.hasData) {
          return BlocConsumer<LandingBloc, LandingState>(
            listener: (context, state) {
              if (state is LinkClickState) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => StreamDetails(
                      channelName: state.doc['channel_name'],
                      isBroadcaster: false,
                      guideName: state.doc['guide_name'],
                      description: state.doc['description'],
                      eventName: state.doc['event_name'],
                      date: state.doc['date_time'].toDate(),
                      imageLink: state.doc['image_link'],
                    ),
                  ),
                );
              }
            },
            buildWhen: (previous, current) {
              if (current is LinkClickState) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              return const HomePage();
            },
          );
        }
        return const LoginPage();
      },
    );
  }
}
