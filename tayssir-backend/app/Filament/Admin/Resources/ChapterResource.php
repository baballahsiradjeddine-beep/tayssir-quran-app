<?php

namespace App\Filament\Admin\Resources;

use App\Enums\ContentDirection;
use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\ChapterResource\Pages;
use App\Filament\Admin\Resources\ChapterResource\RelationManagers\QuestionsRelationManager;
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
                Forms\Components\Tabs::make('Chapter Tabs')
                    ->tabs([
                        Forms\Components\Tabs\Tab::make('معلومات الفصل')
                            ->icon('heroicon-o-information-circle')
                            ->schema([
                                Section::make()->schema([
                                    TextInput::make('name')
                                        ->required()
                                        ->minLength(1)
                                        ->label("اسم الدرس أو الفصل"),

                                    Select::make('unit')
                                        ->relationship('unit', 'name')
                                        ->searchable()
                                        ->required()
                                        ->label("تابع للمحور/الوحدة"),

                                    Select::make('chapter_level_id')
                                        ->relationship('chapter_level', 'name')
                                        ->searchable()
                                        ->preload()
                                        ->required()
                                        ->label(__('custom.models.chapter.level')),

                                    Select::make('type')
                                        ->options([
                                            'exercise' => 'تمرين (أسئلة)',
                                            'lesson' => 'درس (محتوى تفاعلي)',
                                        ])
                                        ->default('exercise')
                                        ->live()
                                        ->label("نوع الفصل"),

                                    Textarea::make('description')
                                        ->rows(2)
                                        ->columnSpanFull()
                                        ->label(__('custom.models.chapter.description')),

                                    Select::make('direction')->native(false)
                                        ->options(ContentDirection::class)
                                        ->enum(ContentDirection::class)
                                        ->default(ContentDirection::INHERIT)
                                        ->required()
                                        ->label(__('custom.direction.label')),

                                    Select::make('subscriptions')
                                        ->multiple()
                                        ->relationship('subscriptions', 'name')
                                        ->searchable()
                                        ->preload()
                                        ->label(__('custom.models.chapter.subscriptions')),

                                    Forms\Components\Toggle::make('active')
                                        ->label(__('custom.models.active'))
                                        ->default(true),

                                    SpatieMediaLibraryFileUpload::make('photo')
                                        ->collection('chapter_photos')
                                        ->image()
                                        ->label('صورة الفصل'),
                                ])->columns(2),
                            ]),

                        Forms\Components\Tabs\Tab::make('محتوى الدرس (الشرائح)')
                            ->icon('heroicon-o-presentation-chart-bar')
                            ->visible(fn ($get) => $get('type') === 'lesson')
                            ->schema([
                                Section::make('بناء محتوى الدرس')->description('قم بإضافة الشرائح والعناصر التفاعلية هنا.')->schema([
                                    Forms\Components\Repeater::make('content')
                                        ->schema([
                                            Forms\Components\Builder::make('elements')
                                                ->blocks([
                                                    Forms\Components\Builder\Block::make('text')
                                                        ->label('نص منسق')
                                                        ->icon('heroicon-o-document-text')
                                                        ->schema([
                                                            Forms\Components\RichEditor::make('content')->label('المحتوى'),
                                                        ]),
                                                    Forms\Components\Builder\Block::make('video')
                                                        ->label('فيديو')
                                                        ->icon('heroicon-o-video-camera')
                                                        ->schema([
                                                            TextInput::make('url')->label('رابط الفيديو (YouTube)'),
                                                            Forms\Components\FileUpload::make('file')->label('أو رفع ملف')->directory('chapters/videos'),
                                                        ]),
                                                    Forms\Components\Builder\Block::make('audio')
                                                        ->label('صوت')
                                                        ->icon('heroicon-o-microphone')
                                                        ->schema([
                                                            Forms\Components\FileUpload::make('file')->label('ملف صوتي')->directory('chapters/audio'),
                                                        ]),
                                                    Forms\Components\Builder\Block::make('flashcards')
                                                        ->label('بطاقات تعليمية')
                                                        ->icon('heroicon-o-square-2-stack')
                                                        ->schema([
                                                            Forms\Components\Repeater::make('cards')
                                                                ->schema([
                                                                    TextInput::make('front')->label('الوجه الأمامي'),
                                                                    TextInput::make('back')->label('الوجه الخلفي'),
                                                                ])->columns(2),
                                                        ]),
                                                ])
                                                ->label('عناصر الشريحة')
                                                ->collapsible(),
                                        ])
                                        ->label('الشرائح (Slides)')
                                        ->itemLabel(fn (array $state): ?string => "شريحة " . ($state['sort'] ?? ''))
                                        ->addActionLabel('إضافة شريحة جديدة')
                                        ->reorderableWithButtons()
                                        ->collapsible()
                                        ->collapsed(),
                                ]),
                            ]),
                    ])->columnSpanFull(),
            ]);
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
            QuestionsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListChapters::route('/'),
            'create' => Pages\CreateChapter::route('/create'),
            'edit' => Pages\EditChapter::route('/{record}/edit'),
        ];
    }
}
