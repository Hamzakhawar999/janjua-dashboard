import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const MyButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent, // needed for InkWell ripple
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 60, // matches field height
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.tertiary,                 // dark slab like in SS
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant), // hairline border
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.black)
                    .withOpacity(isDark ? 0.35 : 0.08),   // soft drop shadow
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: cs.onSurface,   // white in dark, near-black in light
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
