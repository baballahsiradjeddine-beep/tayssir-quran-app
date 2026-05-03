<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$divisions = \App\Models\Division::all();
foreach ($divisions as $d) {
    echo $d->id . ": " . $d->name . " | " . $d->arabic_name . "\n";
}
