<?php

namespace App\Filament\Admin\Resources\SurahResource\Pages;

use App\Filament\Admin\Resources\SurahResource;
use Filament\Resources\Pages\ListRecords;

use Filament\Resources\Components\Tab;
use App\Models\Division;

class ListSurahs extends ListRecords
{
    protected static string $resource = SurahResource::class;

    public function getTabs(): array
    {
        $tabs = [
            'all' => Tab::make('جميع السور'),
        ];

        try {
            $divisions = Division::all();

            foreach ($divisions as $division) {
                $tabs[$division->id] = Tab::make($division->name)
                    ->modifyQueryUsing(fn ($query) => $query->where('division_id', $division->id));
            }
        } catch (\Exception $e) {
            // Fallback
        }

        return $tabs;
    }
}
