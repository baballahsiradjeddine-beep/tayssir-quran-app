<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\SurahResource\Pages;
use App\Models\Surah;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class SurahResource extends Resource
{
    protected static ?string $model = Surah::class;

    protected static ?string $navigationIcon = AdminNavigation::SURAH_RESOURCE['icon'];

    protected static ?int $navigationSort = AdminNavigation::SURAH_RESOURCE['sort'];

    public static function getNavigationGroup(): ?string
    {
        return __(AdminNavigation::SURAH_RESOURCE['group']);
    }

    public static function getModelLabel(): string
    {
        return 'سورة';
    }

    public static function getPluralModelLabel(): string
    {
        return 'السور';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('معلومات السورة')
                    ->schema([
                        Select::make('division_id')
                            ->relationship('division', 'name')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->label('الرواية'),
                        TextInput::make('name_ar')
                            ->required()
                            ->label('اسم السورة (بالعربية)'),
                        TextInput::make('name_en')
                            ->required()
                            ->label('اسم السورة (بالإنجليزية)'),
                        Select::make('type')
                            ->options([
                                'Meccan' => 'مكية',
                                'Medinan' => 'مدنية',
                            ])
                            ->required()
                            ->label('نوع السورة'),
                        TextInput::make('total_ayahs')
                            ->numeric()
                            ->required()
                            ->label('إجمالي عدد الآيات'),
                        TextInput::make('revelation_order')
                            ->numeric()
                            ->label('ترتيب النزول'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('division.name')->label('الرواية')->sortable(),
                TextColumn::make('id')->sortable()->label('ID'),
                TextColumn::make('name_ar')->searchable()->label('الاسم (عربي)'),
                TextColumn::make('name_en')->searchable()->label('الاسم (إنجليزي)'),
                TextColumn::make('type')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Meccan' => 'warning',
                        'Medinan' => 'success',
                    })
                    ->label('النوع'),
                TextColumn::make('total_ayahs')->label('عدد الآيات'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('division_id')
                    ->relationship('division', 'name')
                    ->searchable()
                    ->preload()
                    ->label('تصفية حسب الرواية'),
                Tables\Filters\SelectFilter::make('type')
                    ->options([
                        'Meccan' => 'مكية',
                        'Medinan' => 'مدنية',
                    ])
                    ->label('تصفية حسب النوع'),
            ], layout: Tables\Enums\FiltersLayout::AboveContent)
            ->filtersFormColumns(2)
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListSurahs::route('/'),
            'create' => Pages\CreateSurah::route('/create'),
            'edit' => Pages\EditSurah::route('/{record}/edit'),
        ];
    }
}
