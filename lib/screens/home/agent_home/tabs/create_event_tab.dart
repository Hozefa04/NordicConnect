import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nordic_connect/extensions/app_extensions.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../utils/app_extras.dart';
import '../../../../utils/app_methods.dart';
import '../../../../utils/app_strings.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_text_field.dart';

class CreateEventTab extends StatefulWidget {
  const CreateEventTab({
    Key? key,
  }) : super(key: key);

  @override
  State<CreateEventTab> createState() => _CreateEventTabState();
}

class _CreateEventTabState extends State<CreateEventTab> {
  late DateTime selectedDate;
  late TextEditingController _eventNameController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;
  late TextEditingController _guideNameController;
  final ImagePicker _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();

  XFile? image;
  String? downloadUrl;

  @override
  void initState() {
    selectedDate = DateTime.now();
    _eventNameController = TextEditingController();
    _dateController = TextEditingController();
    _descriptionController = TextEditingController();
    _guideNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    _guideNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 22),
            buildAddEventText(),
            const SizedBox(height: 22),
            buildForm(context),
            const SizedBox(height: 22),
            buildAddEventButton(context),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _eventNameController,
            hintText: AppStrings.textName,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "This field is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: _dateController,
            readOnly: true,
            hintText: AppStrings.textDate,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "This field is required";
              }
              return null;
            },
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: _descriptionController,
            hintText: AppStrings.textDescription,
            minLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "This field is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          CustomTextField(
            controller: _guideNameController,
            hintText: AppStrings.textGuideName,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "This field is required";
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          CustomTextField(
            hintText: AppStrings.textUploadPicture,
            readOnly: true,
            onTap: () => _pickImage(context),
          ),
        ],
      ),
    );
  }

  Widget buildAddEventButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: AppStrings.addEvent,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                AppExtras.showLoaderDialog(
                  context: context,
                  text: AppStrings.loaderAddingEvent,
                );
                await _addEventInFirestore(
                  eventName: _eventNameController.text,
                  date: selectedDate,
                  description: _descriptionController.text,
                  guideName: _guideNameController.text,
                ).then(
                  (value) => {
                    Navigator.of(context, rootNavigator: true).pop('dialog'),
                    AppExtras.showToast(
                      message: AppStrings.eventAddSuccess,
                    ),
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildAddEventText() {
    return Text(
      AppStrings.addEvent,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );
  }

  Future<void> _addEventInFirestore({
    required String guideName,
    required String eventName,
    required DateTime date,
    required String description,
  }) async {
    if (kDebugMode) {
      print("Firestore called!");
    }
    final document = FirebaseFirestore.instance
        .collection("broadcasts")
        .doc(AppMethods.getUid()!)
        .collection("events")
        .doc();

    if (image != null) {
      downloadUrl = await AppMethods.uploadImageToFirebase(
          File(image!.path), document.id);
    }

    String? eventLink =
        await AppMethods.getGameBranchLink(channelName: document.id);

    await document.set({
      "user_id": AppMethods.getUid(),
      "guide_name": guideName,
      "channel_name": document.id,
      "event_name": eventName,
      "date_time": date,
      "description": description,
      "image_link": downloadUrl,
      "event_link": eventLink,
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    if (await Permission.storage.isGranted) {
      image = await _picker.pickImage(source: ImageSource.gallery);
    } else {
      await Permission.storage.request();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DatePicker.showDateTimePicker(
      context,
      minTime: DateTime.now(),
      onConfirm: (date) {
        setState(() {
          selectedDate = date;
          _dateController.text = selectedDate.toLocalDate();
        });
      },
    );
  }
}
