<?php

use App\Models\Chapter;
use Illuminate\Support\Facades\DB;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "Enhancing Lessons with Smart Cards and Video Links...\n";

// Topic to Video Mapping (Consistent Sheiks for Warsh)
$topicMedia = [
    'الاستعاذة' => [
        'video' => 'https://www.youtube.com/watch?v=Xh7o_rZly9o', // شرح أوجه الاستعاذة
        'points' => [
            'الاستعاذة مستحبة عند جمهور القراء للبدء بالقراءة.',
            'أوجه البسملة بين السورتين لورش: السكت (المقدم)، الوصل، والبسملة.',
            'السكت يكون وقفة يسيرة (حركتان) بدون تنفس.',
            'لا يجوز وصل البسملة بآخر السورة والوقف عليها.'
        ]
    ],
    'ميم الجمع' => [
        'video' => 'https://www.youtube.com/watch?v=Q74Vn0K9y78', // صلة ميم الجمع لورش
        'points' => [
            'يصل ورش ميم الجمع بواو لفظية إذا وقع بعدها همزة قطع.',
            'مقدار المد في صلة ميم الجمع هو 6 حركات (إشباع).',
            'إذا وقع بعد الميم حرف عادي، فالحكم هو الإسكان.',
            'يسقط مد الصلة إذا وقع بعد الميم حرف ساكن.'
        ]
    ],
    'هاء الكناية' => [
        'video' => 'https://www.youtube.com/watch?v=O_Ld3vTqRTo', // هاء الكناية لورش
        'points' => [
            'هاء الكناية هي الهاء الزائدة الدالة على المفرد الغائب.',
            'يشترط للصلة وقوع الهاء بين متحركين.',
            "مستثنيات ورش بالإسكان: (يؤده، نصله، نؤته، فألقه).",
            "مستثنيات ورش بالقصر: (يرضه لكم) بالزمر."
        ]
    ],
    'النون والتنوين' => [
        'video' => 'https://www.youtube.com/watch?v=0A_UvY8XvR0', // أحكام النون الساكنة
        'points' => [
            'الإظهار الحلقي: عند الحروف الستة (ء هـ ع ح غ خ).',
            'الإدغام: في حروف (يرملون)، وورش يدغم النون في الواو في (يس والقرآن).',
            'الإخفاء: عند 15 حرفاً مع غنة كاملة.',
            'الإقلاب: قلب النون ميماً مخفاة عند حرف الباء.'
        ]
    ],
    'الراءات' => [
        'video' => 'https://www.youtube.com/watch?v=yYJ4-K66sS0', // ترقيق الراءات لورش
        'points' => [
            'يرقق ورش الراء المفتوحة والمضمومة بعد ياء ساكنة أو كسرة أصلية.',
            'ترقق الراء إذا فصل بينها وبين الكسرة حرف ساكن غير مستعلٍ.',
            'تستثنى الأسماء الأعجمية (إبراهيم، إسرائيل) فتفخم فيها الراء.',
            'تفخم الراء إذا وقع بعدها حرف استعلاء متصل.'
        ]
    ],
    'اللامات' => [
        'video' => 'https://www.youtube.com/watch?v=D8-R2jP5k0k', // تغليظ اللامات لورش
        'points' => [
            'تغلظ اللام المفتوحة إذا سبقتها (ص، ط، ظ) مفتوحة أو ساكنة.',
            'يشترط أن تكون اللام نفسها مفتوحة (مخففة أو مشددة).',
            'يجوز الوجهان (التغليظ والترقيق) عند الوقف على اللام.',
            'لا تغلظ اللام إذا كانت مضمومة أو مكسورة.'
        ]
    ],
    'المد' => [
        'video' => 'https://www.youtube.com/watch?v=wXWk5-e8x_8', // أنواع المدود لورش
        'points' => [
            'المد المتصل والمنفصل يمدان بـ 6 حركات وجوباً.',
            'مد البدل لورش فيه ثلاثة أوجه: القصر (2)، التوسط (4)، الإشباع (6).',
            'مد اللين المهموز (شيء) يمد بـ 4 أو 6 حركات وصلاً.',
            'يمتنع التقليل في ذوات الياء على وجه قصر البدل.'
        ]
    ],
    'الهمز' => [
        'video' => 'https://www.youtube.com/watch?v=7uRzL_00hG0', // الهمز لورش
        'points' => [
            'النقل: نقل حركة الهمزة للساكن قبلها وحذف الهمزة.',
            'الإبدال: إبدال الهمز الساكن فاء الكلمة حرف مد.',
            'تسهيل الهمزة الثانية من الهمزتين الملتقيتين من كلمة.',
            'قواعد الهمزتين من كلمتين (التسهيل أو الإبدال).'
        ]
    ],
    'التحريرات' => [
        'video' => 'https://www.youtube.com/watch?v=pS3tZ2I5p3M', // تحريرات ورش
        'points' => [
            'قاعدة الجمع بين البدل وذوات الياء: قصر البدل معه الفتح فقط.',
            'توسط البدل يوافقه التقليل فقط في ذوات الياء.',
            'إشباع البدل يوافقه الفتح والتقليل معاً.',
            'التحريرات هي قمة الإتقان في أداء رواية ورش.'
        ]
    ],
];

$chapters = Chapter::where('type', 'lesson')->get();

foreach ($chapters as $chapter) {
    echo "Processing Lesson: " . $chapter->name . "\n";
    
    $topicKey = 'الاستعاذة'; // Default
    foreach (array_keys($topicMedia) as $key) {
        if (mb_stripos($chapter->name, $key) !== false || mb_stripos($chapter->description, $key) !== false) {
            $topicKey = $key;
            break;
        }
    }

    $data = $topicMedia[$topicKey];
    
    // Create Smart Card Content
    $smartContent = [
        [
            'elements' => [
                [
                    'type' => 'video',
                    'data' => [
                        'url' => $data['video'],
                        'title' => 'شرح مرئي: ' . $chapter->name
                    ]
                ],
                [
                    'type' => 'text',
                    'data' => [
                        'content' => "<div style='direction: rtl; text-align: right;'>
                            <h3 style='color: #10B981;'>أهم نقاط الدرس:</h3>
                            <ul style='list-style-type: square; line-height: 1.8;'>
                                <li>" . implode("</li><li>", $data['points']) . "</li>
                            </ul>
                        </div>"
                    ]
                ]
            ]
        ]
    ];

    $chapter->update([
        'content' => $smartContent
    ]);
    
    echo "  - Lesson enhanced with Video and Bullet Points.\n";
}

echo "\nAll Lessons have been transformed into Smart Cards with Video support!\n";
