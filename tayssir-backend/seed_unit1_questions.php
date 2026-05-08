<?php

use App\Models\Question;
use App\Models\Chapter;
use App\Enums\QuestionType;
use App\Enums\QuestionScope;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "Seeding Concise Unit 1 Questions...\n";

$questions = [
    // Chapter 464: تحدي: اختر الوجه الصحيح للاستعاذة في المواقف المختلفة
    [
        'chapter_id' => 464,
        'type' => QuestionType::TRUE_OR_FALSE,
        'q' => 'السكت لورش يكون بأخذ نفس.',
        'options' => [
            ['id' => 1, 'text' => 'صحيح', 'is_correct' => false],
            ['id' => 2, 'text' => 'خطأ', 'is_correct' => true],
        ],
        'explanation' => 'السكت هو وقفة لطيفة بدون تنفس.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::TRUE_OR_FALSE,
        'q' => 'يجوز لورش الوصل بين سورتين بدون بسملة.',
        'options' => [
            ['id' => 1, 'text' => 'صحيح', 'is_correct' => true],
            ['id' => 2, 'text' => 'خطأ', 'is_correct' => false],
        ],
        'explanation' => 'الوصل بدون بسملة هو أحد أوجه ورش الثلاثة.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'الوجه المقدم لورش بين السورتين هو:',
        'options' => [
            ['id' => 1, 'text' => 'السكت', 'is_correct' => true],
            ['id' => 2, 'text' => 'الوصل', 'is_correct' => false],
            ['id' => 3, 'text' => 'البسملة', 'is_correct' => false],
        ],
        'explanation' => 'السكت هو الوجه المختار والمقدم في الأداء عند ورش.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'حكم بداية سورة التوبة لورش:',
        'options' => [
            ['id' => 1, 'text' => 'استعاذة فقط', 'is_correct' => true],
            ['id' => 2, 'text' => 'بسملة فقط', 'is_correct' => false],
            ['id' => 3, 'text' => 'استعاذة وبسملة', 'is_correct' => false],
        ],
        'explanation' => 'سورة التوبة لا تبدأ بالبسملة عند جميع القراء.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'الوجه الممنوع عند الجميع في البسملة:',
        'options' => [
            ['id' => 1, 'text' => 'وصلها بآخر السورة فقط والوقف', 'is_correct' => true],
            ['id' => 2, 'text' => 'وصل الجميع', 'is_correct' => false],
            ['id' => 3, 'text' => 'قطع الجميع', 'is_correct' => false],
        ],
        'explanation' => 'لا يجوز وصل البسملة بآخر السورة السابقة ثم الوقف عليها.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::PICK_THE_INTRUDER,
        'q' => 'سورة لا تبدأ بالبسملة أبداً:',
        'options' => [
            ['id' => 1, 'text' => 'الفاتحة', 'is_correct' => false],
            ['id' => 2, 'text' => 'الناس', 'is_correct' => false],
            ['id' => 3, 'text' => 'التوبة', 'is_correct' => true],
            ['id' => 4, 'text' => 'الفلق', 'is_correct' => false],
        ],
        'explanation' => 'سورة التوبة (براءة) هي السورة الوحيدة الخالية من البسملة.'
    ],

    // Chapter 466: اكتشف الخطأ: قارئ وصل بين السورتين بوجه ممنوع — حدّد الخطأ
    [
        'chapter_id' => 466,
        'type' => QuestionType::FILL_IN_THE_BLANKS,
        'q' => 'السكت وقفة لطيفة بدون ____.',
        'options' => [
            ['id' => 1, 'text' => 'تنفس', 'is_correct' => true],
        ],
        'explanation' => 'السكت يمتاز عن الوقف بأنه يكون بدون تنفس.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::FILL_IN_THE_BLANKS,
        'q' => 'عدد أوجه ورش بين السورتين: ____.',
        'options' => [
            ['id' => 1, 'text' => 'ثلاثة', 'is_correct' => true],
        ],
        'explanation' => 'أوجه ورش هي: السكت، والوصل، والبسملة.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::PICK_THE_INTRUDER,
        'q' => 'ليست من أوجه ورش بين السورتين:',
        'options' => [
            ['id' => 1, 'text' => 'السكت', 'is_correct' => false],
            ['id' => 2, 'text' => 'الوصل', 'is_correct' => false],
            ['id' => 3, 'text' => 'السكت بنفس', 'is_correct' => true],
        ],
        'explanation' => 'لا يوجد وجه يسمى السكت بنفس، فالسكت دائماً بدون تنفس.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'عند وصل الناس بالفاتحة (ختم القرآن):',
        'options' => [
            ['id' => 1, 'text' => 'البسملة وجوباً', 'is_correct' => true],
            ['id' => 2, 'text' => 'السكت', 'is_correct' => false],
            ['id' => 3, 'text' => 'الوصل بدون بسملة', 'is_correct' => false],
        ],
        'explanation' => 'إذا لم تكن السور مرتبة (كالفاتحة بعد الناس) تتعين البسملة.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::MATCH_WITH_ARROWS,
        'q' => 'اربط الحالة بالحكم الصحيح:',
        'options' => [
            ['id' => 1, 'left' => 'الأنفال والتوبة', 'right' => 'لا بسملة', 'is_correct' => true],
            ['id' => 2, 'left' => 'سورتين مرتبتين', 'right' => 'ثلاثة أوجه', 'is_correct' => true],
        ],
        'explanation' => 'بين الأنفال والتوبة لا توجد بسملة اتفاقاً، بينما بين السور الأخرى لورش ٣ أوجه.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'زمن السكت لورش تقريباً:',
        'options' => [
            ['id' => 1, 'text' => 'حركتان', 'is_correct' => true],
            ['id' => 2, 'text' => '4 حركات', 'is_correct' => false],
            ['id' => 3, 'text' => '6 حركات', 'is_correct' => false],
        ],
        'explanation' => 'السكت وقفة يسيرة تقدر بحركتين تقريباً.'
    ],
    // --- Additional 12 Questions ---
    [
        'chapter_id' => 464,
        'type' => QuestionType::TRUE_OR_FALSE,
        'q' => 'البسملة واجبة في أول سورة التوبة.',
        'options' => [
            ['id' => 1, 'text' => 'صحيح', 'is_correct' => false],
            ['id' => 2, 'text' => 'خطأ', 'is_correct' => true],
        ],
        'explanation' => 'سورة التوبة لا تبدأ بالبسملة اتفاقاً.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'إذا بدأت من وسط السورة، فالبسملة لك:',
        'options' => [
            ['id' => 1, 'text' => 'مستحبة (مخيرة)', 'is_correct' => true],
            ['id' => 2, 'text' => 'واجبة', 'is_correct' => false],
            ['id' => 3, 'text' => 'ممنوعة', 'is_correct' => false],
        ],
        'explanation' => 'البسملة في أجزاء السورة مستحبة للقارئ.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'الوصل بين السورتين لورش يكون:',
        'options' => [
            ['id' => 1, 'text' => 'بدون بسملة', 'is_correct' => true],
            ['id' => 2, 'text' => 'ببسملة وجوباً', 'is_correct' => false],
        ],
        'explanation' => 'الوصل هو أحد الأوجه التي يترك فيها ورش البسملة.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::TRUE_OR_FALSE,
        'q' => 'الاستعاذة مستحبة عند جمهور القراء.',
        'options' => [
            ['id' => 1, 'text' => 'صحيح', 'is_correct' => true],
            ['id' => 2, 'text' => 'خطأ', 'is_correct' => false],
        ],
        'explanation' => 'الاستعاذة مستحبة لقوله تعالى: فاستعذ بالله.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::PICK_THE_INTRUDER,
        'q' => 'ليست من صيغ الاستعاذة المشهورة:',
        'options' => [
            ['id' => 1, 'text' => 'أعوذ بالله من الشيطان الرجيم', 'is_correct' => false],
            ['id' => 2, 'text' => 'أعوذ بالله السميع العليم', 'is_correct' => false],
            ['id' => 3, 'text' => 'سبحان الله وبحمده', 'is_correct' => true],
        ],
        'explanation' => 'سبحان الله وبحمده هو ذكر وتسبيح وليس استعاذة.'
    ],
    [
        'chapter_id' => 464,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'يُسر بالاستعاذة في هذه الحالة:',
        'options' => [
            ['id' => 1, 'text' => 'في الصلاة السرية', 'is_correct' => true],
            ['id' => 2, 'text' => 'في المحافل العامة', 'is_correct' => false],
            ['id' => 3, 'text' => 'في التعليم الجهرية', 'is_correct' => false],
        ],
        'explanation' => 'يسر بالاستعاذة في الصلاة وفي القراءة المنفردة سراً.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::FILL_IN_THE_BLANKS,
        'q' => 'التعوذ يكون ____ القراءة.',
        'options' => [
            ['id' => 1, 'text' => 'قبل', 'is_correct' => true],
        ],
        'explanation' => 'الاستعاذة تكون قبل الشروع في القراءة.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::MATCH_WITH_ARROWS,
        'q' => 'اربط كل حالة بنوع القراءة:',
        'options' => [
            ['id' => 1, 'left' => 'الجهر بالاستعاذة', 'right' => 'القراءة الجهرية', 'is_correct' => true],
            ['id' => 2, 'left' => 'الإسرار بالاستعاذة', 'right' => 'الصلاة السرية', 'is_correct' => true],
        ],
        'explanation' => 'يتبع حال الاستعاذة حال القراءة من جهر أو إسرار.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'إذا قطع القارئ قراءته لعطاس ضروري:',
        'options' => [
            ['id' => 1, 'text' => 'لا يعيد الاستعاذة', 'is_correct' => true],
            ['id' => 2, 'text' => 'يعيد الاستعاذة وجوباً', 'is_correct' => false],
        ],
        'explanation' => 'القطع الضروري لا يستوجب إعادة الاستعاذة.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::FILL_IN_THE_BLANKS,
        'q' => 'حكم البسملة في أوائل السور (غير التوبة): ____.',
        'options' => [
            ['id' => 1, 'text' => 'واجبة', 'is_correct' => true],
        ],
        'explanation' => 'البسملة واجبة في فواتح السور لجميع القراء عدا التوبة.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::MULTIPLE_CHOICES,
        'q' => 'وصل البسملة بأول السورة والوقف عليها:',
        'options' => [
            ['id' => 1, 'text' => 'جائز', 'is_correct' => true],
            ['id' => 2, 'text' => 'ممنوع', 'is_correct' => false],
        ],
        'explanation' => 'يجوز قطع الجميع أو وصل البسملة ببداية السورة.'
    ],
    [
        'chapter_id' => 466,
        'type' => QuestionType::TRUE_OR_FALSE,
        'q' => 'يجوز لورش البسملة بين السورتين.',
        'options' => [
            ['id' => 1, 'text' => 'صحيح', 'is_correct' => true],
            ['id' => 2, 'text' => 'خطأ', 'is_correct' => false],
        ],
        'explanation' => 'البسملة هي الوجه الثالث لورش بين السورتين.'
    ],
];

foreach ($questions as $qData) {
    $question = Question::create([
        'question' => $qData['q'],
        'question_type' => $qData['type'],
        'options' => $qData['options'],
        'explanation_text' => $qData['explanation'],
        'scope' => QuestionScope::EXERCICE,
    ]);

    $chapter = Chapter::find($qData['chapter_id']);
    if ($chapter) {
        $chapter->questions()->attach($question->id, ['sort' => 1]);
        echo "Created question: " . $qData['q'] . "\n";
    }
}

echo "Seeding completed successfully!\n";
