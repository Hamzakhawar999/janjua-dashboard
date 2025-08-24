import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  const SquareTile({
    super.key,
    required this.imagePath,
    required this.ontap,
    this.imageColor, // optional param
  });

  final String imagePath;
  final void Function() ontap;
  final Color? imageColor; // null = original image color

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: ontap,
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outlineVariant,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Image.asset(
          imagePath,
          color: imageColor, // apply optional color
        ),
      ),
    );
  }
}
