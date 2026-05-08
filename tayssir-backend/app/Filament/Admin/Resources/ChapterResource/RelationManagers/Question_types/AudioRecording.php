<?php

namespace App\Filament\Admin\Resources\ChapterResource\RelationManagers\Question_types;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Group;
use Filament\Forms\Components\Placeholder;
use Filament\Forms\Components\FileUpload;

class AudioRecording
{
    public static function make(): Group
    {
        return Group::make([
            Placeholder::make('audio_instruction')
                ->content(new \Illuminate\Support\HtmlString('
                    <div class="flex items-center gap-3 p-4 bg-primary-500/10 border border-primary-500/20 rounded-2xl">
                        <div class="w-10 h-10 rounded-full bg-primary-500 flex items-center justify-center text-white">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m8 0h-3m4-8a3 3 0 01-3 3V5a3 3 0 116 0v6z"/></svg>
                        </div>
                        <p class="text-sm text-gray-300 font-medium">سيطلب النظام من الطالب تسجيل صوته تالياً للآية المكتوبة أدناه.</p>
                    </div>
                '))
                ->hiddenLabel(),

            TextInput::make('target_text')
                ->label('النص المطلوب تلاوته')
                ->placeholder('مثلاً: قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ')
                ->required()
                ->extraAttributes(['class' => 'bg-[#0b1121]/30 border-[#1e293b] text-lg font-bold text-center']),

            FileUpload::make('reference_audio')
                ->label('نموذج صوتي (اختياري)')
                ->directory('chapter-audio-references')
                ->helperText('ارفع تسجيلاً صحيحاً ليسمعه الطالب قبل أن يسجل هو.')
                ->extraAttributes(['class' => 'bg-[#0b1121]/20']),
        ])
        ->visible(fn ($get) => $get('question_type') === 'audio_recording');
    }
}
