import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tayssir/common/core/app_scaffold.dart';
import 'package:tayssir/features/tools/card_swipper/card_pattern_painter.dart';
import 'package:tayssir/features/tools/card_swipper/category_filter_section.dart';
import 'package:tayssir/features/tools/common/data/tool_repository.dart';
import 'package:tayssir/features/tools/resumes/models/resume_data_model.dart';
import 'package:tayssir/router/app_router.dart';
import 'package:tayssir/resources/colors/app_colors.dart';

final resumeDataProvider = FutureProvider<ResumeDataModel>((ref) async {
  final res = await ref.watch(toolRepositoryProvider).getResumesData();
  return res;
});

class ResumesScreen extends HookConsumerWidget {
  const ResumesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeDataAsync = ref.watch(resumeDataProvider);

    return resumeDataAsync.when(
      loading: () => const ResumesLoadingView(),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              error.toString(),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      data: (data) => ResumesDataView(data: data),
    );
  }
}

class ResumesLoadingView extends StatelessWidget {
  const ResumesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return AppScaffold(
      includeBackButton: false,
      topSafeArea: true,
      paddingX: 0,
      maxWidth: 1000,
      bodyBackgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title on the Right (First child in RTL)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ملخصات بيان 📚',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontFamily: 'SomarSans',
                        ),
                      ),
                    ],
                  ),
                  // Button on the Left (Last child in RTL)
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.sp,
                        color: isDark ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: const CircularProgressIndicator(
                color: Color(0xFF10B981),
                strokeWidth: 3,
              ),
            ),
            24.verticalSpace,
            Text(
              'جاري تحضير الملخصات...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black54,
                fontFamily: 'SomarSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResumesDataView extends HookWidget {
  final ResumeDataModel data;

  const ResumesDataView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currentMaterial = useState<int?>(0);
    final scrollController = useScrollController();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final displayedUnits =
        currentMaterial.value == 0 || currentMaterial.value == null
            ? data.units
            : data.units
                .where((u) => u.materialId == currentMaterial.value)
                .toList();

    final currentColor = currentMaterial.value == 0
        ? const Color(0xFF10B981)
        : data.materials
            .where((item) => item.id == currentMaterial.value)
            .first
            .colors[0];

    return AppScaffold(
      includeBackButton: false,
      topSafeArea: true,
      paddingX: 0,
      paddingY: 0,
      paddingB: 0,
      maxWidth: 1000,
      bodyBackgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.h),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 30.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title on the Right (First child in RTL)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ملخصات بيان 📚',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                          fontFamily: 'SomarSans',
                        ),
                      ),
                    ],
                  ),
                  // Button on the Left (Last child in RTL)
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.sp,
                        color: isDark ? Colors.white : AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth > 1000 ? (constraints.maxWidth - 1000) / 2 : 20.w;
          
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  // Filter Section
                  Container(
                    padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                    child: Column(
                      children: [
                        FilterSection(
                          items: data.materials,
                          isPremium: false,
                          padding: 8,
                          allLabel: 'جميع الملخصات',
                          isAllOptionsPressed: currentMaterial.value == 0,
                          onClearAllSelected: () {
                            currentMaterial.value = 0;
                          },
                          getLabel: (item) => item.name,
                          selectionExtractor: (item) =>
                              currentMaterial.value == item.id,
                          filterColor: const Color(0xFF059669),
                          onItemPressed: (item) {
                            currentMaterial.value = item.id;
                            scrollController.animateTo(
                              0.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                        
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: currentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: currentColor.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 14.sp, color: currentColor),
                                    6.horizontalSpace,
                                    Text(
                                      '${displayedUnits.length} وحدة متوفرة',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w900,
                                        color: currentColor,
                                        fontFamily: 'SomarSans',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currentMaterial.value == 0 ? "كل المواد" : "مادة محددة",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                  fontFamily: 'SomarSans',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),

                  // The Grid of Cards
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
                      physics: const ClampingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth > 700 ? 3 : 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 1.1, // Shorter cards
                      ),
                      itemCount: displayedUnits.length,
                      itemBuilder: (context, index) {
                        final unit = displayedUnits[index];
                        final material = data.materials
                            .firstWhere((mat) => mat.id == unit.materialId);

                        return GestureDetector(
                          onTap: () async {
                            if (kIsWeb) {
                              final uri = Uri.parse(unit.pdf);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              }
                              return;
                            }
                            context.pushNamed(AppRoutes.pdfContent.name, extra: {
                              'pdfUrl': unit.pdf,
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: material.colors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: material.colors.first.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: CardPatternPainter(
                                        color: Colors.white.withOpacity(0.1)),
                                  ),
                                ),
                                // Category Pill
                                Positioned(
                                  top: 12.h,
                                  right: 12.w,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Text(
                                      material.name,
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        fontFamily: 'SomarSans',
                                      ),
                                    ),
                                  ),
                                ),
                                // Centered Content
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(12.w, 35.h, 12.w, 12.h),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          unit.name,
                                          style: TextStyle(
                                            fontSize: 16.sp, // Larger text
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            fontFamily: 'SomarSans',
                                            height: 1.1,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        10.verticalSpace,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.menu_book_rounded, color: Colors.white.withOpacity(0.9), size: 13.sp),
                                            4.horizontalSpace,
                                            Text(
                                              'قراءة الملخص',
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: Colors.white.withOpacity(0.9),
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'SomarSans',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (index * 40).ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
