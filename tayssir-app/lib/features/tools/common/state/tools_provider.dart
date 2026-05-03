import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tayssir/common/data/configs.dart';
import 'package:tayssir/features/tools/common/models/tool_model.dart';
import 'package:tayssir/resources/resources.dart';
import 'package:tayssir/router/app_router.dart';

final toolsProvider = Provider<List<ToolModel>>((ref) {
  final configs = ref.watch(configsProvider).valueOrNull;
  if (configs == null) return [];
  final allTools = [
    ToolModel(
      name: 'بطاقات بيان',
      description: 'بطاقات تعليمية تفاعلية',
      pathName: AppRoutes.cardSwipper.name,
      startColor: const Color(0xffCB2487),
      endColor: const Color(0xffFD67C0),
      isLocked: !configs.cardsActive,
      toolImage: ToolImage(
        grid: configs.toolCardsGrid.isNotEmpty ? configs.toolCardsGrid : Images.flashCardsGBg,
        list: configs.toolCardsList.isNotEmpty ? configs.toolCardsList : Images.flashCardsLBg,
      ),
    ),
    ToolModel(
      name: 'مؤقت الحفظ',
      description: 'تقنية لتقسيم وقت الحفظ والمراجعة بتركيز عالٍ.',
      pathName: AppRoutes.pomodoro.name,
      startColor: const Color(0xFF064E3B),
      endColor: const Color(0xFF10B981),
      isLocked: false,
      toolImage: ToolImage(
        grid: configs.toolPomodoroGrid.isNotEmpty ? configs.toolPomodoroGrid : Images.pomodoroBg,
        list: configs.toolPomodoroList.isNotEmpty ? configs.toolPomodoroList : Images.pomodoroBgList,
      ),
      isStartBottomColor: false,
    ),
    ToolModel(
      name: 'حساب التقدم',
      description: 'تابع مسيرتك في حفظ كتاب الله بدقة.',
      pathName: AppRoutes.gradeCalculator.name,
      startColor: const Color(0xFFD4AF37), // Gold
      endColor: const Color(0xFFB8860B),
      isLocked: false,
      toolImage: ToolImage(
          grid: configs.toolGradeCalcGrid.isNotEmpty ? configs.toolGradeCalcGrid : Images.gradeCalcGrid, 
          list: configs.toolGradeCalcList.isNotEmpty ? configs.toolGradeCalcList : Images.gradeCalcList),
    ),
    ToolModel(
      name: 'تلاوات ومراجعات',
      description: 'منصة لتسجيل تلاواتك ومتابعة مراجعتك.',
      pathName: AppRoutes.resumes.name,
      startColor: const Color(0xff533899),
      endColor: const Color(0xFF563A9C),
      isLocked: !configs.resumesActive,
      toolImage: ToolImage(
        grid: configs.toolResumesGrid.isNotEmpty ? configs.toolResumesGrid : Images.resumesGBg,
        list: configs.toolResumesList.isNotEmpty ? configs.toolResumesList : Images.resumsLBg,
      ),
    ),
    ToolModel(
      name: 'حلول البكالوريا',
      description: 'الحلل النموجي للباكالوريات السابقة',
      pathName: AppRoutes.bacs.name,
      startColor: const Color(0xFF4C4C4C),
      endColor: const Color(0xFFA9A9A9),
      isLocked: !configs.bacSolutionsActive,
      toolImage: ToolImage(
        grid: configs.toolBacSolutionsGrid.isNotEmpty ? configs.toolBacSolutionsGrid : Images.reolveGridBg,
        list: configs.toolBacSolutionsList.isNotEmpty ? configs.toolBacSolutionsList : Images.resolveListBg,
      ),
      isStartBottomColor: false,
    ),
  ];
  return allTools.where((tool) => !tool.isLocked).toList();
});
