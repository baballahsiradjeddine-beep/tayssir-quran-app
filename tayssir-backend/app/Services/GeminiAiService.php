<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GeminiAiService
{
    /**
     * Main method to call Gemini API
     */
    protected static function callGemini(string $prompt, ?string $textContext = null, ?string $pdfFilePath = null, bool $expectJson = false, ?string $modelOverride = null): array|string
    {
        // 1. Get API Key
        $dbKey = \App\Models\GeminiSetting::where('key', 'api_key')->first()?->value;
        $apiKey = trim($dbKey ?: env('GEMINI_API_KEY'));
        
        if (empty($apiKey)) {
            throw new \Exception('مفتاح الـ API غير موجود. يرجى إضافته في الإعدادات.');
        }

        // 2. Build Parts
        $parts = [['text' => $prompt]];
        if (!empty($textContext)) {
            $parts[] = ['text' => "--- CONTEXT ---\n" . $textContext];
        }

        if (!empty($pdfFilePath)) {
            if (file_exists($pdfFilePath)) {
                $fileSize = filesize($pdfFilePath);
                Log::info("Gemini: Attaching PDF", ['path' => $pdfFilePath, 'size' => $fileSize]);
                
                $parts[] = [
                    'inline_data' => [
                        'mime_type' => 'application/pdf',
                        'data' => base64_encode(file_get_contents($pdfFilePath))
                    ]
                ];
            } else {
                Log::error("Gemini: PDF File NOT FOUND", ['path' => $pdfFilePath]);
                throw new \Exception("لم يتم العثور على ملف الـ PDF في المسار: " . $pdfFilePath);
            }
        }

        // 3. Determine Model
        $dbModel = \App\Models\GeminiSetting::where('key', 'model_name')->first()?->value;
        $modelInput = trim($modelOverride ?: ($dbModel ?: 'gemini-2.0-flash'));
        $cleanModel = ltrim(str_replace('models/', '', $modelInput), '/');
        
        // Use v1beta for everything as it's the most compatible with both 1.5 and 2.x models
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$cleanModel}:generateContent?key={$apiKey}";

        // 4. Build Payload
        $payload = [
            'contents' => [['role' => 'user', 'parts' => $parts]],
            'generationConfig' => [
                'temperature' => 0.4,
            ]
        ];

        // Only add response_mime_type if we're actually expecting JSON
        if ($expectJson) {
            $payload['generationConfig']['response_mime_type'] = 'application/json';
        }

        // 5. Execute Request
        $response = Http::withHeaders(['Content-Type' => 'application/json'])
            ->timeout(120)
            ->post($url, $payload);

        if (!$response->successful()) {
            $status = $response->status();
            $body = $response->body();
            Log::error("Gemini API Error", ['status' => $status, 'body' => $body]);

            if ($status === 404) {
                throw new \Exception("الموديل ({$cleanModel}) غير متوفر. تأكد من صحة الاسم في الإعدادات.");
            }
            if ($status === 400 && str_contains($body, 'API_KEY_INVALID')) {
                throw new \Exception("مفتاح الـ API غير صالح.");
            }
            
            throw new \Exception("خطأ في الاتصال ({$status}): " . ($response->json()['error']['message'] ?? 'فشل الاتصال بجوجل'));
        }

        // 6. Parse Result
        $result = $response->json();
        $text = $result['candidates'][0]['content']['parts'][0]['text'] ?? '';

        if (!$expectJson) return $text;

        // Extract JSON if it exists in markdown blocks
        if (preg_match('/\[\s*\{.*\}\s*\]/s', $text, $matches)) {
            $text = $matches[0];
        } else {
            $text = trim(preg_replace('/^```json\s*|```\s*$/', '', $text));
        }

        $decoded = json_decode($text, true);
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new \Exception('فشل في تحليل بيانات الـ JSON المستلمة.');
        }

        return $decoded;
    }

    /**
     * Simple chat interface
     */
    public static function chat(string $prompt, ?string $model = null): string
    {
        try {
            return self::callGemini($prompt, null, null, false, $model);
        } catch (\Exception $e) {
            return "Error: " . $e->getMessage();
        }
    }

    /**
     * Specialized methods for content generation
     */
    public static function analyzePdfForChapters(string $pdfFilePath, ?string $extraInstructions = null): array
    {
        $dbSetting = \App\Models\GeminiSetting::where('key', 'unit_analysis_prompt')->first();
        $prompt = ($dbSetting && !empty($dbSetting->value)) ? $dbSetting->value : "I have attached a study document (PDF). Please analyze it and suggest a logical structure to divide it into multiple chapters or lessons. For each chapter, provide a clear Arabic title and a brief description of the topics covered in that chapter. Output ONLY a JSON array of objects: [{\"title\": \"...\", \"description\": \"...\", \"q_count\": 10}] in Arabic.";

        if (!empty($extraInstructions)) {
            $prompt .= "\n\nAdditional instructions for this analysis: " . $extraInstructions;
        }

        return self::callGemini($prompt, null, $pdfFilePath, true);
    }

    public static function generateQuestionsForChapter(string $pdfFilePath, string $chapterTitle, string $chapterDescription, int $count = 10): array
    {
        $prompt = self::getSystemPromptTemplate($count, 'mix');
        $context = "Focus on chapter: \"{$chapterTitle}\". Description: {$chapterDescription}";

        return self::callGemini($prompt, $context, $pdfFilePath, true);
    }

    public static function generateQuestions(?string $textContext, ?string $pdfFilePath, int $count, string $types): array
    {
        $prompt = self::getSystemPromptTemplate($count, $types);
        return self::callGemini($prompt, $textContext ?? '', $pdfFilePath, true);
    }

    /**
     * Real-time Recitation Analysis (Audio + Text)
     * Analyzes student audio against target Quranic text
     */
    public static function analyzeRecitation(string $audioFilePath, string $targetText): array
    {
        $prompt = <<<PROMPT
You are an expert Quran and Tajweed teacher. 
I am providing you with an audio recording of a student reciting a specific text.
TARGET TEXT: "{$targetText}"

Your task is to analyze the audio and compare it to the target text.
Focus on:
1. Word accuracy (did they say the right words?).
2. Tashkeel (vowels) accuracy.
3. Basic Tajweed (Ghunnah, Qalqalah, Madd) if applicable.

Output ONLY a JSON object with this structure:
{
  "is_correct": boolean,
  "accuracy_score": integer (0-100),
  "feedback_text": "A short, encouraging feedback in Arabic (max 15 words)",
  "errors": [
    {"word": "the_wrong_word", "error_type": "pronunciation|tashkeel|missing", "correction": "how_it_should_be"}
  ]
}
PROMPT;

        // Custom call logic to handle audio file
        $apiKey = self::getApiKey();
        $parts = [
            ['text' => $prompt],
            [
                'inline_data' => [
                    'mime_type' => 'audio/mpeg', // Assuming mp3/mpeg from mobile
                    'data' => base64_encode(file_get_contents($audioFilePath))
                ]
            ]
        ];

        $payload = [
            'contents' => [['role' => 'user', 'parts' => $parts]],
            'generationConfig' => [
                'temperature' => 0.2,
                'response_mime_type' => 'application/json'
            ]
        ];

        $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={$apiKey}";
        $response = Http::withHeaders(['Content-Type' => 'application/json'])->timeout(60)->post($url, $payload);

        if (!$response->successful()) {
            throw new \Exception("AI Analysis failed: " . $response->body());
        }

        $result = $response->json();
        $text = $result['candidates'][0]['content']['parts'][0]['text'] ?? '{}';
        return json_decode(trim(preg_replace('/^```json\s*|```\s*$/', '', $text)), true) ?? [];
    }

    protected static function getApiKey(): string
    {
        $dbKey = \App\Models\GeminiSetting::where('key', 'api_key')->first()?->value;
        return trim($dbKey ?: env('GEMINI_API_KEY'));
    }

    /**
     * Utilities
     */
    public static function listModels(): array
    {
        return [
            'gemini-2.0-flash' => 'Gemini 2.0 Flash 🚀 (الأحدث والأسرع)',
            'gemini-2.0-flash-lite' => 'Gemini 2.0 Flash Lite ⚡ (خفيف واقتصادي)',
            'gemini-2.5-flash' => 'Gemini 2.5 Flash ✨ (نسخة المعاينة المتطورة)',
            'gemini-1.5-flash' => 'Gemini 1.5 Flash (إذا كان متاحاً)',
        ];
    }

    public static function getSystemPromptTemplate(int $count = 5, string $types = 'mix'): string
    {
        $dbSetting = \App\Models\GeminiSetting::where('key', 'system_prompt')->first();
        $template = ($dbSetting && !empty($dbSetting->value)) ? $dbSetting->value : self::getDefaultTemplate();

        $text = str_replace(['{count}', '{$count}'], $count, $template);
        $text = str_replace(['{types}', '{$types}'], $types, $text);
        
        return $text;
    }

    public static function getDefaultTemplate(): string
    {
        return <<<PROMPT
You are an expert Islamic Educator and Quran Teacher. Generate {count} high-quality questions in Arabic based on the provided content.
Types requested: {types} (if 'mix', use a variety of the types below).

Output ONLY a JSON array of objects. Each object MUST follow this structure based on the type:

1. For 'multiple_choices':
{
  "question_text": "...",
  "question_type": "multiple_choices",
  "hint_text": "A helpful hint for the student during the exercise",
  "explanation_text": "Detailed explanation after solving",
  "options": [
    {"option_text": "Correct answer", "is_correct": true},
    {"option_text": "Wrong answer", "is_correct": false}
  ]
}

2. For 'ordering' (VERSE/SENTENCE RECONSTRUCTION - DUOLINGO STYLE):
{
  "question_text": "أعد ترتيب كلمات الآية الكريمة:",
  "question_type": "ordering",
  "hint_text": "تلميح بيداغوجي يساعد في الترتيب",
  "explanation_text": "شرح للسياق أو القاعدة التجويدية في الآية",
  "ordering_items": [
    {"text": "الكلمة الأولى"},
    {"text": "الكلمة الثانية"},
    {"text": "الكلمة الثالثة"}
  ]
}

3. For 'true_or_false':
{
  "question_text": "...",
  "question_type": "true_or_false",
  "hint_text": "...",
  "explanation_text": "...",
  "true_or_false": {"is_true": true}
}

4. For 'fill_in_the_blanks':
{
  "question_text": "نص يحتوي على [فراغ] واحد أو أكثر",
  "question_type": "fill_in_the_blanks",
  "hint_text": "...",
  "explanation_text": "...",
  "blank_items": [
    {"word": "الكلمة المحذوفة"}
  ]
}

IMPORTANT: Ensure the 'ordering' type is used effectively for Quranic verses by breaking them into logical word segments.
Output ONLY the JSON array. No markdown blocks, no extra text.
PROMPT;
    }
}
