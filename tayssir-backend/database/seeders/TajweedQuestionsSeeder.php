<?php

namespace Database\Seeders;

use App\Models\Chapter;
use App\Models\Question;
use App\Enums\QuestionType;
use App\Enums\QuestionScope;
use Illuminate\Database\Seeder;

class TajweedQuestionsSeeder extends Seeder
{
    public function run()
    {
        // Find the chapters we created
        $c_naql_lesson = Chapter::where('name', 'سر سلاسة ورش (قاعدة النقل)')->first();
        $c_naql_ex = Chapter::where('name', 'تحدي صائد النقل')->first();
        $c_izhar_lesson = Chapter::where('name', 'الإظهار الحلقي (صفاء المخرج)')->first();
        $c_hamza_lesson = Chapter::where('name', 'تحدي الهمزتين من كلمة')->first();

        if (!$c_naql_ex) {
            $this->command->error('Chapters not found. Please run TajweedWarshSeeder first.');
            return;
        }

        $questions = [
            // 1. Multiple Choice (Naql)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'ما هو حكم النون في قوله تعالى "مَنْ آمَنَ" عند الإمام ورش؟',
                'question_type' => QuestionType::MULTIPLE_CHOICES,
                'options' => [
                    'choices' => [
                        ['option' => 'الإظهار الحلقي', 'is_correct' => false],
                        ['option' => 'النقل', 'is_correct' => true],
                        ['option' => 'الإدغام الكامل', 'is_correct' => false],
                        ['option' => 'الإخفاء الشفوي', 'is_correct' => false],
                    ]
                ],
                'explanation_text' => 'ورش ينقل حركة الهمزة (الفتحة) إلى النون الساكنة قبلها فتصبح "مَنَامَنَ".'
            ],
            // 2. True or False (Madd)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'يمد الإمام ورش المد المتصل بمقدار 6 حركات وجوباً.',
                'question_type' => QuestionType::TRUE_OR_FALSE,
                'options' => ['correct' => true],
                'explanation_text' => 'المد المتصل والمنفصل عند ورش يمدان بالإشباع (6 حركات).'
            ],
            // 3. Pick the Intruder (Throat letters)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'حدد الحرف الذي لا ينتمي لمجموعة "حروف الحلق" (حروف الإظهار):',
                'question_type' => QuestionType::PICK_THE_INTRUDER,
                'options' => [
                    'choices' => [
                        ['option' => 'أ', 'is_intruder' => false],
                        ['option' => 'هـ', 'is_intruder' => false],
                        ['option' => 'ق', 'is_intruder' => true],
                        ['option' => 'غ', 'is_intruder' => false],
                    ]
                ],
                'explanation_text' => 'حرف القاف من حروف الاستعلاء ويخرج من أقصى اللسان، وليس من الحلق.'
            ],
            // 4. Match with Arrows (Examples)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'صل كل حكم بالمثال المناسب له في رواية ورش:',
                'question_type' => QuestionType::MATCH_WITH_ARROWS,
                'options' => [
                    'pairs' => [
                        ['first' => 'النقل', 'second' => 'قَدَفْلَحَ'],
                        ['first' => 'الإبدال', 'second' => 'يُومِنُونَ'],
                        ['first' => 'تسهيل الهمزة', 'second' => 'أَءَنْذَرْتَهُمْ'],
                    ]
                ],
                'explanation_text' => 'هذه هي أهم أصول ورش في الهمزات.'
            ],
            // 5. Multiple Choice (Badal)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'كم وجهاً لورش في "مد البدل" (مثل: ءامنوا)؟',
                'question_type' => QuestionType::MULTIPLE_CHOICES,
                'options' => [
                    'choices' => [
                        ['option' => 'وجه واحد فقط (حركتان)', 'is_correct' => false],
                        ['option' => 'وجهان (2 و 4 حركات)', 'is_correct' => false],
                        ['option' => 'ثلاثة أوجه (2، 4، 6 حركات)', 'is_correct' => true],
                    ]
                ],
                'explanation_text' => 'لورش في مد البدل القصر (2)، التوسط (4)، والإشباع (6).'
            ],
            // 6. True or False (Raa)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'الأصل في الراء عند ورش هو التفخيم دائماً مثل بقية القراء.',
                'question_type' => QuestionType::TRUE_OR_FALSE,
                'options' => ['correct' => false],
                'explanation_text' => 'ورش يتميز بترقيق الراء في حالات كثيرة جداً لا يرققها فيها غيره (مثل الراء المفتوحة بعد كسر).'
            ],
            // 7. Pick the Intruder (Naql conditions)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'أي من هذه الحالات لا يطبق فيها ورش قاعدة "النقل"؟',
                'question_type' => QuestionType::PICK_THE_INTRUDER,
                'options' => [
                    'choices' => [
                        ['option' => 'النون الساكنة قبل الهمزة', 'is_intruder' => false],
                        ['option' => 'لام التعريف قبل الهمزة', 'is_intruder' => false],
                        ['option' => 'حرف المد قبل الهمزة', 'is_intruder' => true],
                    ]
                ],
                'explanation_text' => 'لا يتم النقل إذا كان الحرف السابق للهمزة حرف مد (مثل: قَالُوا آمَنُوا)، بل يطبق حكم المد المنفصل.'
            ],
            // 8. Multiple Choice (Iqlab)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'ما الحرف الذي تقلب إليه النون الساكنة في "الإقلاب"؟',
                'question_type' => QuestionType::MULTIPLE_CHOICES,
                'options' => [
                    'choices' => [
                        ['option' => 'واو', 'is_correct' => false],
                        ['option' => 'ميم', 'is_correct' => true],
                        ['option' => 'ياء', 'is_correct' => false],
                    ]
                ],
                'explanation_text' => 'تقلب النون ميماً مخفاة بغنة عند ملاقاتها لحرف الباء.'
            ],
            // 9. True or False (Tashil)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'التسهيل يعني نطق الهمزة بين الهمزة والألف (أو الحرف المجانس لحركتها).',
                'question_type' => QuestionType::TRUE_OR_FALSE,
                'options' => ['correct' => true],
                'explanation_text' => 'هذا هو تعريف التسهيل عند أهل الأداء.'
            ],
            // 10. Match with Arrows (Letters)
            [
                'chapter_id' => $c_naql_ex->id,
                'question' => 'صل الحرف بالحكم التجويدي المناسب (للنون الساكنة):',
                'question_type' => QuestionType::MATCH_WITH_ARROWS,
                'options' => [
                    'pairs' => [
                        ['first' => 'ب', 'second' => 'إقلاب'],
                        ['first' => 'ل', 'second' => 'إدغام بغير غنة'],
                        ['first' => 'ع', 'second' => 'إظهار حلقي'],
                    ]
                ],
                'explanation_text' => 'كل حرف يحدد نوع الحكم للنون الساكنة.'
            ]
        ];

        foreach ($questions as $q) {
            $question = Question::create([
                'question' => $q['question'],
                'question_type' => $q['question_type'],
                'options' => $q['options'],
                'explanation_text' => $q['explanation_text'],
                'scope' => QuestionScope::EXERCICE,
                'direction' => 'RTL',
            ]);
            
            $question->chapters()->attach($q['chapter_id'], ['sort' => 1]);
        }

        $this->command->info('10 Professional Tajweed Questions created successfully!');
    }
}
