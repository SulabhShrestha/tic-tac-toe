import 'package:flutter/material.dart';
import 'package:mobile/utils/colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeWidget extends StatelessWidget {
  final GlobalKey keyForQrCode;
  final String roomID; 

  const QrCodeWidget({
    super.key,
    required this.keyForQrCode,
    required this.roomID,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: keyForQrCode,
      backgroundColor: Colors.transparent,
      child: SizedBox(
        width: 400,
        height: 400,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              bottom: 0,
              child: Container(
                height: 200,
                width: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      ConstantColors.yellow,
                      ConstantColors.yellow,
                      Colors.lime,
                    ],
                  ),
                ),
                child: QrImageView(
                  data: roomID,
                  version: QrVersions.auto,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 12,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.red.shade200, Colors.red.shade600]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    ;
  }
}
