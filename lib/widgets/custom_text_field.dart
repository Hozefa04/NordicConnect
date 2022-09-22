import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_strings.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool? readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? minLines;
  final FocusNode? focus;
  final bool? obscureText;
  final bool? autoCorrect;
  final bool? enableSuggestions;
  final FormFieldValidator? validator;

  const CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.readOnly = false,
    this.onTap,
    this.minLines,
    this.maxLines,
    this.focus,
    this.obscureText,
    this.autoCorrect,
    this.enableSuggestions,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textFieldColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly!,
          onTap: onTap,
          minLines: minLines,
          maxLines: maxLines,
          focusNode: focus,
          obscureText: obscureText ?? false,
          enableSuggestions: enableSuggestions ?? true,
          autocorrect: autoCorrect ?? false,
          cursorColor: AppColors.primaryColor,
          textInputAction: TextInputAction.next,
          validator: validator,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            hintText: hintText ?? AppStrings.defaultTextFieldHint,
          ),
        ),
      ),
    );
  }
}
