import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:student_systemv1/API/attendance_api.dart';

class AttendanceQrScanScreen extends StatefulWidget {
  const AttendanceQrScanScreen({super.key});

  @override
  State<AttendanceQrScanScreen> createState() => _AttendanceQrScanScreenState();
}

class _AttendanceQrScanScreenState extends State<AttendanceQrScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isSubmitting = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleQrToken(String qrToken) async {
    if (_isSubmitting || qrToken.trim().isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _message = null;
      _success = false;
    });

    await _scannerController.stop();

    final result = await AttendanceAPI.scanLectureQr(qrToken.trim());
    final success = result["success"] == true;
    final message =
        result["message"]?.toString() ??
        (success ? "Attendance recorded successfully." : "Scan failed.");

    if (!mounted) return;

    setState(() {
      _success = success;
      _message = message;
      _isSubmitting = false;
    });

    Get.snackbar(
      success ? "Attendance" : "Unable to record attendance",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: success
          ? Colors.green.withAlpha(230)
          : Colors.redAccent.withAlpha(230),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _scanAgain() async {
    setState(() {
      _message = null;
      _success = false;
      _isSubmitting = false;
    });
    await _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan QR"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              String? value;
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  value = barcode.rawValue;
                  break;
                }
              }

              if (value != null) {
                _handleQrToken(value);
              }
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ScannerFramePainter()),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]!.withAlpha(240)
                    : Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSubmitting) ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text("Recording attendance..."),
                  ] else if (_message != null) ...[
                    Icon(
                      _success ? Icons.check_circle : Icons.error_outline,
                      color: _success ? Colors.green : Colors.redAccent,
                      size: 36,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _message!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            child: const Text("Done"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _scanAgain,
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text("Scan Again"),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Text(
                      "Point the camera at the lecture QR code.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withAlpha(117);
    final frameSize = size.width * 0.68;
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 36),
      width: frameSize,
      height: frameSize,
    );

    final fullPath = Path()..addRect(Offset.zero & size);
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(18)));

    canvas.drawPath(
      Path.combine(PathOperation.difference, fullPath, cutoutPath),
      overlayPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(18)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
