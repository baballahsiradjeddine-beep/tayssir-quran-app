<?php

namespace Database\Seeders;

use App\Models\Material;
use App\Models\Unit;
use App\Models\Chapter;
use App\Models\ChapterLevel;
use App\Models\Question;
use App\Enums\QuestionType;
use App\Enums\QuestionScope;
use Illuminate\Database\Seeder;

class TajweedWarshSeeder extends Seeder
{
    public function run()
    {
        $material = Material::updateOrCreate(
            ['code' => 'TAJ-WARSH'],
            [
                'name' => 'أحكام التجويد (رواية ورش)',
                'description' => 'المنهج الشامل والمتكامل لإتقان التجويد برواية ورش.',
                'active' => true,
                'direction' => 'RTL',
            ]
        );

        $beginner = ChapterLevel::firstOrCreate(['name' => 'مبتدئ'], ['exercice_points' => 10, 'lesson_points' => 5, 'bonus' => 2]);
        $intermediate = ChapterLevel::firstOrCreate(['name' => 'متوسط'], ['exercice_points' => 20, 'lesson_points' => 10, 'bonus' => 5]);

        // --- EXTENDED SYLLABUS DATA ---
        $syllabus = [
            [
                'unit' => 'مقدمة الرواية وسندها',
                'chapters' => [
                    [
                        'name' => 'التعريف بالإمام نافع وورش',
                        'type' => 'lesson',
                        'questions' => [
                            ['q' => 'ما هو لقب عثمان بن سعيد المصري؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => 'ورش', 'is_correct' => true], ['option' => 'قالون', 'is_correct' => false]]]],
                            ['q' => 'توفي الإمام ورش في مصر.', 'type' => QuestionType::TRUE_OR_FALSE, 'opt' => ['correct' => true]],
                            ['q' => 'قرأ الإمام ورش على نافع كم ختمة؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => 'ختمة واحدة', 'is_correct' => false], ['option' => 'أربع ختمات', 'is_correct' => true]]]],
                        ]
                    ],
                    [
                        'name' => 'طريق الأزرق والشاطبية',
                        'type' => 'lesson',
                        'questions' => [
                            ['q' => 'من هو الراوي المباشر عن ورش من طريق الشاطبية؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => 'الأزرق', 'is_correct' => true], ['option' => 'الأصبهاني', 'is_correct' => false]]]],
                            ['q' => 'طريق الأزرق هو المعتمد في معظم بلاد المغرب العربي.', 'type' => QuestionType::TRUE_OR_FALSE, 'opt' => ['correct' => true]],
                        ]
                    ],
                    [
                        'name' => 'مراتب القراءة ومصطلحات الضبط',
                        'type' => 'lesson',
                        'questions' => [
                            ['q' => 'أفضل مراتب القراءة عند ورش هي الترتيل.', 'type' => QuestionType::TRUE_OR_FALSE, 'opt' => ['correct' => true]],
                            ['q' => 'ماذا تعني النقطة الكبيرة فوق الألف في ضبط ورش؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => 'إمالة', 'is_correct' => false], ['option' => 'تسهيل', 'is_correct' => true]]]],
                        ]
                    ]
                ]
            ],
            [
                'unit' => 'أحكام النون الساكنة والتنوين',
                'chapters' => [
                    [
                        'name' => 'الإظهار الحلقي (صفاء المخرج)',
                        'type' => 'lesson',
                        'questions' => [
                            ['q' => 'كم عدد حروف الإظهار الحلقي؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => '4', 'is_correct' => false], ['option' => '6', 'is_correct' => true]]]],
                            ['q' => 'النون في (مِنْ عِلْمٍ) حكمها الإظهار.', 'type' => QuestionType::TRUE_OR_FALSE, 'opt' => ['correct' => true]],
                            ['q' => 'حدد حرفاً ليس من حروف الحلق:', 'type' => QuestionType::PICK_THE_INTRUDER, 'opt' => ['choices' => [['option' => 'ح', 'is_intruder' => false], ['option' => 'ع', 'is_intruder' => false], ['option' => 'ك', 'is_intruder' => true]]]],
                        ]
                    ],
                    [
                        'name' => 'الإدغام بأنواعه',
                        'type' => 'exercise',
                        'questions' => [
                            ['q' => 'ما هو حكم النون في (مَنْ يَقُولُ)؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => 'إدغام بغنة', 'is_correct' => true], ['option' => 'إظهار', 'is_correct' => false]]]],
                            ['q' => 'الإدغام في اللام والراء يكون بغير غنة.', 'type' => QuestionType::TRUE_OR_FALSE, 'opt' => ['correct' => true]],
                            ['q' => 'صل الكلمة بالحكم:', 'type' => QuestionType::MATCH_WITH_ARROWS, 'opt' => ['pairs' => [['first' => 'مِنْ مَال', 'second' => 'إدغام كامل بغنة'], ['first' => 'مِنْ رَبهم', 'second' => 'إدغام بغير غنة']]]],
                        ]
                    ],
                    [
                        'name' => 'الإخفاء والقلب',
                        'type' => 'exercise',
                        'questions' => [
                            ['q' => 'حرف الباء هو حرف الإقلاب الوحيد.', 'type' => QuestionType::TRUE_OR_FALSE, 'opt' => ['correct' => true]],
                            ['q' => 'كم عدد حروف الإخفاء الحقيقي؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => '15', 'is_correct' => true], ['option' => '12', 'is_correct' => false]]]],
                        ]
                    ]
                ]
            ],
            [
                'unit' => 'قواعد الهمزات (سر ورش)',
                'chapters' => [
                    [
                        'name' => 'سر سلاسة ورش (قاعدة النقل)',
                        'type' => 'lesson',
                        'questions' => [
                            ['q' => 'ما هي حركة النون في (مَنْ آمَنَ) عند ورش؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => 'السكون', 'is_correct' => false], ['option' => 'الفتحة (نقل)', 'is_correct' => true]]]],
                            ['q' => 'يشترط للنقل أن يكون الساكن حرف مد.', 'type' => QuestionType::TRUE_OR_FALSE, 'opt' => ['correct' => false]],
                            ['q' => 'في كلمة (الآخِرَة)، كم وجهاً لورش؟', 'type' => QuestionType::MULTIPLE_CHOICES, 'opt' => ['choices' => [['option' => 'وجه واحد', 'is_correct' => false], ['option' => 'ثلاثة أوجه (بدل)', 'is_correct' => true]]]],
                        ]
                    ]
                ]
            ]
        ];

        // 3. Execution
        foreach ($syllabus as $uIndex => $uData) {
            $unit = Unit::updateOrCreate(
                ['name' => $uData['unit']],
                ['description' => $uData['unit'], 'active' => true]
            );
            $material->units()->syncWithoutDetaching([$unit->id => ['sort' => $uIndex + 1]]);
            $unit->subscriptions()->syncWithoutDetaching([1]);

            foreach ($uData['chapters'] as $cIndex => $cData) {
                $chapter = Chapter::updateOrCreate(
                    ['name' => $cData['name']],
                    [
                        'type' => $cData['type'],
                        'chapter_level_id' => $beginner->id,
                        'active' => true,
                        'description' => $cData['name'],
                        'content' => [['elements' => [['type' => 'text', 'data' => ['content' => "محتوى تفصيلي لدرس " . $cData['name']]]]]]
                    ]
                );
                $unit->chapters()->syncWithoutDetaching([$chapter->id => ['sort' => $cIndex + 1]]);

                if (isset($cData['questions'])) {
                    foreach ($cData['questions'] as $qData) {
                        $question = Question::updateOrCreate(
                            ['question' => $qData['q']],
                            [
                                'question_type' => $qData['type'],
                                'options' => $qData['opt'],
                                'explanation_text' => 'مراجعة لأحكام ورش في هذا الموضع.',
                                'scope' => QuestionScope::EXERCICE,
                                'direction' => 'RTL',
                            ]
                        );
                        $chapter->questions()->syncWithoutDetaching([$question->id => ['sort' => 1]]);
                    }
                }
            }
        }

        $this->command->info('Massive Content Update: Units, Chapters, and Questions synchronized!');
    }
}
