<?php

namespace App\Services\Content;

use App\Models\Chapter;
use App\Models\User;
use App\Models\UserAnswer;
use App\Models\UserChapterBonus;
use Illuminate\Support\Facades\DB;

class AnswerSubmissionService
{
    /**
     * Handle bulk submission of chapter answers and return progress/points payload
     *
     * @param  array  $answers  [ ['question_id' => int, 'answered_correctly' => bool], ... ]
     */
    public function submit(User $user, int $chapterId, array $answers, ?int $totalSlides = null): array
    {
        return DB::transaction(function () use ($user, $chapterId, $answers, $totalSlides) {
            $chapter = Chapter::with([
                'unit',
                'questions' => function ($query) use ($answers) {
                    $questionIds = array_column($answers, 'question_id');
                    $query->whereIn('questions.id', $questionIds);
                },
                'chapter_level',
            ])->findOrFail($chapterId);

            $unit = $chapter->unit()->first();
            $material = $unit->material()->first();

            $isLesson = $chapter->type === 'lesson';
            $earnedPointsInThisSubmission = 0;
            $earnedBonusPointsInThisSubmission = 0;
            $userAnswersData = [];
            $now = now();

            if ($isLesson) {
                // For lessons, we use totalSlides as points (one point per slide)
                $points = $totalSlides ?? 0;
                
                // We use UserChapterBonus to track lesson completion and points
                $existingBonus = UserChapterBonus::where('user_id', $user->id)
                    ->where('chapter_id', $chapterId)
                    ->first();

                if (!$existingBonus) {
                    UserChapterBonus::create([
                        'user_id' => $user->id,
                        'chapter_id' => $chapterId,
                        'bonus_points' => $points,
                    ]);
                    $earnedPointsInThisSubmission = $points;
                } else {
                    // Update if points increased (though usually slides don't change)
                    if ($points > $existingBonus->bonus_points) {
                        $diff = $points - $existingBonus->bonus_points;
                        $existingBonus->update(['bonus_points' => $points]);
                        $earnedPointsInThisSubmission = $diff;
                    }
                }
            } else {
                // Exercise Logic
                $questionsMap = $chapter->questions->keyBy('id');
                $existingAnswers = UserAnswer::where('user_id', $user->id)
                    ->where('chapter_id', $chapterId)
                    ->get()
                    ->keyBy('question_id');

                $totalSubmittedQuestions = count($answers);
                $correctAnswers = 0;

                foreach ($answers as $answer) {
                    $questionId = $answer['question_id'];
                    if (! isset($questionsMap[$questionId])) continue;

                    $question = $questionsMap[$questionId];
                    $isCorrect = (bool) ($answer['answered_correctly'] ?? false);
                    if ($isCorrect) $correctAnswers++;

                    $points = $isCorrect ? $question->points : 0;

                    if (isset($existingAnswers[$questionId]) && $existingAnswers[$questionId]->points_earned > $points) {
                        continue;
                    }

                    if ($isCorrect) {
                        $previousPoints = isset($existingAnswers[$questionId]) ? $existingAnswers[$questionId]->points_earned : 0;
                        $earnedPointsInThisSubmission += max(0, $points - $previousPoints);
                    }

                    if (isset($existingAnswers[$questionId])) {
                        $existingAnswers[$questionId]->delete();
                    }

                    if ($isCorrect) {
                        $userAnswersData[] = [
                            'user_id' => $user->id,
                            'question_id' => $questionId,
                            'chapter_id' => $chapterId,
                            'unit_id' => $unit->id,
                            'material_id' => $material->id,
                            'points_earned' => $points,
                            'created_at' => $now,
                            'updated_at' => $now,
                        ];
                    } else {
                        \App\Models\UserMistake::updateOrCreate(
                            ['user_id' => $user->id, 'question_id' => $questionId],
                            [
                                'last_mistake_at' => $now,
                                'next_review_at' => $now->copy()->addDay()->startOfDay(),
                                'mistake_count' => DB::raw('mistake_count + 1'),
                                'mastery_level' => DB::raw('GREATEST(0, mastery_level - 10)'),
                            ]
                        );
                    }
                }

                if (! empty($userAnswersData)) {
                    UserAnswer::insert($userAnswersData);
                }

                $correctPercentage = $totalSubmittedQuestions > 0 ? ($correctAnswers / $totalSubmittedQuestions) * 100 : 0;
                $allQuestionsSubmitted = $totalSubmittedQuestions === $chapter->questions()->count();

                if ($allQuestionsSubmitted && $correctPercentage >= 50 && $chapter->chapter_level) {
                    $bonusPoints = $chapter->chapter_level->bonus;
                    $existingBonus = UserChapterBonus::where('user_id', $user->id)
                        ->where('chapter_id', $chapterId)
                        ->first();

                    if (! $existingBonus && $bonusPoints > 0) {
                        UserChapterBonus::create([
                            'user_id' => $user->id,
                            'chapter_id' => $chapterId,
                            'bonus_points' => $bonusPoints,
                        ]);
                        $earnedBonusPointsInThisSubmission = $bonusPoints;
                    }
                }
            }

            $materialProgress = $user->materialProgress($material);
            $unitProgress = $user->unitProgress($unit);
            $chapterProgress = $user->chapterProgress($chapter);

            $materialPoints = $user->materialPoints($material);
            $unitPoints = $user->unitPoints($unit);
            $chapterPoints = $user->chapterPoints($chapter);

            $chapterTotalBonusPoints = UserChapterBonus::where('user_id', $user->id)
                ->where('chapter_id', $chapterId)
                ->value('bonus_points') ?? 0;

            return [
                'total_answers' => count($userAnswersData),
                'progress' => [
                    'material' => [
                        'id' => $material->id,
                        'progress' => $materialProgress,
                        'points' => $materialPoints,
                    ],
                    'unit' => [
                        'id' => $unit->id,
                        'progress' => $unitProgress,
                        'points' => $unitPoints,
                    ],
                    'chapter' => [
                        'id' => $chapter->id,
                        'progress' => $chapterProgress,
                        'points' => $chapterPoints,
                        'bonus_points' => $chapterTotalBonusPoints,
                        'earned_points' => $earnedPointsInThisSubmission,
                        'earned_bonus_points' => $earnedBonusPointsInThisSubmission,
                    ],
                ],
            ];
        });
    }
}
