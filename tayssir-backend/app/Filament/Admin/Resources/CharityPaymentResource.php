<?php

namespace App\Filament\Admin\Resources;

use App\Enums\Purchase\PaymentStatus;
use App\Enums\Purchase\PaymentType;
use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\CharityPaymentResource\Pages;
use App\Models\Payment;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Tables\Actions\ViewAction;
use Filament\Tables\Actions\DeleteAction;
use Filament\Tables\Filters\SelectFilter;
use Illuminate\Database\Eloquent\Builder;

class CharityPaymentResource extends Resource
{
    protected static ?string $model = Payment::class;

    protected static ?string $navigationIcon = 'heroicon-o-banknotes';

    public static function getNavigationGroup(): ?string
    {
        return "الأعمال الخيرية";
    }

    public static function getModelLabel(): string
    {
        return "تبرع خيري";
    }

    public static function getPluralModelLabel(): string
    {
        return "مدفوعات التبرعات";
    }

    public static function getNavigationBadge(): ?string
    {
        return (string) static::getModel()::whereIn('status', [
            \App\Enums\Purchase\PaymentStatus::SUCCEEDED->value,
            \App\Enums\Purchase\PaymentStatus::ACCEPTED->value,
        ])
        ->where(function (Builder $query) {
            $query->where('subscription_id', 999)
                  ->orWhereNotNull('charity_campaign_id');
        })
        ->count();
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'success';
    }

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()->where(function (Builder $query) {
            $query->where('subscription_id', 999)
                  ->orWhereNotNull('charity_campaign_id');
        });
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('الحالة')
                    ->columns(2)
                    ->schema([
                        Select::make('status')
                            ->options(PaymentStatus::class)
                            ->label('حالة الدفع'),
                    ]),
                Section::make('معلومات التبرع')
                    ->columns(2)
                    ->schema([
                        Select::make('charity_campaign_id')
                            ->relationship('charityCampaign', 'title')
                            ->label('الحملة المرتبطة')
                            ->disabled(),
                        TextInput::make('final_price')
                            ->label('المبلغ')
                            ->suffix(' DZD')
                            ->disabled(),
                        Select::make('payment_type')
                            ->options(PaymentType::class)
                            ->label('نوع الدفع')
                            ->disabled(),
                        TextInput::make('created_at')
                            ->label('تاريخ التبرع')
                            ->disabled(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')
                    ->label('ID')
                    ->sortable(),
                TextColumn::make('user.email')
                    ->label('المتبرع')
                    ->searchable(),
                TextColumn::make('charityCampaign.title')
                    ->label('الحملة')
                    ->placeholder('تبرع عام')
                    ->searchable(),
                TextColumn::make('status')
                    ->label('الحالة')
                    ->badge(),
                TextColumn::make('final_price')
                    ->label('المبلغ')
                    ->sortable()
                    ->suffix(' DZD'),
                TextColumn::make('payment_type')
                    ->label('النوع')
                    ->badge(),
                TextColumn::make('created_at')
                    ->label('التاريخ')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('status')
                    ->label('الحالة')
                    ->options(PaymentStatus::class),
                SelectFilter::make('charity_campaign_id')
                    ->relationship('charityCampaign', 'title')
                    ->label('الحملة'),
            ])
            ->actions([
                ViewAction::make(),
                DeleteAction::make(),
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
            'index' => Pages\ListCharityPayments::route('/'),
            'view' => Pages\ViewCharityPayment::route('/{record}'),
        ];
    }
}
