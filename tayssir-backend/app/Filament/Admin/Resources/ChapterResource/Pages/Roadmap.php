<?php

namespace App\Filament\Admin\Resources\ChapterResource\Pages;

use App\Filament\Admin\Resources\ChapterResource;
use Filament\Resources\Pages\Page;

class Roadmap extends Page
{
    protected static string $resource = ChapterResource::class;

    protected static string $view = 'filament.admin.pages.roadmap';

    protected static ?string $title = 'خريطة الطريق التعليمية';

    public function getHeaderActions(): array
    {
        return [
            \Filament\Actions\Action::make('table_view')
                ->label('عرض الجدول التقليدي')
                ->url(ChapterResource::getUrl('index_table'))
                ->color('gray')
                ->icon('heroicon-m-table-cells'),
        ];
    }
}
