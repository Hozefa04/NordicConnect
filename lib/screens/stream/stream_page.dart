import 'dart:io';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote;
import 'package:agora_video/extensions/app_extensions.dart';
import 'package:agora_video/utils/app_extras.dart';
import 'package:agora_video/utils/app_strings.dart';
import 'package:agora_video/widgets/custom_text_field.dart';
import 'package:agora_video/widgets/icon_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:agora_video/utils/app_colors.dart';
import 'package:agora_video/utils/app_id.dart';
import 'package:agora_video/utils/app_methods.dart';
import 'package:wakelock/wakelock.dart';

class StreamPage extends StatefulWidget {
  final String channelName;
  final String eventName;
  final String guideName;
  final String description;
  final bool isBroadcaster;
  final String? link;
  final String imageLink;

  const StreamPage({
    Key? key,
    required this.channelName,
    required this.guideName,
    required this.isBroadcaster,
    required this.eventName,
    required this.description,
    this.link,
    required this.imageLink,
  }) : super(key: key);

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  late RtcEngine _engine;
  bool muted = false;
  bool isChatShown = false;
  bool isCameraOff = false;
  late int streamId;
  bool isHidden = false;
  int? userId;
  bool isLoading = true;
  bool isLiveEnded = false;
  bool isFullScreen = false;

  late String firstHalf;
  late String secondHalf;

  bool descriptionShowing = true;

  final TextEditingController _controller = TextEditingController();
  bool emojiShowing = false;
  final FocusNode _focus = FocusNode();

  _onEmojiSelected(emoji.Emoji emoji) {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  _onBackspacePressed() {
    _controller
      ..text = _controller.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length));
  }

  @override
  void initState() {
    initializeAgora();

    _focus.addListener(_onFocusChange);

    if (widget.description.length > 50) {
      firstHalf = widget.description.substring(0, 50);
      secondHalf = widget.description.substring(50, widget.description.length);
    } else {
      firstHalf = widget.description;
      secondHalf = "";
    }

    Wakelock.enable();

    super.initState();
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      setState(() {
        emojiShowing = false;
        descriptionShowing = true;
      });
    }
  }

  @override
  void dispose() {
    _engine.destroy();
    _controller.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    Wakelock.disable();
    super.dispose();
  }

  Future<void> initializeAgora() async {
    await _initAgoraRtcEngine();

    if (widget.isBroadcaster) {
      streamId = (await _engine.createDataStream(false, false))!;
    }

    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.createWithContext(RtcEngineContext(AppId.appId));
    await _engine.enableVideo();

    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadcaster) {
      await _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      await _engine.setClientRole(ClientRole.Audience);
    }

    _engine.setEventHandler(
      RtcEngineEventHandler(
        error: (e) {
          if (kDebugMode) {
            print("CheckAgora Error: " + e.toString());
          }
        },
        joinChannelSuccess: (channelName, uid, elapsed) async {
          if (kDebugMode) {
            print("ChekcAgora joinChannelSuccess Uid" + uid.toString());
          }
        },
        userJoined: (uid, elapsed) {
          setState(() {
            userId = uid;
            isLoading = false;
            isLiveEnded = false;
          });
        },
        userOffline: (uid, reason) {
          setState(() {
            isLiveEnded = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (emojiShowing) {
          setState(() {
            emojiShowing = false;
          });
          return false;
        }
        return true;
      },
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape && !isFullScreen) {
            if (!widget.isBroadcaster && userId != null) {
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                setState(() {
                  isFullScreen = true;
                });
              });
            } else {
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                setState(() {
                  isFullScreen = true;
                });
              });
            }
          }

          if (orientation == Orientation.portrait && isFullScreen) {
            if (!widget.isBroadcaster && userId != null) {
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                setState(() {
                  isChatShown = false;
                });
              });
            } else {
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                setState(() {
                  isChatShown = false;
                });
              });
            }
          }

          return Scaffold(
            body: isFullScreen
                ? isLiveEnded && !widget.isBroadcaster
                    ? liveEndedWidget(context, true)
                    : buildStreamPlayer(context, true)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isLoading && !widget.isBroadcaster
                          ? Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              color: Colors.black,
                              child: Center(
                                child:
                                    buildNoStream(AppStrings.streamNotStarted),
                              ),
                            )
                          : isLiveEnded && !widget.isBroadcaster
                              ? liveEndedWidget(context, false)
                              : buildStreamPlayer(context, false),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            buildTopRow(context),
                            buildChatList(),
                            buildMessageRow(),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget buildNoStream(String text) {
    return CachedNetworkImage(
      imageUrl: widget.imageLink,
      errorWidget: (context, url, error) => const Icon(Icons.error),
      imageBuilder: (context, imageProvider) {
        return Stack(
          children: [
            buildBackgroundImage(imageProvider),
            buildOverlay(),
            buildText(text),
          ],
        );
      },
    );
  }

  Widget buildText(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
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
        color: Colors.black45,
      ),
    );
  }

  Widget buildBackgroundImage(ImageProvider<Object> imageProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget liveEndedWidget(BuildContext context, bool flag) {
    return Container(
      height: flag ? null : MediaQuery.of(context).size.height * 0.3,
      color: Colors.black,
      child: Stack(
        children: [
          buildNoStream(AppStrings.disconnected),
          flag
              ? Positioned(
                  bottom: 12,
                  right: 12,
                  child: buildFullScreenButton(),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget buildStreamPlayer(BuildContext context, isFullScreen) {
    return SizedBox(
      height: isFullScreen
          ? MediaQuery.of(context).size.height
          : MediaQuery.of(context).size.height * 0.3,
      child: Stack(
        children: [
          buildStreamView(),
          if (!isHidden) buildControlButtons(),
          buildStreamChatView(),
        ],
      ),
    );
  }

  Widget buildStreamView() {
    return GestureDetector(
      onTap: () => setState(() {
        isHidden = !isHidden;
      }),
      onDoubleTap: _onSwitchCamera,
      child: widget.isBroadcaster
          ? const rtc_local.SurfaceView()
          : rtc_remote.SurfaceView(
              channelId: widget.channelName,
              uid: userId!,
            ),
    );
  }

  Widget buildTopRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildEventNameText(),
          buildGuideNameText(),
          const SizedBox(height: 4),
          buildDescriptionText(),
          buildShowDescriptionButton(),
        ],
      ),
    );
  }

  Widget buildEventNameText() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Text(
        widget.eventName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),
    );
  }

  Widget buildShareButton(BuildContext context) {
    return widget.isBroadcaster
        ? IconButton(
            onPressed: () => AppExtras.showLinkDialog(context, widget.link!),
            icon: const Icon(Icons.share),
          )
        : Container();
  }

  Widget buildGuideNameText() {
    return Text(
      "Guide: " + widget.guideName,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 18,
        color: Colors.black54,
      ),
    );
  }

  Widget buildDescriptionText() {
    return Text(
      descriptionShowing ? (firstHalf + "...") : (firstHalf + secondHalf),
    );
  }

  Widget buildShowDescriptionButton() {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            descriptionShowing ? "show more" : "show less",
            style: TextStyle(color: AppColors.primaryColor),
          ),
        ],
      ),
      onTap: () {
        setState(() {
          descriptionShowing = !descriptionShowing;
        });
      },
    );
  }

  Widget buildChatList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: buildChatBuilder(),
      ),
    );
  }

  Widget buildChatBuilder() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.channelName)
          .collection("chats")
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return buildChatView(snapshot);
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error: " + snapshot.error.toString()),
          );
        }
        return Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      },
    );
  }

  Widget buildChatView(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data?.docs.length,
      shrinkWrap: true,
      reverse: true,
      itemBuilder: (context, index) {
        bool isSame =
            snapshot.data?.docs[index]['sender_id'] == AppMethods.getUid();
        return Align(
          alignment: isSame ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: isSame || isFullScreen
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isSame
                  ? Container()
                  : isFullScreen
                      ? Container()
                      : buildChatProfileImage(
                          snapshot.data?.docs[index]['sender_profile']),
              buildChatBubble(context, isSame, snapshot, index),
            ],
          ),
        );
      },
    );
  }

  Widget buildChatBubble(
    BuildContext context,
    bool isSame,
    AsyncSnapshot<QuerySnapshot<Object?>> snapshot,
    int index,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isFullScreen
            ? Colors.black54
            : isSame
                ? AppColors.primaryColor
                : Colors.black54,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              isSame ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment:
                  isSame ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                isSame
                    ? Container()
                    : buildUsernameText(
                        snapshot.data?.docs[index]['send_by'] + ":",
                      ),
                const SizedBox(height: 4),
                buildMessageText(
                  context,
                  snapshot.data?.docs[index]['message'],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMessageTime(DateTime date) {
    return Text(
      date.toLocalTime(),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 10,
      ),
    );
  }

  Widget buildMessageText(BuildContext context, String message) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isFullScreen
            ? MediaQuery.of(context).size.width * 0.23
            : MediaQuery.of(context).size.width * 0.63,
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildUsernameText(String username) {
    return Text(
      username,
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Colors.white70,
      ),
    );
  }

  Widget buildChatProfileImage(String profileUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: CircleAvatar(
        backgroundImage: NetworkImage(profileUrl),
        backgroundColor: Colors.transparent,
        radius: 22,
      ),
    );
  }

  Widget buildMessageRow() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              buildMessageField(),
              buildEmojiButton(),
              buildSendButton()
            ],
          ),
        ),
        buildOffstage(),
      ],
    );
  }

  Widget buildMessageField() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: CustomTextField(
          controller: _controller,
          focus: _focus,
          hintText: AppStrings.typeMessage,
        ),
      ),
    );
  }

  Widget buildEmojiButton() {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            emojiShowing = !emojiShowing;
          });
        },
        icon: Icon(
          emojiShowing ? Icons.emoji_emotions : Icons.emoji_emotions_outlined,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget buildSendButton() {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: sendMessage,
        icon: Icon(
          Icons.send,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget buildOffstage() {
    return Offstage(
      offstage: !emojiShowing,
      child: SizedBox(
        height: 250,
        child: emoji.EmojiPicker(
          onEmojiSelected: (emoji.Category category, emoji.Emoji emoji) {
            _onEmojiSelected(emoji);
          },
          onBackspacePressed: _onBackspacePressed,
          config: emoji.Config(
            columns: 7,
            // Issue: https://github.com/flutter/flutter/issues/28894
            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            initCategory: emoji.Category.RECENT,
            bgColor: const Color(0xFFF2F2F2),
            indicatorColor: AppColors.primaryColor,
            iconColor: Colors.grey,
            iconColorSelected: AppColors.primaryColor,
            progressIndicatorColor: AppColors.primaryColor,
            backspaceColor: AppColors.primaryColor,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            showRecentsTab: true,
            recentsLimit: 28,
            noRecentsText: 'No Recents',
            noRecentsStyle:
                const TextStyle(fontSize: 20, color: Colors.black26),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: const emoji.CategoryIcons(),
            buttonMode: emoji.ButtonMode.MATERIAL,
          ),
        ),
      ),
    );
  }

  Widget buildControlButtons() {
    return widget.isBroadcaster
        ? Positioned(
            bottom: 18,
            left: isChatShown ? 12 : 0,
            right: isChatShown ? null : 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                buildMuteButton(),
                buildEndButton(),
                buildSwitchButton(),
                //buildCameraButton(),
                isFullScreen &&
                        MediaQuery.of(context).orientation ==
                            Orientation.landscape
                    ? buildChatToggleButton()
                    : Container(),
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? buildFullScreenButton()
                    : Container(),
              ],
            ),
          )
        : Positioned(
            bottom: 18,
            right: 0,
            child: Row(
              children: [
                buildEndButton(),
                isFullScreen &&
                        MediaQuery.of(context).orientation ==
                            Orientation.landscape
                    ? Container()
                    : buildFullScreenButton(),
              ],
            ),
          );
  }

  Widget buildMuteButton() {
    return IconRawButton(
      onPressed: _onToggleMute,
      icon: muted ? Icons.mic_off : Icons.mic,
      iconColor: muted ? Colors.white : AppColors.primaryColor,
      fillColor: muted ? AppColors.primaryColor : Colors.white,
    );
  }

  Widget buildCameraButton() {
    return IconRawButton(
      onPressed: _onCameraShut,
      icon: isCameraOff
          ? Icons.cancel_presentation_rounded
          : Icons.cancel_presentation_rounded,
      iconColor: isCameraOff ? Colors.white : AppColors.primaryColor,
      fillColor: isCameraOff ? AppColors.primaryColor : Colors.white,
    );
  }

  Widget buildEndButton() {
    return IconRawButton(
      onPressed: () => _onCallEnd(context),
      icon: Icons.call_end,
      iconColor: Colors.white,
      fillColor: Colors.redAccent,
      size: 36,
    );
  }

  Widget buildSwitchButton() {
    return IconRawButton(
      onPressed: _onSwitchCamera,
      icon: Icons.switch_camera,
    );
  }

  Widget buildFullScreenButton() {
    return IconRawButton(
      onPressed: () {
        setState(() {
          isFullScreen = !isFullScreen;
        });
      },
      icon: Icons.fullscreen,
    );
  }

  Widget buildChatToggleButton() {
    return IconRawButton(
      onPressed: _onToggleChat,
      icon: Icons.chat,
      iconColor: isChatShown ? Colors.white : AppColors.primaryColor,
      fillColor: isChatShown ? AppColors.primaryColor : Colors.white,
    );
  }

  Widget buildStreamChatView() {
    return Positioned(
      right: 12,
      bottom: 0,
      top: 0,
      child: isChatShown
          ? Container(
              width: MediaQuery.of(context).size.width * 0.3,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: buildChatBuilder(),
            )
          : Container(),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onToggleChat() {
    setState(() {
      isChatShown = !isChatShown;
    });
  }

  void _onCameraShut() {
    setState(() {
      isCameraOff = !isCameraOff;
    });
    _engine.muteLocalVideoStream(isCameraOff);
  }

  void _onSwitchCamera() {
    //if (streamId != null) _engine.sendStreamMessage(streamId, "mute user blet");
    _engine.switchCamera();
  }

  void sendMessage() {
    if (_controller.text.isNotEmpty) {
      String message = _controller.text.trim();
      _controller.clear();

      FirebaseFirestore.instance
          .collection("chats")
          .doc(widget.channelName)
          .collection("chats")
          .doc()
          .set({
        "message": message,
        "sender_id": AppMethods.getUid() ?? "0",
        "send_by":
            widget.isBroadcaster ? widget.guideName : AppMethods.getUsername(),
        "sender_profile": widget.isBroadcaster
            ? AppStrings.defaultProfileUrl
            : AppMethods.getProfileUrl(),
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }
}
