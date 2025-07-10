import 'package:flutter/material.dart';

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final TextStyle? valueStyle;

  const InfoItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.valueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.blue, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: valueStyle ?? TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
} 