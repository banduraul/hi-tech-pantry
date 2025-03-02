import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  const ImageDialog({super.key, required this.image});

  final Image image;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: image
    );
  }
}