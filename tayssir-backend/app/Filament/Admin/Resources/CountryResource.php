<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\CountryResource\Pages;
use App\Models\Country;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class CountryResource extends Resource
{
    protected static ?string $model = Country::class;

    protected static ?string $navigationIcon = 'heroicon-o-flag';

    protected static ?int $navigationSort = 1000;

    public static function getNavigationGroup(): ?string
    {
        return 'امور اضافية';
    }
    public static function getModelLabel(): string
    {
        return __('custom.models.country');
    }

    public static function getPluralModelLabel(): string
    {
        return __('custom.models.countries');
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make(__('custom.models.country'))
                    ->schema([
                        TextInput::make('name')
                            ->label(__('custom.models.country.name'))
                            ->required()
                            ->maxLength(255),
                        TextInput::make('code')
                            ->label(__('custom.models.country.code'))
                            ->required()
                            ->maxLength(3),
                        TextInput::make('phone_code')
                            ->label(__('custom.models.country.phone_code'))
                            ->required()
                            ->maxLength(10),
                        Toggle::make('is_active')
                            ->label(__('custom.models.active'))
                            ->default(true),
                    ])->columns(2),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label(__('custom.models.country.name'))
                    ->searchable()
                    ->sortable(),
                TextColumn::make('code')
                    ->label(__('custom.models.country.code'))
                    ->searchable(),
                TextColumn::make('phone_code')
                    ->label(__('custom.models.country.phone_code'))
                    ->searchable(),
                IconColumn::make('is_active')
                    ->label(__('custom.models.active'))
                    ->boolean(),
                TextColumn::make('created_at')
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

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListCountries::route('/'),
            'create' => Pages\CreateCountry::route('/create'),
            'edit' => Pages\EditCountry::route('/{record}/edit'),
        ];
    }
}
