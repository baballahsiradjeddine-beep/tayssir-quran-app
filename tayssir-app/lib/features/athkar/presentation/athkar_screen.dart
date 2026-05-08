import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayssir/features/athkar/data/athkar_data.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

class AthkarScreen extends StatefulWidget {
  const AthkarScreen({super.key});

  @override
  State<AthkarScreen> createState() => _AthkarScreenState();
}

class _AthkarScreenState extends State<AthkarScreen> {
  late List<Thikr> _athkar;
  late Map<int, int> _counters;
  bool _isMorning = true;

  @override
  void initState() {
    super.initState();
    _checkTime();
    _initAthkar();
  }

  void _checkTime() {
    final hour = DateTime.now().hour;
    _isMorning = hour >= 4 && hour < 16;
  }

  void _initAthkar() {
    _athkar = _isMorning ? AthkarData.getMorningAthkar() : AthkarData.getEveningAthkar();
    _counters = {for (int i = 0; i < _athkar.length; i++) i: 0};
  }

  void _increment(int index) {
    if (_counters[index]! < _athkar[index].count) {
      setState(() {
        _counters[index] = _counters[index]! + 1;
      });
      HapticFeedback.lightImpact();
      if (_counters[index] == _athkar[index].count) {
        HapticFeedback.heavyImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(isDark),
          SliverPadding(
            padding: EdgeInsets.all(20.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildThikrCard(_athkar[index], index, isDark),
                childCount: _athkar.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      backgroundColor: _isMorning ? const Color(0xFF0EA5E9) : const Color(0xFF1E1B4B),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _isMorning ? "أذكار الصباح ☀️" : "أذكار المساء 🌙",
          style: TextStyle(fontFamily: 'SomarSans', fontWeight: FontWeight.w900, fontSize: 18.sp),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: _isMorning 
                    ? [const Color(0xFF38BDF8), const Color(0xFF0EA5E9)]
                    : [const Color(0xFF312E81), const Color(0xFF1E1B4B)],
                ),
              ),
            ),
            // Pattern or Image
            Positioned(
              right: -50,
              top: -50,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.wb_sunny_rounded, size: 250.r, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThikrCard(Thikr thikr, int index, bool isDark) {
    final current = _counters[index]!;
    final total = thikr.count;
    final isDone = current >= total;
    
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDone ? Colors.green.withOpacity(0.3) : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _increment(index),
        child: Column(
          children: [
            Text(
              thikr.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SomarSans',
                fontSize: 18.sp,
                height: 1.6,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white.withOpacity(0.9) : const Color(0xFF1E293B),
              ),
            ),
            if (thikr.description.isNotEmpty) ...[
              12.verticalSpace,
              Text(
                thikr.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SomarSans',
                  fontSize: 12.sp,
                  color: AppColors.goldColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            20.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTallyButton(current, total, isDark),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildTallyButton(int current, int total, bool isDark) {
    final isDone = current >= total;
    final progress = current / total;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80.r,
          height: 80.r,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            valueColor: AlwaysStoppedAnimation<Color>(isDone ? Colors.green : AppColors.goldColor),
          ),
        ),
        Container(
          width: 65.r,
          height: 65.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? Colors.green : AppColors.goldColor.withOpacity(0.1),
          ),
          child: Center(
            child: isDone 
              ? Icon(Icons.check_rounded, color: Colors.white, size: 30.sp)
              : Text(
                  "$current",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.goldColor,
                  ),
                ),
          ),
        ),
      ],
    );
  }
}
