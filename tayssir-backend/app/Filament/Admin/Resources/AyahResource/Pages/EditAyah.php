<?php

namespace App\Filament\Admin\Resources\AyahResource\Pages;

use App\Filament\Admin\Resources\AyahResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditAyah extends EditRecord
{
    protected static string $resource = AyahResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
