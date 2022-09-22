import 'package:agora_video/extensions/app_extensions.dart';
import 'package:agora_video/screens/stream/stream_page.dart';
import 'package:agora_video/utils/app_colors.dart';
import 'package:agora_video/utils/app_methods.dart';
import 'package:agora_video/utils/app_strings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StreamDetails extends StatelessWidget {
  final String channelName;
  final String description;
  final String eventName;
  final String guideName;
  final bool isBroadcaster;
  final String? imageLink;
  final DateTime date;
  const StreamDetails({
    Key? key,
    required this.channelName,
    required this.description,
    required this.eventName,
    required this.guideName,
    required this.isBroadcaster,
    required this.imageLink,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedNetworkImage(
        imageUrl: imageLink ?? AppStrings.defaultImageUrl,
        errorWidget: (context, url, error) => const Icon(Icons.error),
        placeholder: (context, url) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        },
        imageBuilder: (context, imageProvider) {
          return Stack(
            children: [
              buildBackgroundImage(imageProvider),
              buildOverlay(),
              buildEventDetails(context),
            ],
          );
        },
      ),
    );
  }

  Widget buildEventDetails(BuildContext context) {
    return Positioned(
      bottom: 22,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildEventName(context),
            const SizedBox(height: 12),
            buildEventDescription(context),
            const SizedBox(height: 12),
            buildDateTime(context),
            const SizedBox(height: 12),
            buildGuideName(context),
            const SizedBox(height: 32),
            buildJoinWidget(context),
          ],
        ),
      ),
    );
  }

  Widget buildOverlay() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        backgroundBlendMode: BlendMode.darken,
        color: Colors.black26,
      ),
    );
  }

  Widget buildBackgroundImage(ImageProvider<Object> imageProvider) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget buildEventName(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Text(
        eventName,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildEventDescription(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Text(
        description,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget buildGuideName(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Text(
        "Hosted by: " + guideName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget buildDateTime(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Text(
        "Event starts on: " + date.toLocalDate() + " @" + date.toLocalTime(),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget buildJoinWidget(BuildContext context) {
    return AppMethods.calculateDifference(date) == 0
        ? AppMethods.isEventNow(date)
            ? ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => StreamPage(
                        channelName: channelName,
                        isBroadcaster: false,
                        guideName: guideName,
                        description: description,
                        eventName: eventName,
                        imageLink: imageLink ?? AppStrings.defaultImageUrl,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 22),
                ),
                child: Text(
                  AppStrings.joinButton,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              )
            : buildStartSoonText()
        : AppMethods.calculateDifference(date) >= 1
            ? Text(
                AppStrings.eventNotStarted,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              )
            : Text(
                AppStrings.eventCompleted,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              );
  }

  Widget buildStartSoonText() {
    return Text(
      AppStrings.eventSoon,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );
  }
}
