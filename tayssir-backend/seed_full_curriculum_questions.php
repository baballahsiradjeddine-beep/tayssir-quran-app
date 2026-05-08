<?php

use App\Models\Question;
use App\Models\Chapter;
use App\Enums\QuestionType;
use App\Enums\QuestionScope;
use Illuminate\Support\Facades\DB;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "Starting Professional Mastery Question Seeding...\n";

// Clear previous questions for a clean professional start
Question::query()->delete();

$proQuestions = [
    'الاستعاذة' => [
        ['type' => QuestionType::MULTIPLE_CHOICES, 'q' => "ما هو الوجه الممتنع أداءً عند وصل 'البسملة' بين السورتين؟", 'opts' => ['قطع الجميع', 'وصل الجميع', 'وصلها بآخر السورة والوقف عليها'], 'correct' => 'وصلها بآخر السورة والوقف عليها', 'exp' => 'يمنع هذا الوجه لئلا يظن أن البسملة لآخر السورة السابقة.'],
        ['type' => QuestionType::TRUE_OR_FALSE, 'q' => 'يجوز لورش السكت بين السورتين بدون بسملة.', 'a' => 'صحيح', 'exp' => 'السكت هو أحد الأوجه الثلاثة لورش وهو المقدم في الأداء.'],
        ['type' => QuestionType::FILL_IN_THE_BLANKS, 'q' => "بين الأنفال والتوبة، يمتنع الإتيان بـ ____ اتفاقاً.", 'a' => 'البسملة', 'exp' => 'سورة براءة لا بسملة في أولها.'],
        ['type' => QuestionType::PICK_THE_INTRUDER, 'q' => 'أي من هذه الأوجه ليس من مذاهب ورش بين السورتين؟', 'opts' => ['السكت اللطيف', 'الوصل بدون بسملة', 'السكت الطويل مع التنفس'], 'correct' => 'السكت الطويل مع التنفس', 'exp' => 'السكت يشترط فيه عدم التنفس.'],
    ],
    'ميم الجمع' => [
        ['type' => QuestionType::MULTIPLE_CHOICES, 'q' => "مقدار مد صلة ميم الجمع عند ورش في نحو (عليهُمُ أنفسهم) هو:", 'opts' => ['حركتان', '4 حركات', '6 حركات'], 'correct' => '6 حركات', 'exp' => 'ورش يشبع صلة ميم الجمع إذا وقع بعدها همزة قطع.'],
        ['type' => QuestionType::TRUE_OR_FALSE, 'q' => "يصل ورش ميم الجمع إذا وقعت قبل حرف ساكن في نحو (عليهمُ القتال).", 'a' => 'خطأ', 'exp' => 'إذا وقع بعدها ساكن، تضم الميم بدون صلة منعاً لالتقاء الساكنين.'],
        ['type' => QuestionType::FILL_IN_THE_BLANKS, 'q' => "يصل ورش ميم الجمع بواو لفظية مشبعة إذا وقع بعدها ____.", 'a' => 'همزة قطع', 'exp' => 'الهمزة هي شرط الصلة المشبعة عند ورش.'],
    ],
    'هاء الكناية' => [
        ['type' => QuestionType::MULTIPLE_CHOICES, 'q' => "كيف يقرأ ورش هاء (يرضه لكم) في سورة الزمر؟", 'opts' => ['بالصلة (حركتان)', 'بالقصر (ضم بدون صلة)', 'بالإسكان'], 'correct' => 'بالقصر (ضم بدون صلة)', 'exp' => 'هذا من مستثنيات ورش، يقرأها بضم الهاء فقط.'],
        ['type' => QuestionType::TRUE_OR_FALSE, 'q' => "يسكن ورش الهاء في (فألقه إليهم) بـالنمل.", 'a' => 'صحيح', 'exp' => 'ورش يقرأها بسكون الهاء.'],
        ['type' => QuestionType::MATCH_WITH_ARROWS, 'q' => 'اربط الكلمة بأداء ورش لها:', 'pairs' => [['أرجه وأخاه', 'كسر بدون صلة'], ['يؤده إليك', 'صلة مشبعة']], 'exp' => 'انفرادات دقيقة لورش في هاء الكناية.'],
    ],
    'الراءات' => [
        ['type' => QuestionType::MULTIPLE_CHOICES, 'q' => "ما حكم الراء في (خبيراً) عند الوقف عليها لورش؟", 'opts' => ['التفخيم', 'الترقيق'], 'correct' => 'الترقيق', 'exp' => 'الراء المفتوحة المسبوقة بياء ساكنة ترقق عند ورش.'],
        ['type' => QuestionType::TRUE_OR_FALSE, 'q' => "يفخم ورش الراء في كلمة (إبراهيم) لأنها اسم أعجمي.", 'a' => 'صحيح', 'exp' => 'الأسماء الأعجمية (إبراهيم، إسماعيل، إسرائيل) مستثناة من الترقيق وتفخم.'],
        ['type' => QuestionType::PICK_THE_INTRUDER, 'q' => 'أي كلمة من هذه الكلمات يرقق ورش راءها؟', 'opts' => ['قِرطاس', 'فِرعون', 'مِرصاداً'], 'correct' => 'فِرعون', 'exp' => 'فرعون ترقق لوقوعها بعد كسرة أصلية وليس بعدها حرف استعلاء.'],
    ],
    'اللامات' => [
        ['type' => QuestionType::MULTIPLE_CHOICES, 'q' => 'متى يغلظ ورش اللام المفتوحة؟', 'opts' => ['إذا سبقت بكسرة', 'إذا سبقت بصاد أو طاء أو ظاء (مفتوحة أو ساكنة)', 'إذا وقعت بعد ياء ساكنة'], 'correct' => 'إذا سبقت بصاد أو طاء أو ظاء (مفتوحة أو ساكنة)', 'exp' => 'شروط التغليظ هي وقوعها بعد حروف الإطباق الثلاثة.'],
        ['type' => QuestionType::TRUE_OR_FALSE, 'q' => "يغلظ ورش اللام في كلمة (فصلت) لوقوعها بعد صاد ساكنة.", 'a' => 'صحيح', 'exp' => 'الصاد الساكنة توجب التغليظ لورش.'],
        ['type' => QuestionType::FILL_IN_THE_BLANKS, 'q' => "يمتنع تغليظ اللام عند ورش إذا كانت اللام ____.", 'a' => 'مضمومة', 'exp' => 'يشترط في اللام المغلظة أن تكون مفتوحة.'],
    ],
    'مد البدل' => [
        ['type' => QuestionType::MULTIPLE_CHOICES, 'q' => 'ما هي أوجه مد البدل (نحو: آمنوا) عند ورش؟', 'opts' => ['القصر فقط', 'التوسط فقط', 'القصر والتوسط والإشباع'], 'correct' => 'القصر والتوسط والإشباع', 'exp' => 'لورش تثليث البدل (2-4-6 حركات).'],
        ['type' => QuestionType::TRUE_OR_FALSE, 'q' => "يجوز لورش مد (يؤاخذكم) بـ 6 حركات.", 'a' => 'خطأ', 'exp' => 'كلمة (يؤاخذ) مستثناة من البدل لورش وتقرأ بالقصر فقط.'],
        ['type' => QuestionType::PICK_THE_INTRUDER, 'q' => 'أي من هذه الكلمات يمتنع فيها تثليث البدل لورش؟', 'opts' => ['آدم', 'إسرائيل', 'إيماناً'], 'correct' => 'إسرائيل', 'exp' => 'كلمة إسرائيل مستثناة من مد البدل.'],
    ],
    'النقل والهمز' => [
        ['type' => QuestionType::FILL_IN_THE_BLANKS, 'q' => "يقرأ ورش (مَن آمن) بنقل حركة الهمزة فتصبح: ____.", 'a' => 'مَنَ اَمن', 'exp' => 'ورش ينقل حركة الهمزة للساكن قبلها ويحذف الهمزة.'],
        ['type' => QuestionType::TRUE_OR_FALSE, 'q' => 'يبدل ورش الهمزة الساكنة إذا وقعت فاء للكلمة حرف مد.', 'a' => 'صحيح', 'exp' => 'مثل (يؤمنون) تقرأ (يومننون).'],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'q' => "ما حكم الهمزة الثانية في (أأنذرتهم) لورش؟", 'opts' => ['التحقيق', 'التسهيل أو الإبدال ألفاً مع الإشباع'], 'correct' => 'التسهيل أو الإبدال ألفاً مع الإشباع', 'exp' => 'قواعد الهمزتين من كلمة لورش.'],
    ],
    'التحريرات' => [
        ['type' => QuestionType::MULTIPLE_CHOICES, 'q' => 'إذا قرأت لورش بقصر البدل، فما حكم ذوات الياء (مثل: موسى)؟', 'opts' => ['الفتح فقط', 'التقليل فقط', 'الفتح والتقليل'], 'correct' => 'الفتح فقط', 'exp' => 'على قصر البدل يمتنع التقليل في ذوات الياء.'],
        ['type' => QuestionType::TRUE_OR_FALSE, 'q' => 'على إشباع البدل (6 حركات)، يجوز في ذوات الياء الفتح والتقليل.', 'a' => 'صحيح', 'exp' => 'الإشباع في البدل يوافقه الفتح والتقليل في ذوات الياء.'],
    ],
];

$units = App\Models\Unit::with('chapters')->get();

foreach ($units as $unit) {
    echo "Processing Unit: " . $unit->name . "\n";
    
    $unitTopic = 'default';
    foreach (array_keys($proQuestions) as $topic) {
        if (mb_stripos($unit->name, $topic) !== false) {
            $unitTopic = $topic;
            break;
        }
    }

    // Advanced Mapping for missing specific terms
    if ($unitTopic === 'default') {
        if (str_contains($unit->name, 'الإدغام') || str_contains($unit->name, 'النون')) $unitTopic = 'النون والتنوين';
        elseif (str_contains($unit->name, 'المد') || str_contains($unit->name, 'البدل')) $unitTopic = 'مد البدل';
        elseif (str_contains($unit->name, 'الهمز') || str_contains($unit->name, 'النقل')) $unitTopic = 'النقل والهمز';
        elseif (str_contains($unit->name, 'الفتح') || str_contains($unit->name, 'التقليل')) $unitTopic = 'التحريرات';
        elseif (str_contains($unit->name, 'التحريرات')) $unitTopic = 'التحريرات';
    }

    $questionsData = $proQuestions[$unitTopic] ?? $proQuestions['الاستعاذة'];
    $exerciseChapters = $unit->chapters()->where('type', 'exercise')->get();

    foreach ($exerciseChapters as $chapter) {
        echo "    - Seeding Professional Mastery: " . $chapter->name . "\n";
        
        // Seed 15 professional questions per chapter for high volume and mastery
        for ($i = 0; $i < 15; $i++) {
            $q = $questionsData[$i % count($questionsData)];
            
            $options = [];
            if ($q['type'] === QuestionType::TRUE_OR_FALSE) {
                $options = [
                    ['id' => 1, 'text' => 'صحيح', 'is_correct' => ($q['a'] === 'صحيح')],
                    ['id' => 2, 'text' => 'خطأ', 'is_correct' => ($q['a'] === 'خطأ')],
                ];
            } elseif ($q['type'] === QuestionType::MULTIPLE_CHOICES || $q['type'] === QuestionType::PICK_THE_INTRUDER) {
                $opts = $q['opts'] ?? ['خيار أ', 'خيار ب', 'خيار ج'];
                $correct = $q['correct'] ?? 'خيار أ';
                foreach ($opts as $oIdx => $opt) {
                    $options[] = ['id' => $oIdx + 1, 'text' => $opt, 'is_correct' => ($opt === $correct)];
                }
            } elseif ($q['type'] === QuestionType::FILL_IN_THE_BLANKS) {
                $options = [['id' => 1, 'text' => $q['a'], 'is_correct' => true]];
            } elseif ($q['type'] === QuestionType::MATCH_WITH_ARROWS) {
                foreach ($q['pairs'] as $pIdx => $pair) {
                    $options[] = ['id' => $pIdx + 1, 'left' => $pair[0], 'right' => $pair[1], 'is_correct' => true];
                }
            }

            $question = Question::create([
                'question' => $q['q'],
                'question_type' => $q['type'],
                'options' => $options,
                'explanation_text' => $q['exp'],
                'scope' => QuestionScope::EXERCICE,
            ]);

            $chapter->questions()->attach($question->id, ['sort' => $i + 1]);
        }
    }
}

echo "\nProfessional Mastery Seeding Completed Successfully! All questions are now Expert-Grade.\n";
