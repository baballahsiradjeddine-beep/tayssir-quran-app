<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\AyahResource\Pages;
use App\Models\Ayah;
use App\Models\Surah;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class AyahResource extends Resource
{
    protected static ?string $model = Ayah::class;

    protected static ?string $navigationIcon = AdminNavigation::AYAH_RESOURCE['icon'];

    protected static ?int $navigationSort = AdminNavigation::AYAH_RESOURCE['sort'];

    public static function getNavigationGroup(): ?string
    {
        return __(AdminNavigation::AYAH_RESOURCE['group']);
    }

    public static function getModelLabel(): string
    {
        return 'آية';
    }

    public static function getPluralModelLabel(): string
    {
        return 'الآيات';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('معلومات الآية')
                    ->schema([
                        Select::make('surah_id')
                            ->relationship('surah', 'name_ar')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->label('السورة'),
                        Select::make('division_id')
                            ->relationship('division', 'name')
                            ->required()
                            ->searchable()
                            ->preload()
                            ->label('الرواية'),
                        TextInput::make('number')
                            ->numeric()
                            ->required()
                            ->label('رقم الآية'),
                        Textarea::make('text_ar')
                            ->required()
                            ->label('نص الآية (بالعربية)')
                            ->columnSpanFull(),
                        Textarea::make('text_en')
                            ->label('نص الآية (بالإنجليزي - اختياري)')
                            ->columnSpanFull(),
                        TextInput::make('audio_url')
                            ->url()
                            ->label('رابط الملف الصوتي'),
                        TextInput::make('juz')
                            ->numeric()
                            ->label('رقم الجزء'),
                        TextInput::make('page')
                            ->numeric()
                            ->label('رقم الصفحة'),
                        TextInput::make('hizb')
                            ->numeric()
                            ->label('رقم الحزب'),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('division.name')->label('الرواية')->sortable(),
                TextColumn::make('surah.name_ar')->label('السورة')->searchable(),
                TextColumn::make('number')->label('رقم الآية')->sortable(),
                TextColumn::make('text_ar')
                    ->label('النص (عربي)')
                    ->limit(50)
                    ->searchable(query: function (\Illuminate\Database\Eloquent\Builder $query, string $search): \Illuminate\Database\Eloquent\Builder {
                        $normalized = \App\Utils\ArabicUtils::normalize($search);
                        return $query->where('text_ar', 'like', "%{$search}%")
                                     ->orWhere('text_plain', 'like', "%{$normalized}%");
                    }),
                TextColumn::make('juz')->label('الجزء'),
                TextColumn::make('page')->label('الصفحة'),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('surah_id')
                    ->relationship('surah', 'name_ar')
                    ->searchable()
                    ->preload()
                    ->label('تصفية حسب السورة'),
                Tables\Filters\Filter::make('page')
                    ->form([
                        TextInput::make('page')
                            ->numeric()
                            ->label('رقم الصفحة'),
                    ])
                    ->query(fn ($query, array $data) => $query->when($data['page'], fn ($q) => $q->where('page', $data['page']))),
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
            'index' => Pages\ListAyahs::route('/'),
            'create' => Pages\CreateAyah::route('/create'),
            'edit' => Pages\EditAyah::route('/{record}/edit'),
        ];
    }
}
