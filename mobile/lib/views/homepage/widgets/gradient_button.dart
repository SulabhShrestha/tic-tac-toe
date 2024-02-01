import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final LinearGradient? linearGradient;

  const GradientButton({
    super.key,
    required this.onTap,
    required this.child,
    this.linearGradient =
        const LinearGradient(colors: [Colors.cyan, Colors.indigo]),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 44,
      decoration: BoxDecoration(
        gradient: linearGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}
