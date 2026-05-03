<?php

namespace App\Filament\Admin\Widgets;

use App\Enums\QuestionScope;
use App\Models\Chapter;
use App\Models\Division;
use App\Models\Material;
use App\Models\Question;
use App\Models\Subscription;
use App\Models\SubscriptionCard;
use App\Models\Unit;
use App\Models\User;
use App\Models\UserAnswer;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Spatie\FilamentSimpleStats\SimpleStat;

class PlatformAnalytics extends BaseWidget
{
    protected static bool $isDiscovered = false;
    protected string|array|int $columnSpan = 4;
    protected static ?int $sort = 2;

    protected function getStats(): array
    {
        return [
            // User statistics
            SimpleStat::make(User::class)
                ->last30Days()
                ->dailyCount()
                ->label("حفاظ منضمون حديثاً")
                ->description("آخر 30 يوماً")
                ->color('success'),

            Stat::make("إجمالي الحفاظ", User::count())
                ->description("العدد الكلي للحفاظ المسجلين")
                ->chart([7, 10, 12, 15, 18, 20, User::count()])
                ->color('primary'),

            SimpleStat::make(User::class)
                ->lastDays(7)
                ->dailyCount()
                ->label(__('stats.users.thisWeek'))
                ->description(__('stats.users.last7Days'))
                // ->descriptionIcon('heroicon-o-user-plus')
                ->color('info'),

            // Subscription statistics
            SimpleStat::make(Subscription::class)
                ->lastDays(30)
                ->dailyCount()
                ->label("المساهمات النشطة في الوقف")
                ->description("إجمالي الواقفين هذا الشهر")
                ->color('success'),

            SimpleStat::make(SubscriptionCard::class)
                ->lastDays(30)
                ->dailyCount()
                ->label(__('stats.subscriptions.cards'))
                ->description(__('stats.subscriptions.created'))
                // ->descriptionIcon('heroicon-o-ticket')
                ->color('warning'),

            Stat::make(__('stats.subscriptions.redeemed'), SubscriptionCard::whereNotNull('redeemed_at')->count())
                ->description(__('stats.subscriptions.total_redeemed'))
                // ->descriptionIcon('heroicon-o-check-badge')
                ->chart([2, 5, 8, 10, 15, SubscriptionCard::whereNotNull('redeemed_at')->count()])
                ->color('success'),

            // Material, Unit, and Chapter statistics
            Stat::make("عدد السور المتاحة", Material::count())
                ->description("إجمالي السور المفعلة")
                ->color('primary'),

            Stat::make("عدد الأرباع والأثمان", Unit::count())
                ->description("إجمالي الأقسام القرآنية")
                ->color('info'),

            Stat::make("عدد الآيات والمواضيع", Chapter::count())
                ->description("إجمالي مجموعات الآيات")
                ->color('success'),

            // Question statistics
            Stat::make("إجمالي أسئلة التثبيت", Question::count())
                ->description("عدد الأسئلة المتوفرة للمراجعة")
                ->chart([10, 20, 30, Question::count()])
                ->color('warning'),

            Stat::make(
                __('stats.questions.lesson'),
                Question::where('scope', QuestionScope::LESSON)->count()
            )
                ->description(__('stats.questions.lesson_desc'))
                // ->descriptionIcon('heroicon-o-bookmark')
                ->color('info'),

            Stat::make(
                __('stats.questions.exercise'),
                Question::where('scope', QuestionScope::EXERCICE)->count()
            )
                ->description(__('stats.questions.exercise_desc'))
                // ->descriptionIcon('heroicon-o-clipboard-document-list')
                ->color('success'),

            // User engagement statistics
            SimpleStat::make(UserAnswer::class)
                ->lastDays(30)
                ->dailyCount()
                ->label(__('stats.answers.recent'))
                ->description(__('stats.answers.last30Days'))
                // ->descriptionIcon('heroicon-o-pencil-square')
                ->color('primary'),

            Stat::make(
                __('stats.answers.points'),
                UserAnswer::sum('points_earned')
            )
                ->description(__('stats.answers.points_desc'))
                // ->descriptionIcon('heroicon-o-trophy')
                ->color('success'),

            // Division statistics
            Stat::make(__('stats.divisions.total'), Division::count())
                ->description(__('stats.divisions.available'))
                // ->descriptionIcon('heroicon-o-building-library')
                ->color('info'),

        ];
    }
}
