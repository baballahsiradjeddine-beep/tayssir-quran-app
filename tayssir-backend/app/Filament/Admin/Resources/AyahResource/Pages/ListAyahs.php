<?php

namespace App\Filament\Admin\Resources\AyahResource\Pages;

use App\Filament\Admin\Resources\AyahResource;
use Filament\Resources\Pages\ListRecords;

use Filament\Resources\Components\Tab;
use App\Models\Division;

class ListAyahs extends ListRecords
{
    protected static string $resource = AyahResource::class;

    public function getTabs(): array
    {
        $tabs = [
            'all' => Tab::make('جميع الآيات'),
        ];

        try {
            $divisions = Division::all();

            foreach ($divisions as $division) {
                $tabs[$division->id] = Tab::make($division->name)
                    ->modifyQueryUsing(fn ($query) => $query->where('division_id', $division->id));
            }
        } catch (\Exception $e) {
            // Fallback if DB is not ready or table doesn't exist
        }

        return $tabs;
    }
}
