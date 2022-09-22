import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_methods.dart';
import '../../../utils/app_strings.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/appbar.dart';
import '../../stream/stream_page.dart';
import 'tabs/create_event_tab.dart';
import 'tabs/view_event_tab.dart';

class AgentHomePage extends StatefulWidget {
  final String? channelName;
  final String? userId;
  const AgentHomePage({
    Key? key,
    this.channelName,
    this.userId,
  }) : super(key: key);

  @override
  State<AgentHomePage> createState() => _AgentHomePageState();
}

class _AgentHomePageState extends State<AgentHomePage> {
  @override
  void initState() {
    _checkEventFromLink();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _checkEventFromLink();
    super.didChangeDependencies();
  }

  void _checkEventFromLink() {
    if (widget.channelName != null) {
      openLiveStream(widget.channelName!, widget.userId!);
    }
  }

  Future<void> openLiveStream(String channelName, String userId) async {
    DocumentSnapshot? doc = await AppMethods.getStreamFromFirebase(
      channelName: channelName,
      userId: userId,
    );
    if (doc != null) {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => StreamPage(
            channelName: doc['channel_name'],
            description: doc['description'],
            eventName: doc['event_name'],
            guideName: doc['guide_name'],
            imageLink: doc['image_link'] ?? AppStrings.defaultImageUrl,
            isBroadcaster: false,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.channelNotFound),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: HomeAppBar(),
        drawer: const AppDrawer(),
        body: const TabBarView(
          children: [
            CreateEventTab(),
            ViewEventsTab(),
          ],
        ),
      ),
    );
  }
}
