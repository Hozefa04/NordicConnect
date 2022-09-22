import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class IconRawButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? fillColor;
  final Color? iconColor;
  final double? size;
  const IconRawButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.fillColor = Colors.white,
    this.iconColor,
    this.size = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        color: iconColor ?? AppColors.primaryColor,
        size: size,
      ),
      shape: const CircleBorder(),
      elevation: 2.0,
      fillColor: fillColor,
      padding: const EdgeInsets.all(12.0),
    );
  }
}
