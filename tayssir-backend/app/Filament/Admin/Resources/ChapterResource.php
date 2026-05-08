<?php

namespace App\Filament\Admin\Resources;

use App\Enums\ContentDirection;
use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\ChapterResource\Pages;
use App\Models\Chapter;
use Filament\Forms;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\SpatieMediaLibraryFileUpload;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\SpatieMediaLibraryImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Notifications\Notification;

class ChapterResource extends Resource
{
    public static function getNavigationGroup(): ?string
    {
        return __(AdminNavigation::CHAPTER_RESOURCE['group']);
    }

    public static function getModelLabel(): string
    {
        return "درس / فصل";
    }

    public static function getPluralModelLabel(): string
    {
        return "الدروس والفصول";
    }

    protected static ?string $model = Chapter::class;

    protected static ?string $recordTitleAttribute = 'name';

    protected static bool $isGloballySearchable = true;

    protected static ?string $navigationIcon = AdminNavigation::CHAPTER_RESOURCE['icon'];

    protected static ?int $navigationSort = AdminNavigation::CHAPTER_RESOURCE['sort'];

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make()
                    ->extraAttributes([
                        'style' => 'background-color: #1a2236 !important; border: 1px solid #1e293b !important; border-radius: 2rem !important; box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.5) !important;',
                        'class' => 'overflow-hidden p-0 mb-6',
                    ])
                    ->schema([
                        // Unified Header Strip
                        Forms\Components\View::make('filament.admin.components.master-card-header')
                            ->extraAttributes([
                                'style' => 'background-color: rgba(0,0,0,0.2);',
                                'class' => 'p-6 border-b border-white/5'
                            ]),

                        Forms\Components\Grid::make(12)
                            ->schema([
                                // Right Column: Integrated Settings (7/12)
                                Forms\Components\Group::make()
                                    ->extraAttributes(['class' => 'p-8'])
                                    ->schema([
                                        Forms\Components\Placeholder::make('basic_info_title')
                                            ->content(new \Illuminate\Support\HtmlString('<h3 class="text-xl font-bold text-white mb-6 tracking-tight">البيانات الأساسية</h3>'))
                                            ->hiddenLabel(),
                                            
                                        TextInput::make('name')
                                            ->required()
                                            ->label('عنوان الفصل')
                                            ->placeholder('عنوان الفصل...')
                                            ->extraAttributes(['class' => 'bg-[#0b1121]/30 border-[#1e293b]']),
                                        
                                        Forms\Components\Grid::make(2)
                                            ->schema([
                                                Select::make('unit_id')
                                                    ->relationship('unit', 'name')
                                                    ->searchable()
                                                    ->required()
                                                    ->label('المحور / السورة')
                                                    ->extraAttributes(['class' => 'bg-[#0b1121]/30 border-[#1e293b]']),
                                                Select::make('chapter_level_id')
                                                    ->relationship('chapter_level', 'name')
                                                    ->required()
                                                    ->label('مستوى الصعوبة')
                                                    ->extraAttributes(['class' => 'bg-[#0b1121]/30 border-[#1e293b]']),
                                            ]),

                                        Textarea::make('description')
                                            ->rows(3)
                                            ->label('وصف موجز للمستخدم')
                                            ->extraAttributes(['class' => 'bg-[#0b1121]/30 border-[#1e293b]']),
                                        
                                        Forms\Components\Toggle::make('active')
                                            ->label('تفعيل هذا الفصل الآن')
                                            ->default(true),

                                        Forms\Components\Placeholder::make('icon_divider')
                                            ->content(new \Illuminate\Support\HtmlString('<div class="h-px bg-white/5 my-8 text-center flex items-center justify-center"><span class="bg-[#1a2236] px-4 text-gray-500 text-[10px] uppercase tracking-widest font-bold">Media Assets</span></div>'))
                                            ->hiddenLabel(),

                                        Forms\Components\Placeholder::make('icon_label')
                                            ->content(new \Illuminate\Support\HtmlString('<h4 class="text-lg font-bold text-white mb-4">أيقونة الفصل</h4>'))
                                            ->hiddenLabel(),

                                        Forms\Components\SpatieMediaLibraryFileUpload::make('photo')
                                            ->collection('chapter_photos')
                                            ->image()
                                            ->hiddenLabel()
                                            ->extraAttributes(['class' => 'bg-[#0b1121]/20 border-[#1e293b] rounded-2xl']),
                                    ])->columnSpan(7),

                                // Left Column: Integrated Content Gateway (5/12)
                                Forms\Components\Group::make()
                                    ->extraAttributes(['class' => 'p-8 border-r border-white/5 bg-white/[0.01]'])
                                    ->schema([
                                        Forms\Components\Placeholder::make('content_mgmt_title')
                                            ->content(new \Illuminate\Support\HtmlString('<h3 class="text-xl font-bold text-white mb-6 tracking-tight">إدارة المحتوى</h3>'))
                                            ->hiddenLabel(),
                                            
                                        Forms\Components\Placeholder::make('flow_builder_link')
                                            ->hiddenLabel()
                                            ->content(function ($record) {
                                                if (!$record) return 'يرجى الحفظ أولاً.';
                                                
                                                try { $url = static::getUrl('build-flow', ['record' => $record]); } catch (\Exception $e) { return '...'; }
                                                
                                                return new \Illuminate\Support\HtmlString("
                                                    <div class='p-8 bg-[#0b1121] rounded-[2rem] border border-[#1e293b] shadow-2xl transition-all group overflow-hidden relative min-h-[320px] flex flex-col justify-center border-b-4 border-b-primary-600'>
                                                        <div class='absolute -right-20 -top-20 w-48 h-48 bg-primary-500/10 blur-3xl rounded-full'></div>
                                                        <div class='flex flex-col gap-6 text-center items-center relative z-10'>
                                                            <div class='w-20 h-20 rounded-2xl bg-primary-500/20 flex items-center justify-center text-primary-500 group-hover:rotate-12 transition-all shadow-xl border border-primary-500/30 rotate-3'>
                                                                <svg class='w-12 h-12' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M13 10V3L4 14h7v7l9-11h-7z'/></svg>
                                                            </div>
                                                            <div>
                                                                <h3 class='text-2xl font-black text-white tracking-tight'>بناء المسار</h3>
                                                                <p class='text-gray-400 mt-2 leading-relaxed max-w-[250px] font-medium text-sm'>ادمج الشرح والأسئلة بذكاء</p>
                                                            </div>
                                                            <a href='{$url}' class='w-full px-6 py-4 bg-primary-600 hover:bg-primary-700 text-white font-bold text-base rounded-xl shadow-xl shadow-primary-500/30 transition-all transform hover:-translate-y-1 active:scale-95 flex items-center justify-center gap-2'>
                                                                <span>ابدأ البناء الآن</span>
                                                                <svg class='w-5 h-5' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M17 8l4 4m0 0l-4 4m4-4H3'/></svg>
                                                            </a>
                                                        </div>
                                                    </div>
                                                ");
                                            }),

                                        Forms\Components\Placeholder::make('stats_divider')
                                            ->content(new \Illuminate\Support\HtmlString('<div class="h-px bg-white/5 my-8"></div>'))
                                            ->hiddenLabel(),

                                        Forms\Components\Placeholder::make('content_preview')
                                            ->hiddenLabel()
                                            ->content(function ($record) {
                                                if (!$record || empty($record->content)) return '';
                                                $count = count($record->content);
                                                return new \Illuminate\Support\HtmlString("
                                                    <div class='flex items-center gap-4 text-sm text-gray-300'>
                                                        <div class='w-12 h-12 rounded-xl bg-primary-500/20 flex items-center justify-center text-primary-400 font-black text-xl shadow-inner border border-primary-500/20'>{$count}</div>
                                                        <div>
                                                            <p class='text-white font-bold text-base'>عنصر تعليمي</p>
                                                            <p class='text-[10px] text-primary-500 font-bold tracking-[0.1em] uppercase italic'>Tayssir V2</p>
                                                        </div>
                                                    </div>
                                                ");
                                            }),
                                    ])->columnSpan(5),
                            ]),
                    ]),
            ])->columns(1);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                SpatieMediaLibraryImageColumn::make('photo')
                    ->collection('chapter_photos')
                    ->conversion('thumb')
                    ->placeholder(__('custom.table.image.empty'))
                    ->circular()
                    ->label(__('custom.models.chapter.photo')),

                TextColumn::make('name')
                    ->label(__('custom.models.chapter.name'))
                    ->sortable()
                    ->searchable(),

                TextColumn::make('description')
                    ->limit(30)
                    ->label(__('custom.models.chapter.description')),

                TextColumn::make('unit.name')
                    ->badge()
                    ->colors(['gray'])
                    ->label(__('custom.models.chapter.unit')),

                TextColumn::make('questions_count')
                    ->badge()
                    ->label(__('custom.models.questions'))
                    ->counts('questions')
                    ->sortable()
                    ->colors(['primary']),

                TextColumn::make('subscriptions.name')
                    ->label(__('custom.models.subscriptions'))
                    ->badge(),

                Tables\Columns\ToggleColumn::make('active')
                    ->label(__('custom.models.active'))
                    ->sortable()
                    ->toggleable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\Roadmap::route('/'),
            'index_table' => Pages\ListChapters::route('/list'),
            'create' => Pages\CreateChapter::route('/create'),
            'edit' => Pages\EditChapter::route('/{record}/edit'),
            'build-flow' => Pages\BuildFlow::route('/{record}/build-flow'),
        ];
    }
}
