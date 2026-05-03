<?php

namespace App\Http\Requests\API;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SubmitChapterAnswersRequest extends FormRequest
{
    public function authorize(): bool
    {
        $user = $this->user();
        if (! $user) {
            return false;
        }

        // Verify the chapter exists and is part of user's subscribed content
        $chapterId = $this->input('chapter_id');
        $chapter = \App\Models\Chapter::find($chapterId);
        if (! $chapter) {
            return false;
        }
        $unit = $chapter->unit()->first();
        if (! $unit) {
            return false;
        }

        // Check if user has subscription for this unit's content
        return $unit
            ->subscriptions()
            ->whereIn('subscriptions.id', $user->subscriptions->pluck('id'))
            ->exists();

        // Note: we've removed any checks for existing answers to allow resubmissions
    }

    public function rules(): array
    {
        $chapterId = $this->input('chapter_id');
        $chapter = \App\Models\Chapter::find($chapterId);
        $isLesson = $chapter && $chapter->type === 'lesson';

        return [
            'chapter_id' => ['required', 'integer', 'exists:chapters,id'],
            'answers' => [$isLesson ? 'nullable' : 'required', 'array'],
            'answers.*.question_id' => [
                $isLesson ? 'nullable' : 'required',
                'integer',
                'exists:questions,id',
                Rule::exists('chapter_question', 'question_id')->where('chapter_id', $chapterId),
            ],
            'answers.*.answered_correctly' => [$isLesson ? 'nullable' : 'required', 'boolean'],
            'total_slides' => [$isLesson ? 'required' : 'nullable', 'integer'],
        ];
    }
}
