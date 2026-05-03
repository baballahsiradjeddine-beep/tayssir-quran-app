<?php

namespace Database\Seeders;

use App\Models\Material;
use App\Models\Unit;
use App\Models\Chapter;
use App\Models\ChapterLevel;
use App\Models\Question;
use App\Enums\QuestionType;
use App\Enums\QuestionScope;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;

class TajweedCleanBuildSeeder extends Seeder
{
    public function run()
    {
        $material = Material::where('code', 'TAJ-WARSH')->first();
        if (!$material) {
            $material = Material::create(['code' => 'TAJ-WARSH', 'name' => 'أحكام التجويد (ورش)', 'active' => true, 'direction' => 'RTL', 'division_id' => 1]);
        }
        $material->divisions()->syncWithoutDetaching([1, 2]); // Sync to both divisions for testing

        // Clean existing units/chapters for this material to avoid duplicates
        $this->command->info('Cleaning existing TAJ-WARSH data...');
        $material->units->each(function($unit) {
            $unit->chapters->each(function($chapter) {
                $chapter->subscriptions()->detach();
                $chapter->questions()->each(function($q) { $q->delete(); });
                $chapter->questions()->detach();
                $chapter->delete();
            });
            $unit->subscriptions()->detach();
            $unit->delete();
        });
        $material->units()->detach();

        // Load JSON Data
        $path = database_path('data/tajweed_curriculum.json');
        if (!File::exists($path)) {
            $this->command->error('JSON file not found!');
            return;
        }
        $data = json_decode(File::get($path), true);

        $levels = [
            'beginner' => ChapterLevel::firstOrCreate(['name' => 'مبتدئ']),
            'intermediate' => ChapterLevel::firstOrCreate(['name' => 'متوسط']),
            'advanced' => ChapterLevel::firstOrCreate(['name' => 'متقدم']),
        ];

        foreach ($data as $uIndex => $uData) {
            $unit = Unit::create([
                'name' => $uData['unit'],
                'description' => $uData['unit'],
                'active' => true
            ]);
            $material->units()->attach($unit->id, ['sort' => $uIndex + 1]);
            $unit->subscriptions()->attach(1);

            $chapterGlobalSort = 1;
            foreach ($uData['topics'] as $topic) {
                // We use the topic title in the description of chapters belonging to it
                foreach ($topic['chapters'] as $cData) {
                    $chapter = Chapter::create([
                        'name' => $cData['name'],
                        'type' => $cData['type'],
                        'chapter_level_id' => $levels[$cData['level']]->id,
                        'description' => $topic['title'], // Categorization label
                        'content' => $cData['content'] ?? [],
                        'active' => true
                    ]);
                    $unit->chapters()->attach($chapter->id, ['sort' => $chapterGlobalSort++]);
                    $chapter->subscriptions()->attach(1); // Attach chapters to subscription too

                    if (isset($cData['questions'])) {
                        foreach ($cData['questions'] as $qIndex => $qData) {
                            $type = $this->getQuestionType($qData['type']);
                            $question = Question::create([
                                'question' => $qData['q'],
                                'question_type' => $type,
                                'options' => $qData['opt'],
                                'explanation_text' => $qData['exp'] ?? null,
                                'scope' => QuestionScope::EXERCICE,
                                'direction' => 'RTL',
                            ]);
                            $chapter->questions()->attach($question->id, ['sort' => $qIndex + 1]);
                        }
                    }
                }
            }
        }

        $this->command->info('Professional JSON Curriculum Synchronized Successfully!');
    }

    private function getQuestionType($type)
    {
        return match ($type) {
            'multiple_choices' => QuestionType::MULTIPLE_CHOICES,
            'true_or_false' => QuestionType::TRUE_OR_FALSE,
            'pick_the_intruder' => QuestionType::PICK_THE_INTRUDER,
            'match_with_arrows' => QuestionType::MATCH_WITH_ARROWS,
            'fill_in_the_blanks' => QuestionType::FILL_IN_THE_BLANKS,
            default => QuestionType::MULTIPLE_CHOICES,
        };
    }
}
