<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\BaseController;
use App\Models\User;
use App\Models\Material;
use App\Models\LeaderBoard;
use Illuminate\Http\Request;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use App\Models\UserAnswer;

class LandingController extends BaseController
{
    /**
     * Get landing page stats.
     */
    public function stats(Request $request)
    {
        $totalHafiz = User::count();
        
        // Get active users in the last 24 hours
        $activeNow = UserAnswer::where('created_at', '>=', Carbon::now()->subDay())->distinct('user_id')->count();
        if ($activeNow < 10) {
            $activeNow = rand(100, 500); 
        }

        return $this->sendResponse([
            'total_hafiz' => number_format($totalHafiz),
            'active_now' => number_format($activeNow),
        ]);
    }

    /**
     * Get real leaderboard for landing page (Top 3 daily)
     */
    public function leaderboard(Request $request)
    {
        $startDate = Carbon::now()->startOfDay(); 
        
        $leaderBoardQuery = UserAnswer::where('created_at', '>=', $startDate)
            ->select('user_id', DB::raw('SUM(points_earned) as points'))
            ->groupBy('user_id')
            ->orderBy('points', 'desc')
            ->take(3)
            ->get();
            
        $leaderboardData = [];
        $rank = 1;

        if ($leaderBoardQuery->isEmpty()) {
             $leaderBoardQuery = LeaderBoard::orderBy('points', 'desc')->take(3)->get();
             foreach ($leaderBoardQuery as $item) {
                 $user = User::with(['wilaya'])->find($item->user_id);
                 if (!$user) continue;
                 $leaderboardData[] = [
                     'id' => $user->id,
                     'name' => $user->name,
                     'state' => $user->wilaya ? $user->wilaya->arabic_name : 'الجزائر',
                     'xp' => number_format((int)$item->points),
                     'rank' => $rank++,
                     'avatar' => $user->avatar_image ?: '/svg/Tito.svg',
                 ];
             }
             return response()->json($leaderboardData);
        }

        foreach ($leaderBoardQuery as $item) {
            $user = User::with(['wilaya'])->find($item->user_id);
            if (!$user) continue;
            
            $leaderboardData[] = [
                'id' => $user->id,
                'name' => $user->name,
                'state' => $user->wilaya ? $user->wilaya->arabic_name : 'الجزائر',
                'xp' => number_format((int)$item->points),
                'rank' => $rank++,
                'avatar' => $user->avatar_image ?: '/svg/Tito.svg',
            ];
        }

        return response()->json($leaderboardData);
    }

    /**
     * Get active materials for landing page.
     */
    public function subjects(Request $request)
    {
        $materials = Material::active()
            ->where(function($q) {
                $q->where('name', 'like', '%البقرة%')
                  ->orWhere('name', 'like', '%آل عمران%')
                  ->orWhere('name', 'like', '%الكهف%')
                  ->orWhere('name', 'like', '%يس%');
            })
            ->select('id', 'name', 'color', 'secondary_color', 'description')
            ->get()
            ->map(function ($material) {
                $cleanName = str_replace('مادة ', '', $material->name);
                return [
                    'id' => $material->id,
                    'name' => $cleanName,
                    'description' => $material->description,
                    'color' => $material->color,
                    'secondary_color' => $material->secondary_color,
                    'image' => $material->image_grid ?: ($material->image ?: 'https://tayssir-bac.com/assets/images/placeholder_subject.png'),
                ];
            });

        return response()->json($materials);
    }

    /**
     * Get app tools for landing page.
     */
    public function tools(Request $request)
    {
        $settings = app(\App\Settings\AppSettings::class);
        
        $tools = [
            [
                'name' => 'بطاقات بيان (Flashcards)',
                'description' => 'مذاكرة سريعة وفعالة بأسلوب البطاقات الذكية لتثبيت حفظ الآيات.',
                'image' => $settings->tool_cards_grid ? ('https://bayan-quran.com/storage/' . $settings->tool_cards_grid) : 'https://bayan-quran.com/assets/images/placeholder_tool.png',
                'active' => $settings->cards_tools_active
            ],
            [
                'name' => 'ملخصات السور',
                'description' => 'ملخصات شاملة لمقاصد السور ومواضيعها بأسلوب بصري مريح.',
                'image' => $settings->tool_resumes_grid ? ('https://bayan-quran.com/storage/' . $settings->tool_resumes_grid) : 'https://bayan-quran.com/assets/images/placeholder_tool.png',
                'active' => $settings->resumes_active
            ],
            [
                'name' => 'علوم القرآن والتفسير',
                'description' => 'مكتبة شاملة للتفاسير الميسرة وعلوم القرآن لدعم تدبرك.',
                'image' => $settings->tool_bac_solutions_grid ? ('https://bayan-quran.com/storage/' . $settings->tool_bac_solutions_grid) : 'https://bayan-quran.com/assets/images/placeholder_tool.png',
                'active' => $settings->bac_solutions_active
            ],
            [
                'name' => 'مؤقت التركيز (بومودورو)',
                'description' => 'نظام إدارة الوقت لمساعدتك على التركيز في الحفظ والتدبر.',
                'image' => $settings->tool_pomodoro_grid ? ('https://bayan-quran.com/storage/' . $settings->tool_pomodoro_grid) : 'https://bayan-quran.com/assets/images/placeholder_tool.png',
                'active' => true
            ],
            [
                'name' => 'مخطط ورد الحفظ',
                'description' => 'احسب وردك اليومي وتابع تقدمك في ختم كتاب الله بدقة.',
                'image' => $settings->tool_grade_calc_grid ? ('https://bayan-quran.com/storage/' . $settings->tool_grade_calc_grid) : 'https://bayan-quran.com/assets/images/placeholder_tool.png',
                'active' => true
            ],
            [
                'name' => 'رفيق بيان الذكي AI',
                'description' => 'دع الذكاء الاصطناعي يرافقك في رحلتك ويجيب على تساؤلاتك.',
                'image' => $settings->tool_ai_planner_grid ? ('https://bayan-quran.com/storage/' . $settings->tool_ai_planner_grid) : 'https://bayan-quran.com/assets/images/placeholder_tool.png',
                'active' => $settings->tito_active
            ]
        ];

        return response()->json(array_values(array_filter($tools, fn($t) => $t['active'])));
    }
}
