<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Clusters\NotificationCluster;
use App\Filament\Admin\Resources\AutomatedNotificationResource\Pages;
use App\Models\AutomatedNotification;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Pages\SubNavigationPosition;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class AutomatedNotificationResource extends Resource
{
    protected static ?string $model = AutomatedNotification::class;

    protected static ?string $cluster = NotificationCluster::class;

    protected static SubNavigationPosition $subNavigationPosition = SubNavigationPosition::Top;

    protected static ?string $navigationIcon = 'heroicon-o-cpu-chip';
    public static function getNavigationSort(): ?int
    {
        return AdminNavigation::AUTOMATED_NOTIFICATION_RESOURCE['sort'];
    }

    public static function getNavigationGroup(): ?string
    {
        return null;
    }

    public static function getNavigationLabel(): string
    {
        return 'الإشعارات التلقائية';
    }

    public static function getPluralModelLabel(): string
    {
        return 'الإشعارات التلقائية';
    }

    public static function getModelLabel(): string
    {
        return 'إشعار تلقائي';
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('معلومات الإشعار')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->label('اسم تعريفي داخلي (مثل: تذكير الاستمرار 3 أيام)')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Select::make('trigger_type')
                            ->label('شرط الإرسال التلقائي')
                            ->options([
                                'morning_motivation' => '☀️ تحفيز صباحي (يُرسل 8:00 صباحاً لجميع المستخدمين)',
                                'friday_kahf_reminder' => '🕌 تذكير سورة الكهف (يُرسل صباح الجمعة 9:00)',
                                'evening_muhasaba' => '🌙 محاسبة المساء (يُرسل 8:00 مساءً لمن لم يدرس اليوم)',
                                'streak_at_risk' => '⚠️ خطر انكسار السلسلة (يُرسل 9:00 ليلاً لمن لم يدرس)',
                                'inactive_3_days' => '🔌 غياب 3 أيام (تذكير بالعودة)',
                                'inactive_7_days' => '📡 غياب أسبوع (رسالة شوق)',
                                'inactive_15_days' => '🔭 غياب أسبوعين (رسالة عودة قوية)',
                                'inactive_30_days' => '🛸 غياب شهر (رسالة استعادة)',
                                'material_progress_50' => '🎯 إنجاز 50% من سورة/مادة (احتفال بالنصف)',
                                'material_progress_100' => '🏆 ختم السورة/المادة 100% (احتفال بالختام)',
                                'daily_streak_reminder' => 'تذكير يومي قديم (سيتم استبداله بالمحاسبة)',
                            ])
                            ->required(),
                        Forms\Components\TextInput::make('title')
                            ->label('عنوان الإشعار الذي سيظهر للطالب (يمكنك كتابة {material_name} ليتم تبديلها باسم المادة تلقائياً)')
                            ->required()
                            ->maxLength(255),
                        Forms\Components\Textarea::make('body')
                            ->label('نص ورسالة الإشعار (يمكنك أيضاً كتابة {material_name} هنا)')
                            ->required()
                            ->maxLength(65535),
                        Forms\Components\FileUpload::make('image')
                            ->label('صورة الإشعار (اختياري)')
                            ->image()
                            ->directory('automated_notifications')
                            ->nullable(),
                        Forms\Components\Toggle::make('is_active')
                            ->label('الإشعار مُفعل (سيتم إرساله اوتوماتيكياً)')
                            ->default(true),
                    ])->columns(1)
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')->label('الاسم')->searchable(),
                Tables\Columns\TextColumn::make('trigger_type')
                    ->label('الشرط')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'morning_motivation' => 'تحفيز صباحي',
                        'friday_kahf_reminder' => 'تذكير الجمعة',
                        'evening_muhasaba' => 'محاسبة المساء',
                        'streak_at_risk' => 'خطر السلسلة',
                        'inactive_3_days' => 'غياب 3 أيام',
                        'inactive_7_days' => 'غياب أسبوع',
                        'inactive_15_days' => 'غياب أسبوعين',
                        'inactive_30_days' => 'غياب شهر',
                        'material_progress_50' => 'إنجاز 50%',
                        'material_progress_100' => 'ختم مادة',
                        default => $state,
                    }),
                Tables\Columns\TextColumn::make('title')->label('العنوان'),
                Tables\Columns\IconColumn::make('is_active')
                    ->label('مُفعل')
                    ->boolean(),
                Tables\Columns\TextColumn::make('updated_at')->label('آخر تعديل')->dateTime()->sortable(),
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
            'index' => Pages\ListAutomatedNotifications::route('/'),
            'create' => Pages\CreateAutomatedNotification::route('/create'),
            'edit' => Pages\EditAutomatedNotification::route('/{record}/edit'),
        ];
    }
}
