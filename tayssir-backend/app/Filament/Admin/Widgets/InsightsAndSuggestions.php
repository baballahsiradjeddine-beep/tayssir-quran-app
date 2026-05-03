<?php

namespace App\Filament\Admin\Widgets;

use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use App\Services\Analytics\ContentQualityService;
use App\Services\Analytics\SuggestionsAnalyticsService;

class InsightsAndSuggestions extends BaseWidget
{
    protected static ?int $sort = 5;

    protected int | string | array $columnSpan = 'full';

    protected function getStats(): array
    {
        $qualityService = app(ContentQualityService::class);
        $suggestionsService = app(SuggestionsAnalyticsService::class);

        $qualityStats = $qualityService->getMetrics();
        $suggestionsStats = $suggestionsService->getStats();

        // Format quality stats strings
        $topLessons = collect($qualityStats['top_materials'] ?? [])
            ->map(fn($item) => "{$item['material_name']}")
            ->join(' | ') ?: 'لا تتوفر بيانات';

        $lowLessons = collect($qualityStats['bottom_materials'] ?? [])
            ->map(fn($item) => "{$item['material_name']}")
            ->join(' | ') ?: 'لا تتوفر بيانات';

        return [
            // Quality 1
            Stat::make(
                "أفضل المواد تفاعلاً",
                new \Illuminate\Support\HtmlString('<div class="text-sm font-medium whitespace-normal leading-snug">' . $topLessons . '</div>')
            )
                ->description("أفضل 3 مواد حسب تفاعل المستخدمين")
                ->color('success'),

            // Quality 2
            Stat::make(
                "المواد الأقل تفاعلاً",
                new \Illuminate\Support\HtmlString('<div class="text-sm font-medium whitespace-normal leading-snug">' . $lowLessons . '</div>')
            )
                ->description("المواد ذات أقل معدلات تفاعل")
                ->color('danger'),

            // Suggestion 1
            Stat::make(
                "أكثر الولايات استعمالاً",
                new \Illuminate\Support\HtmlString('<div class="text-sm font-medium whitespace-normal leading-snug">' . ($suggestionsStats['top_wilayas'] ?: 'لا تتوفر بيانات') . '</div>')
            )
                ->description("الولايات الجزائرية الأكثر نشاطاً")
                ->color('info'),

            // Suggestion 2
            Stat::make(
                "أكثر الروايات استعمالاً",
                new \Illuminate\Support\HtmlString('<div class="text-sm font-medium whitespace-normal leading-snug">' . $suggestionsService->formatDivisions($suggestionsStats['top_divisions'] ?? []) . '</div>')
            )
                ->description("الروايات الأكثر تفاعلاً في النظام")
                ->color('primary'),
        ];
    }
}
