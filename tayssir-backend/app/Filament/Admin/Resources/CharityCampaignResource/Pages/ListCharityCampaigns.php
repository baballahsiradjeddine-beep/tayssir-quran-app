<?php

namespace App\Filament\Admin\Resources\CharityCampaignResource\Pages;

use App\Filament\Admin\Resources\CharityCampaignResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListCharityCampaigns extends ListRecords
{
    protected static string $resource = CharityCampaignResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
