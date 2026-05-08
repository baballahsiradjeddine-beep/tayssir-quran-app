<?php

namespace App\Enums;

use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasIcon;
use Filament\Support\Contracts\HasLabel;

enum QuestionType: string implements HasColor, HasIcon, HasLabel
{
    // Exercise Types
    case MULTIPLE_CHOICES = 'multiple_choices';
    case FILL_IN_THE_BLANKS = 'fill_in_the_blanks';
    case PICK_THE_INTRUDER = 'pick_the_intruder';
    case TRUE_OR_FALSE = 'true_or_false';
    case MATCH_WITH_ARROWS = 'match_with_arrows';

    // Lesson Types
    case VIDEO = 'video';
    case STYLED_TEXT = 'styled_text';
    case FLASHCARDS = 'flashcards';

    public function getLabel(): ?string
    {
        return match ($this) {
            self::MULTIPLE_CHOICES => 'اختر الإجابة الصحيحة',
            self::FILL_IN_THE_BLANKS => 'املأ الفراغات',
            self::PICK_THE_INTRUDER => 'اختر الدخيل',
            self::TRUE_OR_FALSE => 'صحيح أو خطأ',
            self::MATCH_WITH_ARROWS => 'اربط بين العبارات',
            self::VIDEO => 'درس فيديو',
            self::STYLED_TEXT => 'شرح نصي مصمم',
            self::FLASHCARDS => 'بطاقات تعليمية (Flashcards)',
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::MULTIPLE_CHOICES => 'primary',
            self::FILL_IN_THE_BLANKS => 'success',
            self::PICK_THE_INTRUDER => 'danger',
            self::TRUE_OR_FALSE => 'info',
            self::MATCH_WITH_ARROWS => 'warning',
            self::VIDEO => 'danger',
            self::STYLED_TEXT => 'gray',
            self::FLASHCARDS => 'success',
        };
    }

    public function getIcon(): ?string
    {
        return match ($this) {
            self::MULTIPLE_CHOICES => 'heroicon-o-list-bullet',
            self::FILL_IN_THE_BLANKS => 'heroicon-o-pencil-square',
            self::PICK_THE_INTRUDER => 'heroicon-o-magnifying-glass',
            self::TRUE_OR_FALSE => 'heroicon-o-check-circle',
            self::MATCH_WITH_ARROWS => 'heroicon-o-arrows-right-left',
            self::VIDEO => 'heroicon-o-play-circle',
            self::STYLED_TEXT => 'heroicon-o-document-text',
            self::FLASHCARDS => 'heroicon-o-rectangle-stack',
        };
    }
}
