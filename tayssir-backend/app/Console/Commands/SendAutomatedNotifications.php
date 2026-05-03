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
    public function handle()
    {
        $activeNotifications = AutomatedNotification::where('is_active', true)->get();

        if ($activeNotifications->isEmpty()) {
            $this->info('No active automated notifications found.');
            return;
        }

        $today = Carbon::today()->toDateString();
        $yesterday = Carbon::yesterday()->toDateString();
        $twoDaysAgo = Carbon::now()->subDays(2)->toDateString();
        
        // تم استبدال منطق العد التنازلي للامتحان بمنطق "الورد اليومي" أو اقتراب شهر رمضان
        $ramadanDate = Carbon::createFromDate(Carbon::now()->year, 3, 1)->startOfDay(); // مثال
        if (now()->gt($ramadanDate)) $ramadanDate->addYear();
        $daysUntilRamadan = Carbon::today()->diffInDays($ramadanDate, false);

        foreach ($activeNotifications as $notification) {
            $imageUrl = null;
            if (!empty($notification->image)) {
                $imageUrl = url(Storage::url($notification->image));
            }

            $usersQuery = User::whereNotNull('fcm_token');

            switch ($notification->trigger_type) {
                case 'daily_quran_reminder':
                    // المستخدم لم يقرأ ورده اليوم
                    $usersQuery->whereNotNull('last_study_date')
                               ->whereDate('last_study_date', '<', $today);
                    break;
                    
                case 'streak_freeze_used':
                    // تم استخدام "تجميد الورد" بالأمس
                    $usersQuery->where('streak_freeze_count', '<', 3) // مثال
                               ->whereDate('last_study_date', '=', $yesterday);
                    break;

                case 'inactive_3_days':
                    $usersQuery->whereDate('last_study_date', '=', $twoDaysAgo);
                    break;
                    
                case 'surah_progress_50':
                case 'surah_progress_100':
                    // معالجة خاصة لتقدم السور
                    $this->processSurahProgressNotification($notification, $today, $imageUrl);
                    continue 2;

                case 'ramadan_countdown_10':
                    if ($daysUntilRamadan !== 10) continue 2;
                    break;

                default:
                    continue 2;
            }

            $usersToNotify = $usersQuery->get();
            // ... إرسال التنبيهات ...

            $usersToNotify = $usersQuery->get();

            if ($usersToNotify->isEmpty()) {
                $this->info("No users met condition for: {$notification->name}");
                continue;
            }

            $count = 0;
            foreach ($usersToNotify as $user) {
                $user->notify(new \App\Notifications\CustomUserNotification(
                    $notification->title, 
                    $notification->body, 
                    $imageUrl
                ));
                $count++;
            }

            $this->info("Sent '{$notification->name}' to {$count} users.");
        }

        $this->info('Automated notifications processed successfully.');
    }

    /**
     * Process notifications that depend on a user's material progress
     */
    private function processMaterialProgressNotification($notification, $today, $imageUrl)
    {
        $usersToNotify = User::whereNotNull('fcm_token')->with('division.materials')->get();
        $allMaterials = \App\Models\Material::pluck('name', 'id')->toArray();
        $count = 0;

        foreach ($usersToNotify as $user) {
            $progressData = $user->MaterialsProgress();
            if (empty($progressData)) continue;

            foreach ($progressData as $item) {
                $matId = $item['material_id'];
                $prog = $item['progress'];
                $matName = $allMaterials[$matId] ?? 'المادة';

                $shouldNotify = false;

                if ($notification->trigger_type == 'material_progress_0' && $prog == 0) {
                    // Send if it's been more than 7 days since account creation and they haven't started
                    if (Carbon::parse($user->created_at)->diffInDays(now()) >= 7) {
                        $shouldNotify = true;
                    }
                } elseif ($notification->trigger_type == 'material_progress_10' && $prog > 0 && $prog < 20) {
                    // Send if progress is between 1% and 20% and last studied exactly 3 days ago
                    $latestAnswer = \App\Models\UserAnswer::where('user_id', $user->id)
                        ->where('material_id', $matId)
                        ->max('created_at');
                    if ($latestAnswer && Carbon::parse($latestAnswer)->diffInDays(now()) == 3) {
                        $shouldNotify = true;
                    }
                } elseif ($notification->trigger_type == 'material_progress_50' && $prog >= 50 && $prog < 60) {
                    // Send if they just hit 50%+ today
                    $answeredToday = \App\Models\UserAnswer::where('user_id', $user->id)
                        ->where('material_id', $matId)
                        ->whereDate('created_at', $today)
                        ->exists();
                    if ($answeredToday) {
                        $shouldNotify = true;
                    }
                } elseif ($notification->trigger_type == 'material_progress_100' && $prog == 100) {
                    // Send if they hit 100% today
                    $answeredToday = \App\Models\UserAnswer::where('user_id', $user->id)
                        ->where('material_id', $matId)
                        ->whereDate('created_at', $today)
                        ->exists();
                    if ($answeredToday) {
                        $shouldNotify = true;
                    }
                }

                if ($shouldNotify) {
                    $title = str_replace('{material_name}', $matName, $notification->title);
                    $body = str_replace('{material_name}', $matName, $notification->body);

                    // Anti-spam: Check if we already sent this exact notification (for this material) 
                    // within the last 30 days
                    $alreadySent = \Illuminate\Support\Facades\DB::table('notifications')
                        ->where('notifiable_type', User::class)
                        ->where('notifiable_id', $user->id)
                        ->where('created_at', '>=', now()->subDays(30))
                        ->where('data', 'like', "%\"title\":\"{$title}\"%")
                        ->exists();

                    if (!$alreadySent) {
                        $user->notify(new \App\Notifications\CustomUserNotification($title, $body, $imageUrl));
                        $count++;
                        // Only notify for one material per rule daily to avoid bombing the user
                        break;
                    }
                }
            }
        }

        $this->info("Sent material progress '{$notification->name}' to {$count} users.");
    }
}
