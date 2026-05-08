<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\AutomatedNotification;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Storage;

class SendAutomatedNotifications extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:send-automated-notifications';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Sends automated push notifications based on predefined triggers (streaks, inactivity, etc.)';

    /**
     * Execute the console command.
     */
    /**
     * Execute the console command.
     */
    public function handle()
    {
        $activeNotifications = AutomatedNotification::where('is_active', true)->get();
        if ($activeNotifications->isEmpty()) return;

        $now = Carbon::now();
        $hour = $now->hour;
        $isFriday = $now->isFriday();
        $today = $now->toDateString();
        $yesterday = $now->subDay()->toDateString();
        $threeDaysAgo = Carbon::now()->subDays(3)->toDateString();
        $sevenDaysAgo = Carbon::now()->subDays(7)->toDateString();

        $fifteenDaysAgo = Carbon::now()->subDays(15)->toDateString();
        $thirtyDaysAgo = Carbon::now()->subDays(30)->toDateString();

        foreach ($activeNotifications as $notification) {
            $imageUrl = $notification->image ? url(Storage::url($notification->image)) : null;
            $usersQuery = User::whereNotNull('fcm_token');

            switch ($notification->trigger_type) {
                case 'morning_motivation':
                    if ($hour !== 8) continue 2;
                    break;

                case 'friday_kahf_reminder':
                    if (!$isFriday || $hour !== 9) continue 2;
                    break;

                case 'evening_muhasaba':
                    if ($hour !== 20) continue 2;
                    $usersQuery->where(function($q) use ($today) {
                        $q->whereNull('last_study_date')
                          ->orWhereDate('last_study_date', '<', $today);
                    });
                    break;

                case 'inactive_3_days':
                    // Short term: 6 PM (evening reflection)
                    if ($hour !== 18) continue 2;
                    $usersQuery->whereDate('last_study_date', '=', $threeDaysAgo);
                    break;

                case 'inactive_7_days':
                    // Mid term: 11 AM (start of the day)
                    if ($hour !== 11) continue 2;
                    $usersQuery->whereDate('last_study_date', '=', $sevenDaysAgo);
                    break;

                case 'inactive_15_days':
                    // Long term: 14 PM (mid-day reminder)
                    if ($hour !== 14) continue 2;
                    $usersQuery->whereDate('last_study_date', '=', $fifteenDaysAgo);
                    break;

                case 'inactive_30_days':
                    // Very long term: 10 AM
                    if ($hour !== 10) continue 2;
                    $usersQuery->whereDate('last_study_date', '=', $thirtyDaysAgo);
                    break;

                case 'streak_at_risk':
                    if ($hour !== 21) continue 2;
                    $usersQuery->where('streak_count', '>', 0)
                               ->whereDate('last_study_date', '<', $today);
                    break;

                default:
                    if (str_starts_with($notification->trigger_type, 'material_progress_')) {
                        if ($hour !== 17) continue 2;
                        $this->processMaterialProgressNotification($notification, $today, $imageUrl);
                    }
                    continue 2;
            }

            $this->sendToUsers($usersQuery, $notification, $imageUrl);
        }

        $this->info('Automated notifications processed successfully.');
    }

    private function sendToUsers($query, $notification, $imageUrl)
    {
        $users = $query->get();
        $count = 0;

        foreach ($users as $user) {
            // Anti-spam: Max 1 automated notification per user per day total across ALL types
            $dailyLock = "notif_daily_lock_{$user->id}_" . date('Y-m-d');
            if (\Illuminate\Support\Facades\Cache::has($dailyLock)) continue;

            $title = str_replace('{name}', $user->name, $notification->title);
            $body = str_replace('{name}', $user->name, $notification->body);

            $user->notify(new \App\Notifications\CustomUserNotification($title, $body, $imageUrl));
            
            // Set lock for 24h to ensure they don't get another automated one today
            \Illuminate\Support\Facades\Cache::put($dailyLock, true, now()->addDay());
            $count++;
        }

        if ($count > 0) {
            $this->info("Sent '{$notification->name}' to {$count} users.");
        }
    }

    private function processMaterialProgressNotification($notification, $today, $imageUrl)
    {
        $usersToNotify = User::whereNotNull('fcm_token')->get();
        $count = 0;

        foreach ($usersToNotify as $user) {
            $progressData = $user->MaterialsProgress();
            if (empty($progressData)) continue;

            foreach ($progressData as $item) {
                $prog = $item['progress'];
                $matName = $item['material_name'] ?? 'السورة';

                $shouldNotify = false;
                $trigger = $notification->trigger_type;

                if ($trigger == 'material_progress_50' && $prog >= 50 && $prog < 60) {
                    $shouldNotify = true;
                } elseif ($trigger == 'material_progress_100' && $prog == 100) {
                    $shouldNotify = true;
                }

                if ($shouldNotify) {
                    $title = str_replace(['{name}', '{material_name}'], [$user->name, $matName], $notification->title);
                    $body = str_replace(['{name}', '{material_name}'], [$user->name, $matName], $notification->body);

                    // Check for spam for this specific material
                    $spamKey = "mat_notif_{$notification->id}_{$user->id}_{$item['material_id']}";
                    if (!\Illuminate\Support\Facades\Cache::has($spamKey)) {
                        $user->notify(new \App\Notifications\CustomUserNotification($title, $body, $imageUrl));
                        \Illuminate\Support\Facades\Cache::put($spamKey, true, now()->addDays(30));
                        $count++;
                        break; // Only one material per notification type per day
                    }
                }
            }
        }
        $this->info("Processed progress '{$notification->name}' for {$count} users.");
    }
}
