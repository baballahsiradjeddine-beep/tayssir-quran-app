import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  CameraController? _cameraController;
  StreamSubscription? _compassSubscription;
  double _heading = 0;
  double _qiblaDirection = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    // 1. Init Camera
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await _cameraController!.initialize();
    }

    // 2. Check Permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 3. Listen to Qibla Stream
    _compassSubscription = FlutterQiblah.qiblahStream.listen((event) {
      setState(() {
        _heading = event.direction;
        _qiblaDirection = event.qiblah;
        _isInitialized = true;
      });
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.goldColor)));
    }

    // Calculate relative direction
    // Qibla is absolute. Heading is absolute.
    // We want the offset on screen.
    double diff = _qiblaDirection - _heading;
    
    // Smooth the difference
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;

    bool isPointing = diff.abs() < 5;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. AR Camera Background
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!)
          else
            Container(color: Colors.black),

          // 2. Dark Overlay for readability
          Container(color: Colors.black.withOpacity(0.3)),

          // 3. AR Floating Icon
          // We map 'diff' to horizontal position
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Transform.translate(
                offset: Offset(diff * 5, 0), // Sensitive mapping
                child: Opacity(
                  opacity: (1 - (diff.abs() / 90)).clamp(0.0, 1.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPointing ? Colors.green.withOpacity(0.5) : Colors.white.withOpacity(0.2),
                          boxShadow: isPointing ? [BoxShadow(color: Colors.green, blurRadius: 30, spreadRadius: 10)] : [],
                        ),
                        child: Icon(Icons.mosque, size: 100.sp, color: Colors.white), // Standard icon as placeholder for 3D
                      ),
                      20.verticalSpace,
                      Text(
                        isPointing ? "أنت تواجه القبلة الآن ✨" : "حرك الهاتف يميناً أو يساراً",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Close Button
          Positioned(
            top: 50.h,
            left: 20.w,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // 5. Status Info
          Positioned(
            bottom: 50.h,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  "زاوية القبلة: ${_qiblaDirection.toStringAsFixed(1)}°",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
