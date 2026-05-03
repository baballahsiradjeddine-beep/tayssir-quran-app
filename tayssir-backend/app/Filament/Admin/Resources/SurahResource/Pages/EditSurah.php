<?php

namespace App\Filament\Admin\Resources\SurahResource\Pages;

use App\Filament\Admin\Resources\SurahResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditSurah extends EditRecord
{
    protected static string $resource = SurahResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
