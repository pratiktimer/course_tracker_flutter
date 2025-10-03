import 'package:flutter/material.dart';

class NeuCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double shadow;

  const NeuCard({required this.child, this.borderRadius = 16, this.shadow = 8, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: shadow, offset: const Offset(-4, -4)),
          BoxShadow(color: Colors.white.withOpacity(0.7), blurRadius: shadow, offset: const Offset(4, 4)),
        ],
      ),
      child: child,
    );
  }
}
