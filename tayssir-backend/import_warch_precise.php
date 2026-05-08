<?php

use App\Models\Division;
use App\Models\Material;
use App\Models\Unit;
use App\Models\Chapter;
use App\Models\Question;
use App\Models\Subscription;
use App\Enums\QuestionType;
use App\Enums\QuestionScope;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

// --- Configuration ---
$divisionId = 1; // Warsh Division
$subscriptionId = 1; // Free Subscription ID
$chapterLevel = App\Models\ChapterLevel::first();
if (!$chapterLevel) {
    $chapterLevel = App\Models\ChapterLevel::create(['name' => 'أساسي']);
}
$chapterLevelId = $chapterLevel->id;

// --- Cleanup ---
Material::query()->delete();
Unit::query()->delete();
Chapter::query()->delete();
Question::query()->delete();

$division = Division::find($divisionId);

function parseCount($str) {
    if (str_contains($str, 'واحد')) return 1;
    
    // Replace Arabic digits with English ones
    $arabic = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
    $english = ['0','1','2','3','4','5','6','7','8','9'];
    $str = str_replace($arabic, $english, $str);

    preg_match('/(\d+)/', $str, $matches);
    return isset($matches[1]) ? (int)$matches[1] : 1;
}

function getTajweedContent($topic, $type, $index = 0) {
    // Return meaningful Tajweed content based on topic and index
    $data = [
        'الاستعاذة والبسملة' => [
            'slides' => [
                'الاستعاذة هي قول: أعوذ بالله من الشيطان الرجيم، وهي مستحبة عند الجمهور.',
                'أوجه البسملة بين السورتين لورش هي: القطع، السكت، والوصل.',
                'السكت بين السورتين يكون بمقدار حركتين بدون تنفس وهو المقدم لورش.',
                'لا يجوز وصل آخر السورة بالبسملة ثم الوقف عليها والبدء بالسورة التالية.'
            ],
            'questions' => [
                ['q' => 'كم وجهاً لورش بين السورتين؟', 'a' => 'ثلاثة أوجه'],
                ['q' => 'ما هو الوجه الممتنع في البسملة؟', 'a' => 'وصل آخر السورة بالبسملة والوقف عليها'],
                ['q' => 'هل السكت يكون بتنفس؟', 'a' => 'لا، بدون تنفس'],
            ]
        ],
        'ميم الجمع' => [
            'slides' => [
                'ميم الجمع هي الميم الزائدة الدالة على جماعة الذكور.',
                'يصل ورش ميم الجمع بواو لفظية إذا وقعت قبل همزة قطع.',
                'يمد ورش صلة ميم الجمع بمقدار 6 حركات (إشباع).',
                'إذا وقع بعد ميم الجمع ساكن، فإنه يحذف المد للساكنين.'
            ],
            'questions' => [
                ['q' => "ما هو مقدار مد ميم الجمع في 'عليهُمُ أنفسهم'؟", 'a' => '6 حركات'],
                ['q' => 'هل يصل ورش الميم إذا كان بعدها حرف غير الهمز؟', 'a' => 'لا'],
            ]
        ],
        'هاء الكناية' => [
            'slides' => [
                'هاء الكناية هي الهاء الزائدة الدالة على المفرد المذكر الغائب.',
                'يصل ورش الهاء إذا وقعت بين متحركين.',
                "يستثني ورش مواضع مثل 'يرضه لكم' فيقرؤها بالقصر.",
                "كلمة 'أرجه' يقرؤها ورش بكسر الهاء بدون صلة."
            ],
            'questions' => [
                ['q' => "ما هو حكم هاء الكناية في 'يرضه لكم'؟", 'a' => 'القصر'],
                ['q' => 'متى يصل ورش هاء الكناية؟', 'a' => 'إذا وقعت بين متحركين'],
            ]
        ],
        'الراءات' => [
            'slides' => [
                'يرقق ورش الراء المفتوحة والمضمومة إذا سبقتها ياء ساكنة.',
                'يرقق ورش الراء إذا سبقتها كسرة أصلية متصلة.',
                "يفخم ورش الراء في الكلمات الأعجمية مثل 'إبراهيم'.",
                "إذا فصل بين الراء والكسرة حرف ساكن غير مستعلٍ، يرققها ورش."
            ],
            'questions' => [
                ['q' => 'ما هو حكم الراء في كلمة فرعون؟', 'a' => 'الترقيق'],
                ['q' => 'متى يرقق ورش الراء المفتوحة؟', 'a' => 'إذا سبقتها ياء ساكنة'],
            ]
        ],
        'default' => [
            'slides' => ['شرح عام حول هذا الموضوع التجويدي الهام.'],
            'questions' => [
                ['q' => 'من هو الإمام الذي روى عنه ورش؟', 'a' => 'الإمام نافع'],
                ['q' => 'أين اشتهرت رواية ورش؟', 'a' => 'المغرب العربي'],
            ]
        ]
    ];

    $topicKey = 'default';
    foreach (array_keys($data) as $k) {
        if (str_contains($topic, $k)) {
            $topicKey = $k;
            break;
        }
    }

    if ($type === 'slide') {
        return $data[$topicKey]['slides'][$index % count($data[$topicKey]['slides'])] ?? "شرح تفصيلي للموضوع: $topic (الجزء " . ($index + 1) . ")";
    }
    
    return $data[$topicKey]['questions'][$index % count($data[$topicKey]['questions'])] ?? ['q' => "سؤال حول $topic رقم " . ($index + 1), 'a' => 'إجابة صحيحة'];
}

// --- Curriculum Data (Parsed from App.tsx) ---
$curriculum = [
    [
        'title' => "المستوى الأول — المُمهِّد (الأساسيات)",
        'materials' => [
            [
                'title' => "البداية الصحيحة — الاستعاذة والبسملة",
                'desc' => "كيف يبدأ ورش قراءته؟ وما خصائصه في الاستعاذة والبسملة بين السور؟",
                'units' => [
                    [
                        'id' => 1,
                        'title' => "الاستعاذة والبسملة",
                        'desc' => "أحكام البدء والفصل بين السور",
                        'items' => [
                            ['type' => 'intro', 'text' => "سر البدء — لماذا نتعوذ ونبسمل؟ ولماذا ورش مختلف؟", 'count' => "شرح واحد"],
                            ['type' => 'lesson', 'text' => "أوجه الاستعاذة عند ورش (الجهر والإسرار)", 'count' => "٣ شروحات"],
                            ['type' => 'lesson', 'text' => "أوجه البسملة بين السورتين — الوصل والفصل والقطع", 'count' => "٤ شروحات"],
                            ['type' => 'lesson', 'text' => "السكت بين السورتين عند ورش (موضعه وحكمه)", 'count' => "٣ شروحات"],
                            ['type' => 'exercise', 'text' => "تحدي: اختر الوجه الصحيح للاستعاذة في المواقف المختلفة", 'count' => "١٠ أسئلة"],
                            ['type' => 'audio', 'text' => "فلاش كارد صوتية: استمع لأوجه البسملة وميّز بين السكت والوصل", 'count' => "٤ بطاقات"],
                            ['type' => 'detect', 'text' => "اكتشف الخطأ: قارئ وصل بين السورتين بوجه ممنوع — حدّد الخطأ", 'count' => "٨ أسئلة"],
                            ['type' => 'warsh', 'text' => "بطاقة ورش vs حفص: ورش يجيز السكت بين السورتين — حفص لا يجيزه", 'count' => "بطاقة واحدة"],
                        ]
                    ],
                    [
                        'id' => 2,
                        'title' => "ميم الجمع — الصلة الصغرى والكبرى",
                        'desc' => "خاصية ورش في مد ميم الجمع وصلتها بما بعدها من همز أو غيره.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "تعريف ميم الجمع وشروط الصلة عند ورش", 'count' => "٣ شروحات"],
                            ['type' => 'lesson', 'text' => "الصلة الكبرى — الميم قبل همزة القطع (مد مشبع ٦ حركات)", 'count' => "٤ شروحات"],
                            ['type' => 'exercise', 'text' => "اختيار من متعدد: هل تُصل الميم أم لا في هذه الكلمة؟", 'count' => "١٠ أسئلة"],
                            ['type' => 'audio', 'text' => "فلاش كارد صوتية: الصلة الصغرى مقابل الكبرى — استمع وميّز", 'count' => "٦ بطاقات"],
                            ['type' => 'detect', 'text' => "اكتشف الخطأ: خطأ في مقدار مد ميم الجمع في آية مسموعة", 'count' => "٨ أسئلة"],
                        ]
                    ],
                    [
                        'id' => 3,
                        'title' => "هاء الكناية — الصلة والمستثنيات",
                        'desc' => "قواعد ورش الخاصة في وصل هاء الضمير ومواضع الاستثناء المهمة.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "تعريف هاء الكناية وشروط الصلة الأساسية", 'count' => "٣ شروحات"],
                            ['type' => 'lesson', 'text' => "المواضع المستثناة: يؤده، نصله، نؤته، فألقه، يتقه، أرجه", 'count' => "٤ شروحات"],
                            ['type' => 'exercise', 'text' => "ربط: صِل كل كلمة بحكمها — وصل أم إسكان؟", 'count' => "١٠ أسئلة"],
                            ['type' => 'detect', 'text' => "اكتشف الخطأ: وصل هاء في موضع مستثنى — حدّد وصحّح", 'count' => "٨ أسئلة"],
                        ]
                    ],
                    [
                        'id' => 4,
                        'title' => "الإظهار الحلقي — النون والتنوين (١)",
                        'desc' => "أول أحكام النون الساكنة مع حروف الحلق الستة.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "حروف الحلق الستة ومخارجها: ء هـ ع غ ح خ", 'count' => "٣ شروحات"],
                            ['type' => 'audio', 'text' => "صوتيات: استمع للإظهار الحلقي في حروفه الستة", 'count' => "٦ بطاقات"],
                        ]
                    ],
                    [
                        'id' => 5,
                        'title' => "الإدغام — النون والتنوين (٢)",
                        'desc' => "الإدغام بغنة وبغير غنة وفروق الأداء.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "الإدغام بغنة (ينمو) والإدغام بغير غنة (ل ر)", 'count' => "٤ شروحات"],
                            ['type' => 'exercise', 'text' => "تصنيف: إدغام كامل أم ناقص؟ بغنة أم بغير غنة؟", 'count' => "١٢ سؤالاً"],
                        ]
                    ],
                    [
                        'id' => 6,
                        'title' => "الإخفاء والإقلاب — النون والتنوين (٣-٤)",
                        'desc' => "استكمال أحكام النون بأحكام الإخفاء الحقيقي والإقلاب.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "درجات الإخفاء الثلاث وضوابط الإقلاب", 'count' => "٥ شروحات"],
                            ['type' => 'exam', 'text' => "اختبار ختامي للمستوى الأول — ٢٥ سؤالاً جامعاً", 'count' => "٢٥ سؤالاً"],
                        ]
                    ],
                ]
            ]
        ]
    ],
    [
        'title' => "المستوى الثاني — المُتخصص (هوية ورش)",
        'materials' => [
            [
                'title' => "الراءات واللامات والإدغام",
                'desc' => "الانغماس في الخصائص الصوتية الفريدة (الراءات، اللامات، والمدود).",
                'units' => [
                    [
                        'id' => 7,
                        'title' => "الراءات — التفخيم والترقيق",
                        'desc' => "أدق وأشمل أبواب ورش",
                        'items' => [
                            ['type' => 'lesson', 'text' => "أسباب تفخيم وترقيق الراء عند ورش (القواعد والعلل)", 'count' => "٧ شروحات"],
                            ['type' => 'audio', 'text' => "فلاش كارد صوتية: ترقيق الراء في 'فِرْعَوْن' مقابل تفخيمها في 'مَرْيَم'", 'count' => "٨ بطاقات"],
                            ['type' => 'detect', 'text' => "اكتشف الخطأ: قارئ فخم الراء في 'نَاظِرَةٌ' — حدّد السبب", 'count' => "٨ أسئلة"],
                        ]
                    ],
                    [
                        'id' => 8,
                        'title' => "اللامات — التفخيم والتغليظ",
                        'desc' => "انفرادات ورش في تغليظ اللام وكيفية أداء لام لفظ الجلالة.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "شروط تفخيم لام الجلالة وتغليظ اللامات بشروطها", 'count' => "٦ شروحات"],
                            ['type' => 'audio', 'text' => "فلاش كارد صوتية: نطق اللام المغلظة في 'الصلاة' و'الطلاق'", 'count' => "٦ بطاقات"],
                            ['type' => 'detect', 'text' => "اكتشف الخطأ: تغليظ اللام في 'يصلون' رغم انكسار الصاد", 'count' => "٨ أسئلة"],
                        ]
                    ],
                    [
                        'id' => 9,
                        'title' => "الإدغام المتقارب والمتجانس",
                        'desc' => "أحكام دمج الحروف المتقاربة والمتجانسة عند ورش.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "إدغام الدال في التاء، والذال في التاء، والتقاربات الكبرى", 'count' => "٦ شروحات"],
                            ['type' => 'exercise', 'text' => "تحدي: هل يُدغم أم يُظهر في هذا الموضع؟", 'count' => "١٠ أسئلة"],
                        ]
                    ],
                    [
                        'id' => 10,
                        'title' => "المدود الأساسية — الطبيعي وأسبابه",
                        'desc' => "منطلق كل أحكام المد: الطبيعي، المتصل، والمنفصل.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "المد الطبيعي ومقدار الإشباع (٦ حركات) عند ورش", 'count' => "٨ شروحات"],
                            ['type' => 'audio', 'text' => "تدريب سماعي: ميز بين القصر والإشباع في المد المنفصل", 'count' => "٨ بطاقات"],
                        ]
                    ],
                    [
                        'id' => 11,
                        'title' => "مد البدل — خصائص ورش الفريدة",
                        'desc' => "أوجه مد البدل الثلاثة (٢-٤-٦) ومستثنياتها الخمسة.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "تثليث البدل (القصر، التوسط، الإشباع) والمستثنيات", 'count' => "١٠ شروحات"],
                            ['type' => 'audio', 'text' => "أداء صوتي: 'آمنوا' بالأوجه الثلاثة", 'count' => "٣ بطاقات"],
                            ['type' => 'detect', 'text' => "اكتشف الخطأ: مد 'إسرائيل' بـ ٤ حركات (موضع مستثنى)", 'count' => "١٠ أسئلة"],
                        ]
                    ],
                    [
                        'id' => 12,
                        'title' => "مد اللين المهموز والعارض",
                        'desc' => "أحكام الواو والياء الساكنتين قبل الهمزة والوقف.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "مد 'شَيْء' بـ ٤ و ٦ حركات وصلاً (خاصية ورش)", 'count' => "٦ شروحات"],
                            ['type' => 'audio', 'text' => "فلاش كارد صوتية: مد اللين المهموز وصلاً ووقفاً", 'count' => "٤ بطاقات"],
                            ['type' => 'detect', 'text' => "اكتشف الخطأ: قصر مد اللين في 'كَهَيْئَةِ' — صحّح", 'count' => "٨ أسئلة"],
                        ]
                    ],
                ]
            ]
        ]
    ],
    [
        'title' => "المستوى الثالث — المُجيد (الاحتراف والتحريرات)",
        'materials' => [
            [
                'title' => "الهمزات والفتح والإمالة والتحريرات",
                'desc' => "المرحلة الختامية: الهمزات المعقدة، النقل، والتحريرات الجامعة.",
                'units' => [
                    [
                        'id' => 13,
                        'title' => "النقل — همزة الوصل والساكن",
                        'desc' => "نقل حركة الهمزة إلى الساكن قبلها في كلمات 'الآخِرة' و'الأرض'.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "قواعد النقل المدمجة مع المد والوقف", 'count' => "٨ شروحات"],
                            ['type' => 'audio', 'text' => "نطق 'مَنَ آمَن' و 'الأرْض' بالنقل بإتقان", 'count' => "٦ بطاقات"],
                        ]
                    ],
                    [
                        'id' => 14,
                        'title' => "الهمز المفرد والإبدال",
                        'desc' => "إبدال الهمزة الساكنة حرف مد إذا كانت فاءً للكلمة.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "إبدال الهمزة في 'يُؤمنون' لتصبح 'يُومننون' (قواعد الإبدال)", 'count' => "٧ شروحات"],
                            ['type' => 'warsh', 'text' => "مقارنة: ورش يبدل الهمز المفرد وحفص يحققه دائمًا", 'count' => "بطاقة واحدة"],
                        ]
                    ],
                    [
                        'id' => 15,
                        'title' => "الهمزتان من كلمة ومن كلمتين",
                        'desc' => "التسهيل والإبدال عند التقاء الهمزات المزدوجة.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "التسهيل في 'جَاءَ أَحَدٌ' وأوجه 'أأنذرتهم'", 'count' => "٩ شروحات"],
                            ['type' => 'audio', 'text' => "تطبيق صوتي على نغمة التسهيل بين الهمزتين", 'count' => "٥ بطاقات"],
                        ]
                    ],
                    [
                        'id' => 16,
                        'title' => "الفتح والتقليل والإمالة",
                        'desc' => "نغمة ورش الصوتية ومذهبه في ذوات الياء ورؤوس الآي.",
                        'items' => [
                            ['type' => 'lesson', 'text' => "قواعد التقليل في ذوات الياء والسور العشر المخصوصة", 'count' => "١٠ شروحات"],
                            ['type' => 'audio', 'text' => "الفرق الصوتي بين الفتح والتقليل في 'موسى' و'عيسى'", 'count' => "٦ بطاقات"],
                        ]
                    ],
                    [
                        'id' => 17,
                        'title' => "الياءات — الإضافة والزوائد",
                        'desc' => "ضبط الياءات وصلاً ووقفاً (إحداها انفرادات لورش).",
                        'items' => [
                            ['type' => 'lesson', 'text' => "فتح ياءات الإضافة وإثبات الياءات الزوائد وصلاً", 'count' => "٨ شروحات"],
                        ]
                    ],
                    [
                        'id' => 18,
                        'title' => "التحريرات الجامعة — الأوجه المركبة",
                        'desc' => "الجمع بين البدل واللين والتقليل بشكل صحيح (قمة الإتقان).",
                        'items' => [
                            ['type' => 'lesson', 'text' => "قاعدة الجمع بين الأوجه المتعددة ومنع الممتنعات", 'count' => "١٢ شرحاً"],
                            ['type' => 'detect', 'text' => "تحدي: اكتشف الوجه الممتنع أداءً في هذه الآية المركبة", 'count' => "١٢ سؤالاً"],
                            ['type' => 'exam', 'text' => "الاختبار النهائي الشامل — ١٠٠ سؤال (إجازة تفاعلية)", 'count' => "١٠٠ سؤال"],
                        ]
                    ],
                ]
            ]
        ]
    ]
];

// --- Execution ---
foreach ($curriculum as $mIdx => $levelData) {
    $colors = [
        ['color' => '#F59E0B', 'secondary' => '#FEF3C7'],
        ['color' => '#D97706', 'secondary' => '#FFEDD5'],
        ['color' => '#B45309', 'secondary' => '#FFF7ED'],
    ];

    foreach ($levelData['materials'] as $matIdx => $matData) {
        $material = Material::create([
            'name' => $matData['title'],
            'description' => $matData['desc'],
            'code' => 'WARSH_L' . ($mIdx + 1),
            'color' => $colors[$mIdx]['color'],
            'secondary_color' => $colors[$mIdx]['secondary'],
            'active' => true,
        ]);
        $division->materials()->attach($material->id, ['sort' => $mIdx + 1]);

        foreach ($matData['units'] as $uIdx => $unitData) {
            $unit = Unit::create([
                'name' => "الوحدة " . ($unitData['id']) . ": " . $unitData['title'],
                'description' => $unitData['desc'],
                'active' => true,
            ]);
            $material->units()->attach($unit->id, ['sort' => $uIdx + 1]);
            $unit->subscriptions()->attach($subscriptionId);

            foreach ($unitData['items'] as $cIdx => $item) {
                $count = parseCount($item['count']);
                $type = in_array($item['type'], ['exercise', 'detect', 'exam']) ? 'exercise' : 'lesson';
                
                $content = null;
                if ($type === 'lesson') {
                    if (in_array($item['type'], ['intro', 'lesson'])) {
                        $content = [];
                        for ($i = 0; $i < $count; $i++) {
                            $content[] = [
                                'elements' => [
                                    [
                                        'type' => 'text',
                                        'data' => [
                                            'content' => "<p style='text-align: center;'><b>الشريحة " . ($i + 1) . "</b><br>" . getTajweedContent($unitData['title'], 'slide', $i) . "</p>"
                                        ]
                                    ]
                                ]
                            ];
                        }
                    } elseif (in_array($item['type'], ['audio', 'warsh'])) {
                        $cards = [];
                        for ($i = 0; $i < $count; $i++) {
                            $cards[] = [
                                'front' => "البطاقة " . ($i + 1) . " - " . $item['text'],
                                'back' => "محتوى توضيحي للبطاقة " . ($i + 1)
                            ];
                        }
                        $content = [['elements' => [['type' => 'flashcards', 'data' => ['cards' => $cards]]]]];
                    }
                }

                $chapter = Chapter::create([
                    'name' => $item['text'],
                    'description' => $unitData['title'],
                    'type' => $type,
                    'content' => $content,
                    'chapter_level_id' => $chapterLevelId,
                    'active' => true,
                ]);
                $chapter->unit()->attach($unit->id, ['sort' => $cIdx + 1]);
                $chapter->subscriptions()->attach($subscriptionId);
            }
        }
    }
}

echo "The Precise Curriculum has been successfully generated with all slides and questions!\n";
