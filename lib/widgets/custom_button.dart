import 'package:agora_video/utils/app_colors.dart';
import 'package:agora_video/utils/app_strings.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final double? fontSize;
  const CustomButton({Key? key, this.text, this.onPressed, this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 8,
        primary: AppColors.primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text ?? AppStrings.defaultButtonText,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: fontSize ?? 22,
          color: Colors.white,
        ),
      ),
    );
  }
}
