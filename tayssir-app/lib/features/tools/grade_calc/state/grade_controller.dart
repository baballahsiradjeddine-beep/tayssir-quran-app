import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tayssir/features/tools/grade_calc/state/grade_state.dart';
import 'package:tayssir/features/tools/grade_calc/speciality_model.dart';
import 'package:tayssir/features/tools/grade_calc/subject.dart';
import 'package:tayssir/features/tools/grade_calc/state/subject_state.dart';

import '../../../../resources/resources.dart';

final gradeControllerProvider =
    StateNotifierProvider.family<GradeController, GradeState, SpecialityModel>(
        (ref, speciality) {
  return GradeController(
    speciality,
  );
});

class GradeController extends StateNotifier<GradeState> {
  GradeController(
    SpecialityModel speciality,
  ) : super(GradeState(
          speciality: speciality,
          subjects: speciality.subjects
              .map((e) => SubjectState(subjectId: e.id, grade: 0))
              .toList(),
        ));

  void updateGrade(int subjectId, double grade) {
    if (grade < 0 || grade > 20) {
      return;
    }
    // if (state.subjects
    //         .firstWhere((element) => element.subjectId == subjectId)
    //         .grade ==
    //     grade) {
    //   return;
    // }
    state = state.updateGrade(subjectId, grade);
  }

  void reset() {
    state = GradeState(
      speciality: state.speciality,
      subjects: state.subjects
          .map((e) => SubjectState(subjectId: e.subjectId, grade: 0))
          .toList(),
    );
  }
}

final specialityProvider = Provider<List<SpecialityModel>>((ref) {
  return [
    const SpecialityModel(
      name: 'رواية حفص عن عاصم',
      iconPath: SVGs.icQuran,
      subjects: [
        Subject(id: 1, name: 'أصول الرواية', coefficient: 5),
        Subject(id: 2, name: 'مخارج الحروف', coefficient: 4),
        Subject(id: 3, name: 'أحكام التجويد', coefficient: 6),
        Subject(id: 4, name: 'الأداء والترتيل', coefficient: 3),
        Subject(id: 5, name: 'الوقف والابتداء', coefficient: 2),
      ],
    ),
    const SpecialityModel(
      name: 'رواية ورش عن نافع',
      iconPath: SVGs.icQuran,
      subjects: [
        Subject(id: 1, name: 'أصول الرواية', coefficient: 5),
        Subject(id: 2, name: 'أحكام المدود', coefficient: 4),
        Subject(id: 3, name: 'أحكام الهمز', coefficient: 6),
        Subject(id: 4, name: 'الأداء والترتيل', coefficient: 3),
        Subject(id: 5, name: 'الوقف والابتداء', coefficient: 2),
      ],
    ),
    const SpecialityModel(
      name: 'برنامج الحفظ المكثف',
      iconPath: SVGs.icFlash,
      subjects: [
        Subject(id: 1, name: 'الحفظ الجديد', coefficient: 10),
        Subject(id: 2, name: 'الربط والتمكين', coefficient: 5),
        Subject(id: 3, name: 'المراجعة القريبة', coefficient: 4),
        Subject(id: 4, name: 'الاستماع والتدبر', coefficient: 2),
      ],
    ),
    const SpecialityModel(
      name: 'برنامج المراجعة والتمكين',
      iconPath: SVGs.icTime,
      subjects: [
        Subject(id: 1, name: 'مراجعة الماضي القريب', coefficient: 6),
        Subject(id: 2, name: 'مراجعة الماضي البعيد', coefficient: 8),
        Subject(id: 3, name: 'الاختبارات الذاتية', coefficient: 4),
        Subject(id: 4, name: 'تثبيت المتشابهات', coefficient: 2),
      ],
    ),
  ];
});
