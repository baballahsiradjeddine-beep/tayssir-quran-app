<?php

namespace App\Filament\Admin\Widgets;

use App\Services\Analytics\AnalyticsService;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class GeneralInfos extends BaseWidget
{
    protected string|array|int $columnSpan = 'full';
    protected static ?int $sort = 1;

    public function getHeading(): ?string
    {
        return __('stats.general.title');
    }

    protected function getStats(): array
    {
        $analyticsService = new AnalyticsService();
        $stats = $analyticsService->getStats();

        return [
            // Total Users Card
            Stat::make("إجمالي الحفاظ", number_format($stats['total_users']))
                ->description("عدد المسجلين في رحلة بيان القرآن")
                ->color('primary'),

            // New Users This Week Card
            Stat::make(
                "الحفاظ المنضمون هذا الأسبوع",
                $stats['new_users_this_week']['count']
            )
                ->description(
                    "نمو بنسبة " . $stats['new_users_this_week']['growth'] . '%'
                )
                ->color('success'),

            // Active Users Today Card
            Stat::make(
                "الحفاظ النشطون اليوم",
                $stats['active_users_today']
            )
                ->description("الحفاظ الذين يراجعون الآن")
                ->color('info'),

            // Average Learning Time Card
            // Stat::make(
            //     __('stats.general.avg_learning_time') . "testing",
            //     $stats['average_learning_time'] . ' ' . __('stats.general.avg_learning_time_minutes')
            // )
            //     ->description(__('stats.general.avg_learning_time_desc'))
            //     ->color('warning'),
        ];
    }
}
