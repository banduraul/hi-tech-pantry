import 'package:flutter/material.dart';

class ProductExpiryDateStatus extends StatelessWidget {
  const ProductExpiryDateStatus({
    super.key,
    required this.icon,
    required this.expiryDate,
    required this.color
  });

  final IconData icon;
  final String expiryDate;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
        ),
        const SizedBox(width: 5.0),
        Text(
          expiryDate,
          style: TextStyle(color: color, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}