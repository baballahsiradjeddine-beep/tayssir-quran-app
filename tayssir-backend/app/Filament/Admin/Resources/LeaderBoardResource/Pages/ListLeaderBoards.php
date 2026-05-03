<?php

namespace App\Filament\Admin\Resources\LeaderBoardResource\Pages;

use App\Filament\Admin\Resources\LeaderBoardResource;
use App\Models\UserAnswer;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;
use Filament\Resources\Components\Tab;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ListLeaderBoards extends ListRecords
{
    protected static string $resource = LeaderBoardResource::class;

    protected function getHeaderActions(): array
    {
        return [
            // Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make()
                ->label('الكل (الإجمالي)')
                ->icon('heroicon-o-globe-alt')
                ->badge(fn () => \App\Models\LeaderBoard::count()),

            'weekly' => Tab::make()
                ->label('الأسبوعي')
                ->icon('heroicon-o-calendar-days')
                ->badge(fn () => UserAnswer::where('created_at', '>=', Carbon::now()->startOfWeek())
                    ->distinct('user_id')->count())
                ->modifyQueryUsing(function (Builder $query) {
                    // Show only users who answered this week, ordered by their weekly points
                    $startOfWeek = Carbon::now()->startOfWeek();
                    $weeklyPoints = UserAnswer::select('user_id', DB::raw('SUM(points_earned) as weekly_points'))
                        ->where('created_at', '>=', $startOfWeek)
                        ->groupBy('user_id');

                    $query->joinSub($weeklyPoints, 'weekly', function ($join) {
                        $join->on('leader_boards.user_id', '=', 'weekly.user_id');
                    })->orderBy('weekly.weekly_points', 'desc')
                      ->addSelect('leader_boards.*', 'weekly.weekly_points as display_points');
                }),

            'daily' => Tab::make()
                ->label('اليومي')
                ->icon('heroicon-o-sun')
                ->badge(fn () => UserAnswer::where('created_at', '>=', Carbon::now()->startOfDay())
                    ->distinct('user_id')->count())
                ->modifyQueryUsing(function (Builder $query) {
                    // Show only users who answered today, ordered by their daily points
                    $startOfDay = Carbon::now()->startOfDay();
                    $dailyPoints = UserAnswer::select('user_id', DB::raw('SUM(points_earned) as daily_points'))
                        ->where('created_at', '>=', $startOfDay)
                        ->groupBy('user_id');

                    $query->joinSub($dailyPoints, 'daily', function ($join) {
                        $join->on('leader_boards.user_id', '=', 'daily.user_id');
                    })->orderBy('daily.daily_points', 'desc')
                      ->addSelect('leader_boards.*', 'daily.daily_points as display_points');
                }),
        ];
    }
}
