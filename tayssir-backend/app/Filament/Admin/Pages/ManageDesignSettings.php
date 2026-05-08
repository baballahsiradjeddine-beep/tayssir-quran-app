<?php

namespace App\Filament\Admin\Pages;

use App\Settings\DesignSettings;
use Filament\Forms\Components\ColorPicker;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Grid;
use Filament\Forms\Form;
use Filament\Pages\SettingsPage;

class ManageDesignSettings extends SettingsPage
{
    protected static ?string $navigationIcon = 'heroicon-o-paint-brush';

    protected static string $settings = DesignSettings::class;

    protected static ?string $navigationGroup = 'اعدادات التطبيق';

    public static function getNavigationLabel(): string
    {
        return 'تصميم التطبيق';
    }

    public function getTitle(): string
    {
        return 'تصميم التطبيق (Design System)';
    }

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make('الوضع الفاتح (Light Mode)')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                ColorPicker::make('light_primary')->label('اللون الأساسي')->required(),
                                ColorPicker::make('light_secondary')->label('اللون الثانوي')->required(),
                                ColorPicker::make('light_accent')->label('لون التميز (ذهبي)')->required(),
                            ]),
                        Grid::make(2)
                            ->schema([
                                ColorPicker::make('light_background')->label('لون الخلفية')->required(),
                                ColorPicker::make('light_surface')->label('لون البطاقات')->required(),
                            ]),
                        Grid::make(2)
                            ->schema([
                                ColorPicker::make('light_text_primary')->label('لون النص الأساسي')->required(),
                                ColorPicker::make('light_text_secondary')->label('لون النص الثانوي')->required(),
                            ]),
                    ])->collapsible(),

                Section::make('الوضع الغامق (Dark Mode)')
                    ->schema([
                        Grid::make(3)
                            ->schema([
                                ColorPicker::make('dark_primary')->label('اللون الأساسي')->required(),
                                ColorPicker::make('dark_secondary')->label('اللون الثانوي')->required(),
                                ColorPicker::make('dark_accent')->label('لون التميز (ذهبي)')->required(),
                            ]),
                        Grid::make(2)
                            ->schema([
                                ColorPicker::make('dark_background')->label('لون الخلفية')->required(),
                                ColorPicker::make('dark_surface')->label('لون البطاقات')->required(),
                            ]),
                        Grid::make(2)
                            ->schema([
                                ColorPicker::make('dark_text_primary')->label('لون النص الأساسي')->required(),
                                ColorPicker::make('dark_text_secondary')->label('لون النص الثانوي')->required(),
                            ]),
                    ])->collapsible(),
            ]);
    }
}
