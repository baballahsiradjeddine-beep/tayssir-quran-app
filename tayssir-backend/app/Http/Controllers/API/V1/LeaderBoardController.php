<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\BaseController;
use App\Models\Badge;
use App\Models\LeaderBoard;
use App\Models\User;
use App\Models\UserAnswer;
use Dedoc\Scramble\Attributes\Group;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

#[Group('Leaderboard APIs', weight: 7)]
class LeaderBoardController extends BaseController
{
    /**
     * Leader board.
     *
     * This endpoint returns a list of users paginated with query param 'page' and 'per_page', the list of users contains name, image, points.
     * Use 'type=weekly' for weekly leaderboard (last 7 days) and 'type=global' (default) for all-time.
     */
    public function index(Request $request)
    {
        $perPage = $request->input('per_page', 10);
        $currentPage = $request->input('page', 1);
        $type = $request->input('type', 'global');

        if ($type === 'weekly') {
            // Calculate starting from 7 days ago
            $startDate = Carbon::now()->startOfWeek(); // This week starting Monday
            
            $leaderBoardQuery = UserAnswer::where('created_at', '>=', $startDate)
                ->select('user_id', DB::raw('SUM(points_earned) as points'))
                ->groupBy('user_id')
                ->orderBy('points', 'desc');
                
            $leaderBoard = $leaderBoardQuery->paginate($perPage, page: $currentPage);
            
            // We need to load user relations manually for the paginated items
            $leaderBoard->getCollection()->transform(function($item) {
                $item->user = User::with(['wilaya', 'commune'])->find($item->user_id);
                return $item;
            });
            
            $totalItems = UserAnswer::where('created_at', '>=', $startDate)->distinct('user_id')->count();
        } elseif ($type === 'daily') {
            // Calculate starting from today
            $startDate = Carbon::now()->startOfDay(); // Today
            
            $leaderBoardQuery = UserAnswer::where('created_at', '>=', $startDate)
                ->select('user_id', DB::raw('SUM(points_earned) as points'))
                ->groupBy('user_id')
                ->orderBy('points', 'desc');
                
            $leaderBoard = $leaderBoardQuery->paginate($perPage, page: $currentPage);
            
            // We need to load user relations manually for the paginated items
            $leaderBoard->getCollection()->transform(function($item) {
                $item->user = User::with(['wilaya', 'commune'])->find($item->user_id);
                return $item;
            });
            
            $totalItems = UserAnswer::where('created_at', '>=', $startDate)->distinct('user_id')->count();
        } else {
            // Default Global Leaderboard
            $leaderBoard = LeaderBoard::with(['user' => function ($query) {
                $query->with(['wilaya', 'commune']);
            }])
                ->orderBy('points', 'desc')
                ->paginate($perPage, page: $currentPage);
                
            $totalItems = LeaderBoard::count();
        }

        $leaderboardData = [];
        foreach ($leaderBoard as $item) {
            if (!$item->user) continue;
            
            $badge = $item->user->current_badge;
            $leaderboardData[] = [
                'id' => $item->user->id,
                'name' => $item->user->name,
                'avatar_url' => $item->user->avatar_image,
                'points' => (int)$item->points,
                'wilaya' => $item->user->wilaya ? $item->user->wilaya->arabic_name : 'الجزائر',
                'commune' => $item->user->commune ? $item->user->commune->arabic_name : null,
                'badge' => $badge ? [
                    'name' => $badge->name,
                    'color' => $badge->color,
                    'icon_url' => $badge->icon,
                ] : null,
            ];
        }

        $result = [
            'page' => $currentPage,
            'per_page' => $perPage,
            'total_items' => $totalItems,
            'total_pages' => $leaderBoard->lastPage(),
            'current_page' => $currentPage,
            'data' => $leaderboardData,
        ];

        return $this->sendResponse($result);
    }
}
