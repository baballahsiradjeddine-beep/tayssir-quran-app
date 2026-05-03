<?php

namespace App\Services\Analytics;

use App\Models\User;
use App\Models\UserAnswer;
use Carbon\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class AnalyticsService
{
    private const CACHE_DURATION = 3600; // 1 hour in seconds
    private const CACHE_KEY = 'analytics.general_stats';

    /**
     * Get all general stats with a single cache call
     */
    public function getStats(): array
    {
        return Cache::remember(self::CACHE_KEY, self::CACHE_DURATION, function () {
            return [
                'total_users' => $this->calculateTotalUsers(),
                'new_users_this_week' => $this->calculateNewUsersThisWeek(),
                'active_users_today' => $this->calculateActiveUsersToday(),
                'average_learning_time' => $this->calculateAverageLearningTime(),
            ];
        });
    }

    /**
     * Calculate total users count
     */
    private function calculateTotalUsers(): int
    {
        return User::count();
    }

    /**
     * Calculate new users this week with growth percentage
     */
    private function calculateNewUsersThisWeek(): array
    {
        $thisWeek = User::where('created_at', '>=', Carbon::now()->startOfWeek())->count();
        $lastWeek = User::where('created_at', '>=', Carbon::now()->subWeek()->startOfWeek())
            ->where('created_at', '<', Carbon::now()->startOfWeek())
            ->count();

        $growth = $lastWeek > 0 ? round((($thisWeek - $lastWeek) / $lastWeek) * 100) : 0;
        if ($growth < 0) {
            $growth = '▼ -' . abs($growth);
        } elseif ($growth > 0) {
            $growth = '▲ +' . $growth;
        } else {
            $growth = '0';
        }

        return [
            'count' => $thisWeek,
            'growth' => $growth,
        ];
    }

    /**
     * Calculate active users today (users with answers today)
     */
    private function calculateActiveUsersToday(): int
    {
        return UserAnswer::where('created_at', '>=', Carbon::now()->startOfDay())
            ->distinct('user_id')
            ->count('user_id');
    }

    /**
     * Calculate average learning time in minutes (estimated based on sessions)
     */
    private function calculateAverageLearningTime(): int
    {
        // Estimate: each distinct (user, date, hour) group represents a learning session of ~5 minutes
        // Using strftime for SQLite compatibility
        $sessions = DB::table('user_answers')
            ->selectRaw("user_id, date(created_at) as activity_date, strftime('%H', created_at) as activity_hour")
            ->groupByRaw("user_id, date(created_at), strftime('%H', created_at)")
            ->get();

        if ($sessions->isEmpty()) {
            return 0;
        }

        $totalMinutes = $sessions->count() * 5;
        $totalUsers = User::count();

        return $totalUsers > 0 ? round($totalMinutes / $totalUsers) : 0;
    }

    /**
     * Clear all analytics cache
     */
    public function clearCache(): void
    {
        Cache::forget(self::CACHE_KEY);
    }
}
