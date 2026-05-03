<?php

namespace App\Filament\Admin\Resources\UnitResource\Pages;

use App\Filament\Admin\Resources\MaterialResource;
use App\Filament\Admin\Resources\UnitResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditUnit extends EditRecord
{
    protected static string $resource = UnitResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
            // Action to navigate to a specific link (/ for example)
            Actions\Action::make('view_material')
                ->url(fn($record) => ($material = $record->material->first()) ? MaterialResource::getUrl('edit', ['record' => $material]) : null)
                ->label(fn($record) => ($material = $record->material->first()) ? __('custom.models.material.action.details') . " '" . $material->name . "'" : 'No Material')
                ->visible(fn($record) => $record->material->isNotEmpty()),
        ];
    }
}
