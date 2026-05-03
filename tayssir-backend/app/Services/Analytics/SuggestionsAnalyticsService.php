<?php

namespace App\Services\Analytics;

use App\Models\User;
use App\Models\UserAnswer;
use Carbon\Carbon;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class SuggestionsAnalyticsService
{
    private const CACHE_DURATION = 3600; // 1 hour in seconds
    private const CACHE_KEY = 'analytics.suggestions_stats';

    /**
     * Get all suggestions metrics with a single cache call
     */
    public function getStats(): array
    {
        $stats = Cache::remember(self::CACHE_KEY, self::CACHE_DURATION, function () {
            return [
                'top_wilayas' => $this->calculateTopWilayas(),
                'top_divisions' => $this->calculateTopDivisions(),
                'peak_hours' => $this->calculatePeakHours(),
            ];
        });

        // Format top wilayas based on current locale
        $stats['top_wilayas'] = $this->formatWilayasForLocale($stats['top_wilayas']);

        return $stats;
    }

    /**
     * Calculate top wilayas by user count - stores both names
     */
    private function calculateTopWilayas(): array
    {
        $topWilayas = User::select('wilaya_id', DB::raw('COUNT(*) as count'))
            ->whereNotNull('wilaya_id')
            ->where('wilaya_id', '>', 0)
            ->groupBy('wilaya_id')
            ->orderByDesc('count')
            ->limit(3)
            ->with('wilaya:id,name,arabic_name')
            ->get();

        if ($topWilayas->isEmpty()) {
            return [];
        }

        // Cache the raw data with both names
        return $topWilayas->map(function ($record) {
            return [
                'name' => $record->wilaya?->name ?? 'Unknown',
                'arabic_name' => $record->wilaya?->arabic_name ?? 'غير معروف',
                'count' => $record->count,
            ];
        })->toArray();
    }

    /**
     * Format wilayas display based on current locale
     */
    private function formatWilayasForLocale(array $wilayas): string
    {
        if (empty($wilayas)) {
            return 'No data';
        }

        $locale = App::getLocale();
        $useArabic = $locale === 'ar';

        $formatted = collect($wilayas)->map(function ($wilaya) use ($useArabic) {
            $name = $useArabic ? $wilaya['arabic_name'] : $wilaya['name'];
            return "{$name}: {$wilaya['count']}";
        })->join(' ');

        return $formatted;
    }

    /**
     * Calculate top divisions (narrations) by user count
     */
    private function calculateTopDivisions(): array
    {
        $topDivisions = User::select('division_id', DB::raw('COUNT(*) as count'))
            ->whereNotNull('division_id')
            ->groupBy('division_id')
            ->orderByDesc('count')
            ->limit(3)
            ->with('division:id,name')
            ->get();

        return $topDivisions->map(function ($record) {
            return [
                'name' => $record->division?->name ?? 'Unknown',
                'count' => $record->count,
            ];
        })->toArray();
    }

    /**
     * Format divisions display
     */
    public function formatDivisions(array $divisions): string
    {
        if (empty($divisions)) {
            return 'No data';
        }

        return collect($divisions)->map(function ($div) {
            return "{$div['name']}: {$div['count']}";
        })->join(' | ');
    }

    /**
     * Calculate peak usage hours (semi-real)
     */
    private function calculatePeakHours(): string
    {
        // Simple peak hour detection based on last week's answers
        $peakHour = DB::table('user_answers')
            ->selectRaw("strftime('%H', created_at) as hour, COUNT(*) as count")
            ->groupByRaw("strftime('%H', created_at)")
            ->where('created_at', '>=', Carbon::now()->subWeek())
            ->orderByDesc('count')
            ->first();

        if (!$peakHour) {
            return '19:00 - 21:00';
        }

        $start = str_pad($peakHour->hour, 2, '0', STR_PAD_LEFT) . ':00';
        $end = str_pad(($peakHour->hour + 2) % 24, 2, '0', STR_PAD_LEFT) . ':00';

        return "{$start} - {$end}";
    }

    /**
     * Clear suggestions analytics cache
     */
    public function clearCache(): void
    {
        Cache::forget(self::CACHE_KEY);
    }
}
