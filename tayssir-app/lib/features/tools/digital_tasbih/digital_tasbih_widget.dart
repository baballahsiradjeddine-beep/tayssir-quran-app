import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class DigitalTasbihWidget extends StatefulWidget {
  const DigitalTasbihWidget({super.key});

  @override
  State<DigitalTasbihWidget> createState() => _DigitalTasbihWidgetState();
}

class _DigitalTasbihWidgetState extends State<DigitalTasbihWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
    HapticFeedback.heavyImpact();
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعادة ضبط العداد', style: TextStyle(fontFamily: 'SomarSans', fontWeight: FontWeight.bold)),
        content: const Text('هل تريد تصفير المسبحة؟', style: TextStyle(fontFamily: 'SomarSans')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'SomarSans'))),
          TextButton(
            onPressed: () {
              setState(() => _counter = 0);
              HapticFeedback.vibrate();
              Navigator.pop(context);
            },
            child: const Text('تصفير', style: TextStyle(color: Colors.red, fontFamily: 'SomarSans', fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.emerald900.withOpacity(0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gold500.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المسبحة الإلكترونية',
                style: TextStyle(
                  color: AppColors.gold500,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'SomarSans',
                ),
              ),
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, color: AppColors.gold500),
              ),
            ],
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: _increment,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold500.withOpacity(0.2),
                    AppColors.emerald800,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold500.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
                border: Border.all(color: AppColors.gold500, width: 2),
              ),
              child: Center(
                child: Text(
                  '$_counter',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold500,
                    fontFamily: 'SomarSans',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'انقر على الدائرة للتسبيح',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'SomarSans',
            ),
          ),
        ],
      ),
    );
  }
}
