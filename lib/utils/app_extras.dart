import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../widgets/custom_text_field.dart';
import 'app_colors.dart';
import 'app_methods.dart';
import 'app_strings.dart';

class AppExtras {
  static showLoaderDialog({
    required BuildContext context,
    String? text,
    bool isLoading = true,
    bool isBarrierDismissible = false,
  }) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          if (isLoading)
            CircularProgressIndicator(color: AppColors.primaryColor),
          text != null
              ? Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
    showDialog(
      barrierDismissible: isBarrierDismissible,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static void showToast({required String message}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  static void showLinkDialog(BuildContext context, String link) async {
    Widget copyButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(AppStrings.shareButton),
      onPressed: () {
        AppMethods.shareLink(link);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(AppStrings.invite),
      content: CustomTextField(
        hintText: link,
        readOnly: true,
        minLines: 2,
        maxLines: 3,
      ),
      actions: [
        copyButton,
      ],
    );

    await Future.delayed(const Duration(milliseconds: 50));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
