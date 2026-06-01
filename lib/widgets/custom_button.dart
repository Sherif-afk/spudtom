import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spudtom/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.height = 56,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String text;
  final FutureOr<void> Function()? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground = isOutlined
        ? Colors.transparent
        : backgroundColor ?? AppColors.primaryGreen;
    final resolvedForeground =
        foregroundColor ?? (isOutlined ? AppColors.textDark : AppColors.white);
    final resolvedBorder =
        borderColor ?? (isOutlined ? AppColors.border : resolvedBackground);

    final child = isLoading
        ? SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(resolvedForeground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading || onPressed == null
                ? null
                : () {
                    onPressed!.call();
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: resolvedForeground,
              side: BorderSide(color: resolvedBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: resolvedBackground,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: isLoading || onPressed == null
                ? null
                : () {
                    onPressed!.call();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: resolvedBackground,
              foregroundColor: resolvedForeground,
              disabledBackgroundColor: resolvedBackground.withOpacity(0.7),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            child: child,
          );

    return SizedBox(width: double.infinity, height: height, child: button);
  }
}
