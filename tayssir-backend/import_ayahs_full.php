<?php

use App\Models\Surah;
use App\Models\Ayah;
use Illuminate\Support\Facades\DB;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$files = [
    1 => 'database/seeders/json/quran-hafs.json',
    2 => 'database/seeders/json/quran-warsh.json',
];

echo "Starting Comprehensive Quran Import (Surahs + Ayahs)...\n";

// 1. Clean up
echo "Cleaning up existing Surahs and Ayahs...\n";
DB::statement('PRAGMA foreign_keys = OFF;');
Ayah::truncate();
Surah::truncate();
DB::statement('PRAGMA foreign_keys = ON;');

foreach ($files as $divId => $filePath) {
    if (!file_exists($filePath)) {
        echo "Warning: File $filePath not found. Skipping Division $divId.\n";
        continue;
    }

    echo "Processing Division $divId from $filePath...\n";
    $json = json_decode(file_get_contents($filePath), true);
    $surahsData = $json['data']['surahs'];

    foreach ($surahsData as $sData) {
        $number = $sData['number'];
        $nameAr = $sData['name'];
        $nameEn = $sData['englishName'];
        $typeAr = ($sData['revelationType'] === 'Meccan') ? 'مكية' : 'مدنية';
        
        echo "  Importing Surah $number: $nameAr...\n";

        // Create Surah
        $surah = Surah::create([
            'division_id' => $divId,
            'name_ar' => $nameAr,
            'name_en' => $nameEn,
            'type' => $typeAr,
            'total_ayahs' => count($sData['ayahs']),
            'revelation_order' => $number,
        ]);

        $ayahsBatch = [];
        foreach ($sData['ayahs'] as $aData) {
            $ayahsBatch[] = [
                'surah_id' => $surah->id,
                'division_id' => $divId,
                'number' => $aData['numberInSurah'],
                'text_ar' => $aData['text'],
                'text_plain' => preg_replace('/[^\x{0621}-\x{064A}\s]/u', '', $aData['text']), // Basic stripping of diacritics
                'text_en' => '', // Translation can be added later if needed
                'juz' => $aData['juz'],
                'page' => $aData['page'],
                'hizb' => floor($aData['hizbQuarter'] / 4) + 1,
                'created_at' => now(),
                'updated_at' => now(),
            ];

            // Insert in chunks of 50 to avoid memory issues
            if (count($ayahsBatch) >= 50) {
                DB::table('ayahs')->insert($ayahsBatch);
                $ayahsBatch = [];
            }
        }

        // Insert remaining ayahs
        if (!empty($ayahsBatch)) {
            DB::table('ayahs')->insert($ayahsBatch);
        }
    }
}

echo "\nFull Quran (114 Surahs and all Ayahs for both Narrations) has been successfully imported!\n";
