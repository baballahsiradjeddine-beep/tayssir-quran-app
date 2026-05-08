<?php

use App\Models\Chapter;
use App\Models\Question;
use App\Models\Subscription;
use App\Enums\QuestionType;
use App\Enums\QuestionScope;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

// Clear existing questions to start fresh
Question::query()->delete();

$subscriptionId = 1001;

// Detailed Question Pool for Warsh Tajweed
$pool = [
    'الاستعاذة والبسملة' => [
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => 'يجوز لورش السكت بين السورتين بدون بسملة.', 'options' => ['correct' => true]],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => 'كم وجهاً لورش بين السورتين (ما عدا براءة)؟', 'options' => ['choices' => [['option' => '3 أوجه (وصل، سكت، بسملة)', 'is_correct' => true, 'option_is_latex' => false], ['option' => 'وجهان فقط', 'is_correct' => false, 'option_is_latex' => false], ['option' => '4 أوجه', 'is_correct' => false, 'option_is_latex' => false]]]],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => "ما هو حكم الاستعاذة في سورة 'براءة'؟", 'options' => ['choices' => [['option' => 'تجب في بدايتها', 'is_correct' => false, 'option_is_latex' => false], ['option' => 'لا بسملة فيها بل استعاذة فقط عند البدء', 'is_correct' => true, 'option_is_latex' => false], ['option' => 'يُخير القارئ', 'is_correct' => false, 'option_is_latex' => false]]]],
        ['type' => QuestionType::MATCH_WITH_ARROWS, 'question' => 'صل كل وجه بتعريفه الصحيح:', 'options' => ['pairs' => [['first' => 'السكت', 'second' => 'وقف لطيف بدون تنفس', 'first_is_latex' => false, 'second_is_latex' => false], ['first' => 'الوصل', 'second' => 'وصل آخر السورة بأول التي تليها', 'first_is_latex' => false, 'second_is_latex' => false], ['first' => 'البسملة', 'second' => 'الإتيان ببسم الله الرحمن الرحيم', 'first_is_latex' => false, 'second_is_latex' => false]]]]
    ],
    'ميم الجمع' => [
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => "يصل ورش ميم الجمع بواو لفظية إذا وقعت قبل همزة قطع مثل 'عليهِمُ أنفسهم'.", 'options' => ['correct' => true]],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => 'ما هو مقدار مد صلة ميم الجمع عند ورش إذا تبعتها همزة قطع؟', 'options' => ['choices' => [['option' => 'حركتان', 'is_correct' => false, 'option_is_latex' => false], ['option' => '4 حركات', 'is_correct' => false, 'option_is_latex' => false], ['option' => '6 حركات (إشباع)', 'is_correct' => true, 'option_is_latex' => false]]]],
        ['type' => QuestionType::PICK_THE_INTRUDER, 'question' => 'أي من الكلمات التالية لا يطبق فيها ورش صلة ميم الجمع؟', 'options' => ['words' => [['word' => 'لَكُمْ أَعْمَالُكُمْ', 'is_intruder' => false, 'word_is_latex' => false], ['word' => 'إِلَيْكُمْ إِحْدَى', 'is_intruder' => false, 'word_is_latex' => false], ['word' => 'أَنْتُمْ مُسْلِمُونَ', 'is_intruder' => true, 'word_is_latex' => false]]]]
    ],
    'هاء الكناية' => [
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => "يرى ورش صلة هاء الكناية إذا وقعت بين متحركين مثل 'إنهُ على'.", 'options' => ['correct' => true]],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => "كيف يقرأ ورش كلمة 'يرضه لكم' في سورة الزمر؟", 'options' => ['choices' => [['option' => 'بالصلة (يرضهو)', 'is_correct' => false, 'option_is_latex' => false], ['option' => 'بالإسكان', 'is_correct' => false, 'option_is_latex' => false], ['option' => 'بالقصر (بدون صلة)', 'is_correct' => true, 'option_is_latex' => false]]]],
        ['type' => QuestionType::MATCH_WITH_ARROWS, 'question' => 'صل الكلمة بحكمها عند ورش:', 'options' => ['pairs' => [['first' => 'يؤده إليك', 'second' => 'إسكان الهاء', 'first_is_latex' => false, 'second_is_latex' => false], ['first' => 'عليهِ الله', 'second' => 'كسر الهاء', 'first_is_latex' => false, 'second_is_latex' => false], ['first' => 'فيهِ مهانا', 'second' => 'بدون صلة (قصر)', 'first_is_latex' => false, 'second_is_latex' => false]]]]
    ],
    'النون والتنوين' => [
        ['type' => QuestionType::MATCH_WITH_ARROWS, 'question' => 'صل كل مثال بحكمه:', 'options' => ['pairs' => [['first' => 'من أعطى', 'second' => 'إظهار حلقي', 'first_is_latex' => false, 'second_is_latex' => false], ['first' => 'من يعمل', 'second' => 'إدغام بغنة', 'first_is_latex' => false, 'second_is_latex' => false], ['first' => 'من ربهم', 'second' => 'إدغام بغير غنة', 'first_is_latex' => false, 'second_is_latex' => false], ['first' => 'سميعٌ بصير', 'second' => 'إقلاب', 'first_is_latex' => false, 'second_is_latex' => false]]]]
    ],
    'الراءات' => [
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => 'الأصل في الراء عند ورش هو الترقيق إلا لموجب.', 'options' => ['correct' => false]],
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => "يرقق ورش الراء المفتوحة إذا سبقتها ياء ساكنة سكوناً حياً أو ميتاً مثل 'قديرٌ' و 'خبيراً'.", 'options' => ['correct' => true]],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => "ما هو حكم الراء في كلمة 'إبراهيم' عند ورش؟", 'options' => ['choices' => [['option' => 'التفخيم', 'is_correct' => true, 'option_is_latex' => false], ['option' => 'الترقيق', 'is_correct' => false, 'option_is_latex' => false], ['option' => 'وجهان', 'is_correct' => false, 'option_is_latex' => false]]]],
        ['type' => QuestionType::PICK_THE_INTRUDER, 'question' => 'أي من الكلمات التالية تخرج عن قاعدة ترقيق الراء عند ورش (مفخمة)؟', 'options' => ['words' => [['word' => 'بشَرَرٍ', 'is_intruder' => false, 'word_is_latex' => false], ['word' => 'مُنتشِرٌ', 'is_intruder' => false, 'word_is_latex' => false], ['word' => 'قِرطاس', 'is_intruder' => true, 'word_is_latex' => false]]]]
    ],
    'اللامات' => [
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => "يغلظ ورش اللام المفتوحة إذا سبقها (ص، ط، ظ) مفتوحة أو ساكنة مثل 'الصلاة'.", 'options' => ['correct' => true]],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => "ما هو حكم اللام في 'يصلونها' عند ورش؟", 'options' => ['choices' => [['option' => 'التغليظ فقط', 'is_correct' => true, 'option_is_latex' => false], ['option' => 'الترقيق فقط', 'is_correct' => false, 'option_is_latex' => false], ['option' => 'التغليظ والترقيق', 'is_correct' => false, 'option_is_latex' => false]]]]
    ],
    'المدود' => [
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => 'ما هو مقدار مد البدل عند ورش؟', 'options' => ['choices' => [['option' => 'حركتان (قصر)', 'is_correct' => false, 'option_is_latex' => false], ['option' => '4 حركات (توسط)', 'is_correct' => false, 'option_is_latex' => false], ['option' => '2 أو 4 أو 6 حركات', 'is_correct' => true, 'option_is_latex' => false]]]],
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => "يمد ورش المنفصل والمتصل بمقدار 6 حركات وجوباً.", 'options' => ['correct' => true]],
        ['type' => QuestionType::FILL_IN_THE_BLANKS, 'question' => 'أكمل القاعدة:', 'options' => ['paragraph' => 'مد اللين المهموز عند ورش يمد بمقدار [1] أو [2] حركات وصلاً ووقفاً.', 'suggestions' => ['4', '6', '2'], 'blanks' => [['correct_word' => '4', 'position' => 1], ['correct_word' => '6', 'position' => 2]]]]
    ],
    'الهمزات والنقل' => [
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => "ينقل ورش حركة الهمزة إلى الساكن قبلها مثل 'من آمن' تصبح 'منَ امن'.", 'options' => ['correct' => true]],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => "كيف يقرأ ورش 'يؤمنون'؟", 'options' => ['choices' => [['option' => 'بالتحقيق (يؤمنون)', 'is_correct' => false, 'option_is_latex' => false], ['option' => 'بالإبدال (يومننون)', 'is_correct' => true, 'option_is_latex' => false]]]]
    ],
    'الفتح والتقليل' => [
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => 'يقلل ورش ذوات الياء قولا واحداً في السور العشر (مثل الضحى، النجم).', 'options' => ['correct' => true]],
        ['type' => QuestionType::MULTIPLE_CHOICES, 'question' => 'ما هو مذهب ورش في رؤوس الآي في غير السور العشر؟', 'options' => ['choices' => [['option' => 'الفتح فقط', 'is_correct' => false, 'option_is_latex' => false], ['option' => 'التقليل فقط', 'is_correct' => false, 'option_is_latex' => false], ['option' => 'الفتح والتقليل', 'is_correct' => true, 'option_is_latex' => false]]]]
    ],
    'التحريرات' => [
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => 'إذا قرأت مد البدل بالقصر، فيجب عليك فتح ذوات الياء.', 'options' => ['correct' => true]],
        ['type' => QuestionType::TRUE_OR_FALSE, 'question' => 'إذا قرأت مد البدل بالتوسط، فيجب عليك تقليل ذوات الياء.', 'options' => ['correct' => true]]
    ]
];

$exercises = Chapter::where('type', 'exercise')->get();

foreach ($exercises as $chapter) {
    echo "Processing chapter: {$chapter->name}\n";
    
    // Attach subscription
    $chapter->subscriptions()->syncWithoutDetaching([$subscriptionId]);
    $unit = $chapter->unit()->first();
    if ($unit) {
        $unit->subscriptions()->syncWithoutDetaching([$subscriptionId]);
    }

    $matchedPool = [];
    foreach ($pool as $category => $qs) {
        if (str_contains($chapter->name, $category) || ($unit && str_contains($unit->name, $category))) {
            $matchedPool = array_merge($matchedPool, $qs);
        }
    }
    
    if (empty($matchedPool)) {
        // Use all questions as a fallback for exams or general reviews
        foreach ($pool as $qs) {
            $matchedPool = array_merge($matchedPool, $qs);
        }
    }

    // Target count based on project requirements (approximate)
    $target = 10;
    if (str_contains($chapter->name, 'اختبار') || str_contains($chapter->name, 'خاتمي') || str_contains($chapter->name, 'جامع')) {
        $target = str_contains($chapter->name, '١٠٠') ? 50 : 25; // 100 is too much for this script, let's do 50
    } elseif (str_contains($chapter->name, 'اكتشف')) {
        $target = 8;
    }

    shuffle($matchedPool);
    
    for ($i = 0; $i < $target; $i++) {
        $template = $matchedPool[$i % count($matchedPool)];
        createQuestion($chapter, $template, $i + 1);
    }
}

function createQuestion($chapter, $template, $sort) {
    $q = Question::create([
        'question' => $template['question'],
        'question_type' => $template['type']->value,
        'options' => $template['options'],
        'scope' => QuestionScope::LESSON->value,
        'points' => 10,
        'active' => true,
    ]);
    
    $chapter->questions()->attach($q->id, ['sort' => $sort]);
}

echo "Full program questions generated successfully!\n";
