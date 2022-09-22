import 'package:agora_video/extensions/app_extensions.dart';
import 'package:agora_video/screens/stream/stream_page.dart';
import 'package:agora_video/utils/app_colors.dart';
import 'package:agora_video/utils/app_extras.dart';
import 'package:agora_video/utils/app_methods.dart';
import 'package:agora_video/utils/app_strings.dart';
import 'package:agora_video/widgets/network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ViewEventsTab extends StatefulWidget {
  const ViewEventsTab({
    Key? key,
  }) : super(key: key);

  @override
  State<ViewEventsTab> createState() => _ViewEventsTabState();
}

class _ViewEventsTabState extends State<ViewEventsTab> {
  Future<void> _onPullRefresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return buildEventCards();
  }

  Widget buildEventCards() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: RefreshIndicator(
        onRefresh: _onPullRefresh,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("broadcasts")
              .doc(AppMethods.getUid()!)
              .collection("events")
              .orderBy("date_time")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data?.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return buildEventCard(
                    context: context,
                    data: snapshot.data?.docs[index],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: " + snapshot.error.toString()),
              );
            }
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          },
        ),
      ),
    );
  }

  Widget buildEventCard({
    required BuildContext context,
    QueryDocumentSnapshot? data,
  }) {
    DateTime date = data?['date_time'].toDate();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 2.0,
            spreadRadius: 0.0,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: SizedBox(
        height: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImage(data!),
            buildEventDetails(data, date, context),
          ],
        ),
      ),
    );
  }

  Widget buildEventDetails(
    QueryDocumentSnapshot<Object?> data,
    DateTime date,
    BuildContext context,
  ) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildEventName(data),
          const Divider(),
          buildTimeAndButton(date, context, data),
        ],
      ),
    );
  }

  Widget buildTimeAndButton(
    DateTime date,
    BuildContext context,
    QueryDocumentSnapshot<Object?> data,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildDateAndTime(date),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildStarButton(context, date, data),
                AppMethods.calculateDifference(date) < 0
                    ? Container()
                    : buildShareButton(context, data['event_link']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStarButton(
    BuildContext context,
    DateTime date,
    QueryDocumentSnapshot<Object?> data,
  ) {
    return AppMethods.calculateDifference(date) == 0
        ? buildStartButton(context, data)
        : AppMethods.calculateDifference(date) >= 1
            ? buildUpcomingText()
            : buildCompletedText();
  }

  Widget buildStartButton(
      BuildContext context, QueryDocumentSnapshot<Object?> data) {
    return ElevatedButton(
      onPressed: () async {
        if (await Permission.camera.isGranted &&
            await Permission.microphone.isGranted) {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => StreamPage(
                channelName: data['channel_name'],
                isBroadcaster: true,
                guideName: data['guide_name'],
                description: data['description'],
                eventName: data['event_name'],
                link: data['event_link'],
                imageLink: data['image_link'] ?? AppStrings.defaultImageUrl,
              ),
            ),
          );
        } else {
          await Permission.camera.request();
          await Permission.microphone.request();
        }
      },
      style: ElevatedButton.styleFrom(
        primary: AppColors.primaryColor,
      ),
      child: Text(
        AppStrings.startButton,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildShareButton(BuildContext context, String link) {
    return IconButton(
      onPressed: () => AppExtras.showLinkDialog(context, link),
      icon: const Icon(Icons.share),
    );
  }

  Widget buildCompletedText() {
    return Text(
      AppStrings.eventComplete,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget buildUpcomingText() {
    return Text(
      AppStrings.eventUpcoming,
      style: TextStyle(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget buildStartSoonText() {
    return Text(
      AppStrings.eventSoon,
      style: TextStyle(
        color: AppColors.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  Widget buildDateAndTime(DateTime date) {
    return Text(
      date.toLocalDate() + " @" + date.toLocalTime(),
      style: const TextStyle(
        color: Colors.black54,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  Widget buildEventName(QueryDocumentSnapshot<Object?> data) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
      child: Text(
        data['event_name'],
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget buildImage(QueryDocumentSnapshot<Object?> data) {
    return Expanded(
      flex: 4,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: ImageFromNetwork(
          imageLink: data['image_link'] ?? AppStrings.defaultImageUrl,
        ),
      ),
    );
  }
}
