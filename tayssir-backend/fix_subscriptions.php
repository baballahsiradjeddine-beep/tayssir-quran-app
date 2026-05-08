<?php

use App\Models\Unit;
use App\Models\Chapter;
use App\Models\Subscription;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

// Find the Free Subscription ID
$freeSubscription = Subscription::where('name', 'like', '%مجاني%')->first();

if (!$freeSubscription) {
    echo "Could not find 'الاشتراك المجاني'. Checking ID 1...\n";
    $freeSubscription = Subscription::find(1);
}

if (!$freeSubscription) {
    die("Free subscription not found!\n");
}

$subId = $freeSubscription->id;
echo "Found Free Subscription with ID: $subId\n";

// Link all units and chapters
$units = Unit::all();
foreach ($units as $unit) {
    $unit->subscriptions()->syncWithoutDetaching([$subId]);
}

$chapters = Chapter::all();
foreach ($chapters as $chapter) {
    $chapter->subscriptions()->syncWithoutDetaching([$subId]);
}

echo "Successfully linked all units and chapters to the Free Subscription!\n";
