<?php

namespace App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types;

use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Group;

class Ordering
{
    public static function make(): Group
    {
        return Group::make([
            Repeater::make('ordering_items')
                ->label('كلمات الآية / الجملة (بالترتيب الصحيح)')
                ->helperText('أدخل الكلمات مرتبة كما يجب أن تظهر في الإجابة الصحيحة. النظام سيقوم ببعثرتها للمستخدم.')
                ->schema([
                    TextInput::make('text')
                        ->label('الكلمة / المقطع')
                        ->placeholder('مثلاً: الحمد')
                        ->required(),
                ])
                ->defaultItems(3)
                ->reorderableWithButtons()
                ->collapsible()
                ->extraAttributes(['class' => 'bg-[#0b1121]/30 rounded-2xl p-4 border border-[#1e293b]'])
                ->itemLabel(fn (array $state): ?string => $state['text'] ?? null),
        ])
        ->visible(fn ($get) => $get('question_type') === 'ordering');
    }
}
