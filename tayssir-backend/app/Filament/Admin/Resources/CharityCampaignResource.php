<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\CharityCampaignResource\Pages;
use App\Models\CharityCampaign;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\SpatieMediaLibraryFileUpload;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\SpatieMediaLibraryImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;

class CharityCampaignResource extends Resource
{
    protected static ?string $model = CharityCampaign::class;

    protected static ?string $recordTitleAttribute = 'title';

    public static function getNavigationGroup(): ?string
    {
        return "الأعمال الخيرية";
    }

    public static function getModelLabel(): string
    {
        return "حملة خيرية";
    }

    public static function getPluralModelLabel(): string
    {
        return "الحملات الخيرية";
    }

    protected static ?string $navigationIcon = 'heroicon-o-heart';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('الوسائط الرئيسية (التي تظهر في الأعلى)')->schema([
                    Select::make('main_media_type')
                        ->options([
                            'image' => 'صورة',
                            'video' => 'فيديو',
                        ])
                        ->default('image')
                        ->live()
                        ->label('نوع الوسائط الرئيسية'),

                    SpatieMediaLibraryFileUpload::make('main_image')
                        ->label('الصورة الرئيسية')
                        ->collection('main_image')
                        ->image()
                        ->visible(fn (callable $get) => $get('main_media_type') === 'image'),

                    TextInput::make('main_video_url')
                        ->url()
                        ->label('رابط الفيديو الرئيسي (YouTube)')
                        ->placeholder('https://www.youtube.com/watch?v=...')
                        ->visible(fn (callable $get) => $get('main_media_type') === 'video'),
                ])->columns(2),

                Section::make('معلومات الحملة')->schema([
                    TextInput::make('title')
                        ->required()
                        ->label('عنوان الحملة')
                        ->columnSpanFull(),

                    RichEditor::make('description')
                        ->label('وصف الحملة')
                        ->columnSpanFull(),

                    TextInput::make('target_amount')
                        ->numeric()
                        ->label('المبلغ المستهدف (دج)')
                        ->placeholder('مثلاً: 1000000'),

                    TextInput::make('raised_amount')
                        ->numeric()
                        ->label('المبلغ المجموع حالياً (دج)')
                        ->default(0),

                    Select::make('status')
                        ->options([
                            'ongoing' => 'جارية',
                            'completed' => 'منتهية',
                        ])
                        ->default('ongoing')
                        ->required()
                        ->label('حالة الحملة'),

                    Toggle::make('is_visible')
                        ->label('ظاهرة في التطبيق')
                        ->default(true),
                ])->columns(2),

                Section::make('توثيق الإنجاز والمراحل (صور وصفية)')->schema([
                    SpatieMediaLibraryFileUpload::make('documentation_images')
                        ->multiple()
                        ->label('معرض الصور الوصفية')
                        ->collection('documentation')
                        ->image()
                        ->reorderable(),
                ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                SpatieMediaLibraryImageColumn::make('main_image')
                    ->label('الصورة')
                    ->collection('main_image')
                    ->circular(),

                TextColumn::make('title')
                    ->label('العنوان')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('target_amount')
                    ->label('المستهدف')
                    ->money('DZD')
                    ->sortable(),

                TextColumn::make('raised_amount')
                    ->label('المجموع')
                    ->money('DZD')
                    ->sortable(),

                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'ongoing' => 'success',
                        'completed' => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'ongoing' => 'جارية',
                        'completed' => 'منتهية',
                    }),

                ToggleColumn::make('is_visible')
                    ->label('ظاهرة'),

                TextColumn::make('created_at')
                    ->label('تاريخ الإنشاء')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
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
            'index' => Pages\ListCharityCampaigns::route('/'),
            'create' => Pages\CreateCharityCampaign::route('/create'),
            'edit' => Pages\EditCharityCampaign::route('/{record}/edit'),
        ];
    }
}
