import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final LinearGradient? linearGradient;
  final double? width;
  final double? height;

  const GradientButton({
    super.key,
    required this.onTap,
    required this.child,
    this.linearGradient =
        const LinearGradient(colors: [Colors.cyan, Colors.indigo]),
    this.width = 150.0,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 38,
      width: width,
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
          padding: EdgeInsets.symmetric(horizontal: 12),
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: child,
      ),
    );
  }
}
