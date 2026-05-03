<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\RegionResource\Pages;
use App\Models\Region;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class RegionResource extends Resource
{
    protected static ?string $model = Region::class;

    protected static ?string $navigationIcon = 'heroicon-o-map-pin';

    protected static ?int $navigationSort = 1001;

    public static function getNavigationGroup(): ?string
    {
        return 'امور اضافية';
    }

    public static function getModelLabel(): string
    {
        return __('custom.models.region');
    }

    public static function getPluralModelLabel(): string
    {
        return __('custom.models.regions');
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make(__('custom.models.region'))
                    ->schema([
                        TextInput::make('name')
                            ->label(__('custom.models.region.name'))
                            ->required()
                            ->maxLength(255),
                        Select::make('country_id')
                            ->label(__('custom.models.country'))
                            ->relationship('country', 'name', fn($query) => $query->ordered())
                            ->required()
                            ->searchable()
                            ->preload(),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label(__('custom.models.region.name'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('country.name')
                    ->label(__('custom.models.country'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('country')
                    ->relationship('country', 'name', fn($query) => $query->ordered())
                    ->label(__('custom.models.country')),
            ], layout: Tables\Enums\FiltersLayout::AboveContent)
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

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRegions::route('/'),
            'create' => Pages\CreateRegion::route('/create'),
            'edit' => Pages\EditRegion::route('/{record}/edit'),
        ];
    }
}
