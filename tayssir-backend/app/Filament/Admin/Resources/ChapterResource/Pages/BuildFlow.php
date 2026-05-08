<?php

namespace App\Filament\Admin\Resources\ChapterResource\Pages;

use App\Filament\Admin\Resources\ChapterResource;
use Filament\Forms\Form;
use Filament\Resources\Pages\EditRecord;
use Filament\Forms;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Select;
use Filament\Notifications\Notification;
use App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types\FillInTheBlanks;
use App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types\MatchWithArrows;
use App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types\MultipleChoice;
use App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types\PickTheIntruder;
use App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types\TrueOrFalse;
use App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types\Ordering;
use App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types\AudioRecording;

class BuildFlow extends EditRecord
{
    protected static string $resource = ChapterResource::class;
    protected static ?string $title = 'بناء مسار التعلم الذكي';

    protected function getHeaderActions(): array
    {
        return [
            \Filament\Actions\Action::make('back_to_chapter')
                ->label('العودة لإعدادات الفصل')
                ->url(static::getResource()::getUrl('edit', ['record' => $this->getRecord()]))
                ->color('gray')
                ->icon('heroicon-m-arrow-left'),
        ];
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make()
                    ->extraAttributes([
                        'style' => 'background-color: #1a2236 !important; border: 1px solid #1e293b !important; border-radius: 2rem !important; box-shadow: 0 10px 40px -10px rgba(0, 0, 0, 0.7) !important;',
                        'class' => 'overflow-hidden p-0 mb-6',
                    ])
                    ->schema([
                        // Unified Header Strip
                        Forms\Components\View::make('filament.admin.components.master-card-header')
                            ->extraAttributes([
                                'style' => 'background-color: rgba(0,0,0,0.3);',
                                'class' => 'p-6 border-b border-white/5'
                            ]),

                        Forms\Components\Group::make()
                            ->extraAttributes(['class' => 'p-8'])
                            ->schema([
                                Forms\Components\Grid::make(3)
                                    ->schema([
                                        Forms\Components\Group::make()
                                            ->schema([
                                                Forms\Components\Placeholder::make('flow_title')
                                                    ->content(new \Illuminate\Support\HtmlString('
                                                        <div class="flex flex-col gap-1">
                                                            <div class="flex items-center gap-2">
                                                                <span class="w-2 h-2 rounded-full bg-warning-500 animate-pulse"></span>
                                                                <h3 class="text-xl font-bold text-white tracking-tight">هيكلة المسار التعليمي</h3>
                                                            </div>
                                                            <p class="text-sm text-gray-400">نظّم تجربة التعلم، ادمج الصوت، الترتيب، والذكاء الاصطناعي</p>
                                                        </div>
                                                    '))
                                                    ->hiddenLabel(),
                                            ])->columnSpan(2),

                                        Forms\Components\Group::make()
                                            ->schema([
                                                Forms\Components\Actions::make([
                                                    Forms\Components\Actions\Action::make('import_json_v2')
                                                        ->label('الذكاء الاصطناعي')
                                                        ->icon('heroicon-m-sparkles')
                                                        ->color('warning')
                                                        ->modalWidth('7xl')
                                                        ->modalHeading('منصة إدارة المحتوى الذكية')
                                                        ->form([
                                                            Forms\Components\Grid::make(5)->schema([
                                                                Forms\Components\Section::make([
                                                                    Forms\Components\Textarea::make('json_data')
                                                                        ->label('بيانات JSON')
                                                                        ->placeholder('[{ "question": "...", ... }]')
                                                                        ->required()
                                                                        ->rows(15)
                                                                        ->live(debounce: 500)
                                                                        ->extraAttributes([
                                                                            'dir' => 'ltr',
                                                                            'style' => 'font-family: monospace; background: #0b1121; color: #10b981; border: 1px solid #1e293b;',
                                                                        ]),
                                                                ])->columnSpan(2),

                                                                Forms\Components\Section::make([
                                                                    Forms\Components\Placeholder::make('preview')
                                                                        ->hiddenLabel()
                                                                        ->content(function ($get) {
                                                                            $raw = $get('json_data');
                                                                            $blocks = [];
                                                                            if (!empty($raw)) {
                                                                                $parsed = json_decode($raw, true);
                                                                                if (json_last_error() === JSON_ERROR_NONE) $blocks = $parsed;
                                                                            }
                                                                            $questionsData = array_map(function($b) {
                                                                                return array_merge($b['data'] ?? [], ['question' => $b['data']['question_text'] ?? '']);
                                                                            }, array_filter($blocks, fn($b) => ($b['type'] ?? '') === 'question'));

                                                                            return view('filament.admin.components.questions-preview', [
                                                                                'questions' => $questionsData,
                                                                                'raw' => $raw,
                                                                                'ownerRecord' => $this->getRecord(),
                                                                            ]);
                                                                        }),
                                                                ])->columnSpan(3),
                                                            ]),
                                                        ])
                                                        ->action(function (array $data) {
                                                            $decoded = json_decode($data['json_data'], true);
                                                            if ($decoded) {
                                                                $this->getRecord()->update(['content' => array_merge($this->getRecord()->content ?? [], $decoded)]);
                                                                $this->refreshFormData(['content']);
                                                                Notification::make()->title('تم التحديث بنجاح!')->success()->send();
                                                            }
                                                        }),

                                                    Forms\Components\Actions\Action::make('export_json')
                                                        ->label('تصدير')
                                                        ->icon('heroicon-m-arrow-down-tray')
                                                        ->color('success')
                                                        ->action(function () {
                                                            $json = json_encode($this->getRecord()->content, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
                                                            return response()->streamDownload(fn () => print($json), 'chapter_flow.json');
                                                        }),
                                                ])->alignEnd(),
                                            ])->columnSpan(1),
                                    ]),

                                Forms\Components\Placeholder::make('divider')
                                    ->content(new \Illuminate\Support\HtmlString('<div class="h-px bg-white/5 my-8"></div>'))
                                    ->hiddenLabel(),

                                Forms\Components\Builder::make('content')
                                    ->hiddenLabel()
                                    ->blocks([
                                        // BLOCK: Slide
                                        Forms\Components\Builder\Block::make('slide')
                                            ->label('شريحة شرح')
                                            ->icon('heroicon-o-presentation-chart-bar')
                                            ->schema([
                                                Forms\Components\Tabs::make('SlideTabs')
                                                    ->tabs([
                                                        Forms\Components\Tabs\Tab::make('النص الأساسي')
                                                            ->icon('heroicon-o-document-text')
                                                            ->schema([
                                                                Forms\Components\RichEditor::make('content')
                                                                    ->label('المحتوى النصي')
                                                                    ->columnSpanFull(),
                                                            ]),
                                                        Forms\Components\Tabs\Tab::make('الوسائط والإعدادات')
                                                            ->icon('heroicon-o-adjustments-vertical')
                                                            ->schema([
                                                                Forms\Components\Grid::make(2)
                                                                    ->schema([
                                                                        Select::make('media_type')
                                                                            ->options(['none' => 'نص فقط', 'image' => 'صورة', 'video' => 'فيديو'])
                                                                            ->default('none')->live()->label('نوع الميديا'),
                                                                        Forms\Components\Toggle::make('is_latex')
                                                                            ->label('دعم LaTeX')->default(false),
                                                                    ]),
                                                                Forms\Components\FileUpload::make('media_file')
                                                                    ->label('الملف المصاحب')
                                                                    ->directory('chapter-content')
                                                                    ->visible(fn ($get) => $get('media_type') !== 'none'),
                                                            ]),
                                                    ]),
                                            ]),

                                        // BLOCK: Question
                                        Forms\Components\Builder\Block::make('question')
                                            ->label('سؤال تفاعلي')
                                            ->icon('heroicon-o-academic-cap')
                                            ->schema([
                                                Forms\Components\Tabs::make('QuestionTabs')
                                                    ->tabs([
                                                        Forms\Components\Tabs\Tab::make('1. السؤال والمحتوى')
                                                            ->icon('heroicon-o-pencil-square')
                                                            ->schema([
                                                                Forms\Components\Grid::make(2)
                                                                    ->schema([
                                                                        TextInput::make('question_text')
                                                                            ->required()->label('نص السؤال الرئيسي'),
                                                                        Forms\Components\Select::make('question_type')
                                                                            ->options([
                                                                                'multiple_choices' => 'اختيارات متعددة',
                                                                                'fill_in_the_blanks' => 'ملء الفراغات',
                                                                                'pick_the_intruder' => 'اختر الدخيل',
                                                                                'true_or_false' => 'صح أم خطأ',
                                                                                'match_with_arrows' => 'التوصيل بالأسهم',
                                                                                'ordering' => 'ترتيب الكلمات/الآيات',
                                                                                'audio_recording' => '🎙️ تسجيل صوتي (جديد)',
                                                                            ])
                                                                            ->required()->live()->label('نوع التفاعل'),
                                                                    ]),
                                                                
                                                                Forms\Components\Section::make('تفاصيل التفاعل')
                                                                    ->extraAttributes(['class' => 'bg-[#0b1121]/20 rounded-xl'])
                                                                    ->schema([
                                                                        TrueOrFalse::make(),
                                                                        MultipleChoice::make(),
                                                                        FillInTheBlanks::make(),
                                                                        PickTheIntruder::make(),
                                                                        MatchWithArrows::make(),
                                                                        Ordering::make(),
                                                                        AudioRecording::make(),
                                                                    ])->compact(),
                                                            ]),

                                                        Forms\Components\Tabs\Tab::make('2. المساعدة والتعليل')
                                                            ->icon('heroicon-o-sparkles')
                                                            ->schema([
                                                                Forms\Components\Grid::make(2)
                                                                    ->schema([
                                                                        Forms\Components\Section::make('التوجيه (Hint)')
                                                                            ->description('يظهر "أثناء" التفكير')
                                                                            ->extraAttributes(['class' => 'bg-warning-500/5 border-warning-500/20'])
                                                                            ->schema([
                                                                                Forms\Components\Textarea::make('hint_text')
                                                                                    ->label('نص التلميح')->rows(2),
                                                                                Forms\Components\FileUpload::make('hint_image')
                                                                                    ->label('صورة تلميح')->image(),
                                                                            ]),
                                                                        Forms\Components\Section::make('التعليل (Explanation)')
                                                                            ->description('يظهر "بعد" الحل')
                                                                            ->extraAttributes(['class' => 'bg-success-500/5 border-success-500/20'])
                                                                            ->schema([
                                                                                Forms\Components\RichEditor::make('explanation_text')->label('نص التعليل'),
                                                                                Forms\Components\FileUpload::make('explanation_asset')->label('وسائط الشرح'),
                                                                            ]),
                                                                    ]),
                                                            ]),

                                                        Forms\Components\Tabs\Tab::make('3. الوسائط والإعدادات')
                                                            ->icon('heroicon-o-cog-6-tooth')
                                                            ->schema([
                                                                Forms\Components\Grid::make(2)
                                                                    ->schema([
                                                                        Forms\Components\FileUpload::make('image')
                                                                            ->label('صورة السؤال الأساسية')->image()
                                                                            ->directory('chapter-questions'),
                                                                        Forms\Components\Group::make([
                                                                            Select::make('direction')
                                                                                ->options(['inherit' => '(inherit)', 'RTL' => 'RTL', 'LTR' => 'LTR'])
                                                                                ->default('inherit')->label('اتجاه النص'),
                                                                            Select::make('scope')
                                                                                ->options(['lesson' => 'درس', 'exercice' => 'تمرين'])
                                                                                ->default('lesson')->label('نطاق السؤال'),
                                                                            Forms\Components\Toggle::make('question_is_latex')
                                                                                ->label('دعم LaTeX')->default(false),
                                                                        ]),
                                                                    ]),
                                                            ]),
                                                    ])->persistTabInQueryString(),
                                            ]),
                                    ])
                                    ->columnSpanFull()
                                    ->collapsible()
                                    ->extraAttributes(['class' => 'bg-[#0b1121]/30 rounded-3xl border border-[#1e293b] p-6 shadow-inner']),
                            ]),
                    ]),
            ]);
    }
}
