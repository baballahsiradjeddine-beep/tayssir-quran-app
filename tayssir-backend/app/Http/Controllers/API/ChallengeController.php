<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\API\BaseController;
use App\Models\ChallengeProgress;
use App\Models\Ayah;
use App\Models\Surah;
use Illuminate\Http\Request;

class ChallengeController extends BaseController
{
    public function getQuestions(Request $request, $surah_id)
    {
        try {
            $user = $request->user();
            $surah = Surah::findOrFail($surah_id);
            
            // Get 10 random ayahs from this surah
            $ayahs = Ayah::where('surah_id', $surah->id)
                ->inRandomOrder()
                ->take(10)
                ->get();

            if ($ayahs->isEmpty()) {
                return $this->sendError('لا توجد آيات كافية للتحدي في هذه السورة حالياً.', [], 404);
            }

            $formattedQuestions = [];
            foreach ($ayahs as $index => $ayah) {
                // Generate a "Complete the Verse" question
                $words = explode(' ', $ayah->text_ar);
                if (count($words) < 4) {
                    $questionText = "ما هي هذه الآية؟";
                    $missingPart = $ayah->text_ar;
                } else {
                    $midPoint = floor(count($words) / 2);
                    $questionText = implode(' ', array_slice($words, 0, $midPoint)) . ' ...';
                    $missingPart = implode(' ', array_slice($words, $midPoint));
                }

                // Generate 3 wrong options from other ayahs
                $wrongAyahs = Ayah::where('id', '!=', $ayah->id)
                    ->inRandomOrder()
                    ->take(3)
                    ->get();
                
                $options = [
                    ['id' => 'correct', 'text' => $missingPart, 'is_correct' => true]
                ];

                foreach ($wrongAyahs as $wIndex => $wAyah) {
                    $wWords = explode(' ', $wAyah->text_ar);
                    $wPart = implode(' ', array_slice($wWords, -min(3, count($wWords))));
                    $options[] = ['id' => 'wrong_'.$wIndex, 'text' => $wPart, 'is_correct' => false];
                }

                shuffle($options);

                $formattedQuestions[] = [
                    'id' => $ayah->id,
                    'question' => $questionText,
                    'question_type' => 'multiple_choices',
                    'options' => $options,
                ];
            }

            return $this->sendResponse([
                'surah' => [
                    'id' => $surah->id,
                    'name' => $surah->name_ar,
                ],
                'questions' => $formattedQuestions,
            ], 'تم جلب آيات التحدي بنجاح');
        } catch (\Exception $e) {
            return $this->sendError('Backend Error: ' . $e->getMessage(), [], 500);
        }
    }

    public function submitResult(Request $request)
    {
        $request->validate([
            'unit_id' => 'required', // unit_id is surah_id
            'is_winner' => 'required|boolean',
            'points_gained' => 'required|integer|min:0',
        ]);

        try {
            $user = $request->user();
            $surah_id = $request->unit_id;
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
            $user->xp_points += $pointsGained;
            $user->save();

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
