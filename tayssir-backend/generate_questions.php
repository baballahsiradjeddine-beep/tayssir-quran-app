<?php

use App\Models\Chapter;
use App\Models\Question;
use App\Models\Subscription;
use App\Enums\QuestionType;
use App\Enums\QuestionScope;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$subscriptionId = 1001; // الاشتراك المجاني

// Attach subscriptions to all units and chapters
App\Models\Unit::all()->each(function ($unit) use ($subscriptionId) {
    $unit->subscriptions()->syncWithoutDetaching([$subscriptionId]);
});

Chapter::all()->each(function ($chapter) use ($subscriptionId) {
    $chapter->subscriptions()->syncWithoutDetaching([$subscriptionId]);
});

// Question Templates based on keywords
$templates = [
    'الاستعاذة' => [
        [
            'type' => QuestionType::TRUE_OR_FALSE,
            'question' => 'الاستعاذة واجبة عند بداية كل سورة حتى لو كانت في منتصف القراءة.',
            'options' => ['correct' => true]
        ],
        [
            'type' => QuestionType::MULTIPLE_CHOICES,
            'question' => 'ما هو حكم الاستعاذة عند البدء بالقراءة؟',
            'options' => [
                'choices' => [
                    ['option' => 'واجبة', 'is_correct' => true, 'option_is_latex' => false],
                    ['option' => 'مستحبة', 'is_correct' => false, 'option_is_latex' => false],
                    ['option' => 'محرمة', 'is_correct' => false, 'option_is_latex' => false],
                    ['option' => 'مكروهة', 'is_correct' => false, 'option_is_latex' => false],
                ]
            ]
        ]
    ],
    'البسملة' => [
        [
            'type' => QuestionType::MULTIPLE_CHOICES,
            'question' => 'كم وجهاً لورش في البسملة بين السورتين؟',
            'options' => [
                'choices' => [
                    ['option' => 'وجهان (وصل وسكت)', 'is_correct' => false, 'option_is_latex' => false],
                    ['option' => 'ثلاثة أوجه (وصل وسكت وبسملة)', 'is_correct' => true, 'option_is_latex' => false],
                    ['option' => 'وجه واحد فقط', 'is_correct' => false, 'option_is_latex' => false],
                ]
            ]
        ]
    ],
    'ميم الجمع' => [
        [
            'type' => QuestionType::TRUE_OR_FALSE,
            'question' => 'يصل ورش ميم الجمع إذا وقع بعدها همزة قطع بمقدار 6 حركات.',
            'options' => ['correct' => true]
        ],
        [
            'type' => QuestionType::PICK_THE_INTRUDER,
            'question' => 'اختر الكلمة التي لا تندرج تحت حكم صلة ميم الجمع عند ورش:',
            'options' => [
                'words' => [
                    ['word' => 'عَلَيْكُمُ أَنفُسَكُمْ', 'is_intruder' => false, 'word_is_latex' => false],
                    ['word' => 'إِلَيْكُمُ إِحْدَى', 'is_intruder' => false, 'word_is_latex' => false],
                    ['word' => 'أَنْتُمْ مُسْلِمُونَ', 'is_intruder' => true, 'word_is_latex' => false],
                ]
            ]
        ]
    ],
    'الإظهار' => [
        [
            'type' => QuestionType::PICK_THE_INTRUDER,
            'question' => 'اختر الحرف الذي ليس من حروف الإظهار الحلقي:',
            'options' => [
                'words' => [
                    ['word' => 'ء', 'is_intruder' => false, 'word_is_latex' => false],
                    ['word' => 'ح', 'is_intruder' => false, 'word_is_latex' => false],
                    ['word' => 'خ', 'is_intruder' => false, 'word_is_latex' => false],
                    ['word' => 'ق', 'is_intruder' => true, 'word_is_latex' => false],
                ]
            ]
        ],
        [
            'type' => QuestionType::MATCH_WITH_ARROWS,
            'question' => 'صِل كل مثال بحكمه التجويدي الصحيح:',
            'options' => [
                'pairs' => [
                    ['first' => 'مَنْ آمَنَ', 'second' => 'إظهار حلقي', 'first_is_latex' => false, 'second_is_latex' => false],
                    ['first' => 'مَنْ يَعْمَلْ', 'second' => 'إدغام بغنة', 'first_is_latex' => false, 'second_is_latex' => false],
                    ['first' => 'مِنْ بَعْدِ', 'second' => 'إقلاب', 'first_is_latex' => false, 'second_is_latex' => false],
                ]
            ]
        ]
    ],
    'الإدغام' => [
        [
            'type' => QuestionType::FILL_IN_THE_BLANKS,
            'question' => 'أكمل القاعدة التالية المتعلقة بالإدغام:',
            'options' => [
                'paragraph' => 'يُقسم الإدغام إلى نوعين: إدغام [1] وحروفه مجموعة في كلمة (ينمو)، وإدغام [2] وحروفه هي اللام والراء.',
                'suggestions' => ['بغنة', 'بغير غنة', 'إخفاء'],
                'blanks' => [
                    ['correct_word' => 'بغنة', 'position' => 1],
                    ['correct_word' => 'بغير غنة', 'position' => 2],
                ]
            ]
        ]
    ],
    'الراءات' => [
        [
            'type' => QuestionType::TRUE_OR_FALSE,
            'question' => "يرقق ورش الراء المفتوحة أو المضمومة إذا سبقتها ياء ساكنة مثل 'خبيرٌ'.",
            'options' => ['correct' => true]
        ],
        [
            'type' => QuestionType::MULTIPLE_CHOICES,
            'question' => "ما هو حكم الراء في كلمة 'فِرْعَوْن' عند ورش؟",
            'options' => [
                'choices' => [
                    ['option' => 'التفخيم دائماً', 'is_correct' => false, 'option_is_latex' => false],
                    ['option' => 'الترقيق دائماً', 'is_correct' => true, 'option_is_latex' => false],
                    ['option' => 'جواز الوجهين', 'is_correct' => false, 'option_is_latex' => false],
                ]
            ]
        ]
    ],
    'اللامات' => [
        [
            'type' => QuestionType::TRUE_OR_FALSE,
            'question' => "يغلظ ورش اللام إذا كانت مفتوحة وسبقها حرف الصاد أو الطاء أو الظاء بشرط أن تكون هذه الحروف مفتوحة أو ساكنة.",
            'options' => ['correct' => true]
        ]
    ],
    'مد البدل' => [
        [
            'type' => QuestionType::MULTIPLE_CHOICES,
            'question' => 'ما هي أوجه مد البدل عند ورش؟',
            'options' => [
                'choices' => [
                    ['option' => 'حركتان فقط', 'is_correct' => false, 'option_is_latex' => false],
                    ['option' => '4 حركات فقط', 'is_correct' => false, 'option_is_latex' => false],
                    ['option' => '2 أو 4 أو 6 حركات', 'is_correct' => true, 'option_is_latex' => false],
                ]
            ]
        ]
    ],
    'نقل' => [
        [
            'type' => QuestionType::TRUE_OR_FALSE,
            'question' => "ينفرد ورش بنقل حركة الهمزة إلى الساكن الصحيح قبلها، فيسقط الهمزة ويحرك الساكن بحركتها.",
            'options' => ['correct' => true]
        ]
    ],
    'default' => [
        [
            'type' => QuestionType::TRUE_OR_FALSE,
            'question' => 'رواية ورش عن نافع هي الرواية المعتمدة في بلاد المغرب العربي.',
            'options' => ['correct' => true]
        ],
        [
            'type' => QuestionType::MULTIPLE_CHOICES,
            'question' => 'من هو الإمام الذي روى عنه ورش؟',
            'options' => [
                'choices' => [
                    ['option' => 'الإمام نافع', 'is_correct' => true, 'option_is_latex' => false],
                    ['option' => 'الإمام عاصم', 'is_correct' => false, 'option_is_latex' => false],
                    ['option' => 'الإمام حمزة', 'is_correct' => false, 'option_is_latex' => false],
                ]
            ]
        ]
    ]
];

$exercises = Chapter::where('type', 'exercise')->get();

foreach ($exercises as $chapter) {
    // Determine which templates to use based on name/description
    $matched = false;
    foreach ($templates as $keyword => $chapterTemplates) {
        if ($keyword === 'default') continue;
        if (str_contains($chapter->name, $keyword) || str_contains($chapter->unit->first()?->name ?? '', $keyword)) {
            foreach ($chapterTemplates as $t) {
                createQuestion($chapter, $t);
            }
            $matched = true;
        }
    }
    
    // Add default questions if no match or to increase count
    $defaultPool = $templates['default'];
    $countToAdd = 5 - ($matched ? count($templates['default']) : 0); // Aim for at least 5
    if ($countToAdd > 0) {
        for ($i = 0; $i < $countToAdd; $i++) {
            createQuestion($chapter, $defaultPool[$i % count($defaultPool)]);
        }
    }
}

function createQuestion($chapter, $template) {
    $q = Question::create([
        'question' => $template['question'],
        'question_type' => $template['type']->value,
        'options' => $template['options'],
        'scope' => QuestionScope::LESSON->value,
        'points' => 10,
        'active' => true,
    ]);
    
    $chapter->questions()->attach($q->id, ['sort' => $chapter->questions()->count() + 1]);
}

echo "Questions generated successfully!\n";
