import 'package:flutter/material.dart';
import 'package:tayssir/resources/colors/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class QuranCertificateScreen extends StatelessWidget {
  final String userName;
  final String surahName;
  final DateTime date;

  const QuranCertificateScreen({
    super.key,
    required this.userName,
    required this.surahName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emerald950,
      appBar: AppBar(
        title: const Text('شهادة إنجاز', style: TextStyle(fontFamily: 'SomarSans', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold500.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative Borders
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.gold500, width: 4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.emerald800, width: 1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                // Certificate Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'شهادة حفظ وإتمام',
                        style: TextStyle(
                          fontFamily: 'SomarSans',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emerald900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.gold500, thickness: 2, indent: 50, endIndent: 50),
                      const SizedBox(height: 30),
                      Text(
                        'تمنح هذه الشهادة لـ',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontFamily: 'SomarSans', fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        userName,
                        style: TextStyle(
                          fontFamily: 'SomarSans',
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emerald700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'لإتمامه بنجاح حفظ ومراجعة',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF64748B), fontFamily: 'SomarSans', fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        surahName,
                        style: TextStyle(
                          fontFamily: 'SomarSans',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold500,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('التاريخ', style: TextStyle(fontSize: 12, fontFamily: 'SomarSans', fontWeight: FontWeight.bold)),
                              Text(
                                DateFormat('yyyy/MM/dd').format(date),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'SomarSans'),
                              ),
                            ],
                          ),
                          const Icon(Icons.qr_code_2, size: 60, color: AppColors.emerald900),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('الختم الرقمي', style: TextStyle(fontSize: 12, fontFamily: 'SomarSans', fontWeight: FontWeight.bold)),
                              const Text('BAYAN-QRT-2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'SomarSans')),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'مشروع بيان القرآن - رؤية 2030',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gold500,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SomarSans',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
