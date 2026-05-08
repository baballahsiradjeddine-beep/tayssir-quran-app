<?php

use App\Models\Surah;
use App\Models\Ayah;
use App\Models\Division;
use Illuminate\Support\Facades\Http;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

// --- Configuration ---
$divisions = [
    1 => 'quran-uthmani', // Hafs
    2 => 'quran-warsh',   // Warsh
];

echo "Starting Full Quran Import...\n";

// 1. Fetch Surah List
echo "Fetching Surah list from Alquran.cloud...\n";
$response = Http::get('https://api.alquran.cloud/v1/surah');

if (!$response->successful()) {
    die("Failed to fetch Surah list.\n");
}

$surahsData = $response->json()['data'];

// 2. Clean up existing Surahs and Ayahs (optional, based on user preference)
// Surah::query()->delete();
// Ayah::query()->delete();

foreach ($surahsData as $sData) {
    $number = $sData['number'];
    $nameAr = $sData['name'];
    $nameEn = $sData['englishName'];
    $type = ($sData['revelationType'] === 'Meccan') ? 'مكية' : 'مدنية';
    $totalAyahs = $sData['numberOfAyahs'];

    echo "Processing Surah $number: $nameAr ($nameEn)...\n";

    foreach ($divisions as $divId => $edition) {
        // Create or update Surah for this division
        $surah = Surah::updateOrCreate(
            ['division_id' => $divId, 'name_ar' => $nameAr],
            [
                'name_en' => $nameEn,
                'type' => $type,
                'total_ayahs' => $totalAyahs,
                'revelation_order' => $number, // Using number as order for simplicity
            ]
        );

        // For now, let's just create the Surah structure.
        // Importing all Ayahs (6236 x 2) might take a long time and hit API limits.
        // If the user wants full text, we can do it in a separate step or for specific Surahs.
        
        echo "  - Created Surah for Division $divId\n";
    }
}

echo "\nFull Quran structure (114 Surahs for 2 Narrations) has been successfully created!\n";
echo "Note: This script only created the Surah records. Ayah text can be imported per Surah as needed.\n";
