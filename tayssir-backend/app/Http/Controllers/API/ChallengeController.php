<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\API\BaseController;
use App\Models\ChallengeProgress;
use App\Models\Ayah;
use App\Models\Surah;
use Illuminate\Http\Request;

/**
 * ChallengeController
 * مسؤول عن إدارة "مبارزات الحفظ" بين المستخدمين.
 * تم تحويل المنطق من نظام المواد الدراسية إلى نظام السور القرآنية.
 */
class ChallengeController extends BaseController
{
    /**
     * جلب "آيات التحدي" بناءً على مستوى المستخدم في السورة المختارة.
     */
    public function getQuestions(Request $request, $surah_id)
    {
        try {
            $user = $request->user();

            // 1. الحصول على أو إنشاء سجل التقدم في هذا التحدي
            // ملاحظة: أعدنا استخدام جدول challenge_progresses القديم مع تغيير المفهوم
            $progress = ChallengeProgress::firstOrCreate(
                ['user_id' => $user->id, 'unit_id' => $surah_id], // نستخدم unit_id لتخزين معرف السورة مؤقتاً لتجنب تغيير قاعدة البيانات
                ['level' => 1, 'points' => 0, 'games_played' => 0, 'games_won' => 0]
            );

            $surah = Surah::findOrFail($surah_id);
            
            // 2. جلب آيات عشوائية من السورة المختارة لعمل التحدي
            // في المرحلة القادمة سنضيف "أنواع الأسئلة" (أكمل الآية، من أي سورة، إلخ)
            $ayahs = Ayah::where('surah_id', $surah->id)
                ->inRandomOrder()
                ->take(10)
                ->get();

            if ($ayahs->isEmpty()) {
                return $this->sendError('لا توجد آيات كافية للتحدي في هذه السورة حالياً.', [], 404);
            }

            return $this->sendResponse([
                'surah' => [
                    'id' => $surah->id,
                    'name' => $surah->name_ar,
                ],
                'progress' => [
                    'level' => $progress->level,
                    'points' => $progress->points,
                    'rank_name' => $user->wilayah_rank_name,
                ],
                'questions' => $ayahs, // نرسل الآيات كأسئلة مبدئياً
            ], 'تم جلب آيات التحدي بنجاح');
        } catch (\Exception $e) {
            return $this->sendError('Backend Error: ' . $e->getMessage(), [], 500);
        }
    }

    /**
     * تسجيل نتائج مبارزة الحفظ.
     */
    public function submitResult(Request $request)
    {
        $request->validate([
            'surah_id' => 'required|exists:surahs,id',
            'is_winner' => 'required|boolean',
            'points_gained' => 'required|integer|min:0',
        ]);

        try {
            $user = $request->user();
            $surah_id = $request->surah_id;
            $isWinner = $request->is_winner;
            $pointsGained = $request->points_gained;

            $progress = ChallengeProgress::firstOrCreate(
                ['user_id' => $user->id, 'unit_id' => $surah_id],
                ['level' => 1, 'points' => 0, 'games_played' => 0, 'games_won' => 0]
            );

            $progress->games_played += 1;
            if ($isWinner) {
                $progress->games_won += 1;
            }

            $progress->points += $pointsGained;
            
            // تحديث نقاط الخبرة الإجمالية للمستخدم (XP)
            $user->xp_points += $pointsGained;
            $user->save();

            // منطق الترقية: المستوى = floor(الانتصارات / 3) + 1
            $progress->level = max(1, floor($progress->games_won / 3) + 1);
            $progress->save();

            return $this->sendResponse([
                'progress' => [
                    'level' => $progress->level,
                    'points' => $progress->points,
                    'games_played' => $progress->games_played,
                    'games_won' => $progress->games_won,
                    'total_xp' => $user->xp_points,
                ]
            ], 'تم حفظ نتيجة المبارزة بنجاح');
        } catch (\Exception $e) {
            return $this->sendError('Server Error: ' . $e->getMessage(), [], 500);
        }
    }
}
