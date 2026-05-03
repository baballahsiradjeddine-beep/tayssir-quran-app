import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tayssir/common/bayan_background.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

/// [QuranBaseLayout] هو القالب الأساسي (Template) لجميع شاشات مشروع القرآن.
/// 
/// الميزات:
/// 1. يدمج خلفية [BayanBackground] المتحركة بشكل تلقائي.
/// 2. يوفر نمطاً بصرياً موحداً (Glassmorphism) للمحتوى ليعطي شعوراً بالحداثة والوقار.
/// 3. يستخدم خط 'Amiri' للعناوين لإضفاء اللمسة التراثية القرآنية.
class QuranBaseLayout extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const QuranBaseLayout({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return BayanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent, // شفاف لتظهر خلفية السكينة المتحركة
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'SomarSans',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.goldColor,
            ),
          ),
          actions: actions,
          centerTitle: true,
          leading: const BackButton(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              // خط زخرفي بسيط تحت العنوان
              Container(
                width: 100,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.goldColor.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // منطقة المحتوى الأساسي مع تأثير الزجاج (Glassmorphism)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    child: body,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
