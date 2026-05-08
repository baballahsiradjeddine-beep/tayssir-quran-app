<?php

use App\Models\Material;
use Illuminate\Support\Facades\DB;

require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "Updating Material Icons with Professional 3D Assets...\n";

$mappings = [
    23 => 'level1.png',
    24 => 'level2.png',
    25 => 'level3.png',
];

foreach ($mappings as $id => $filename) {
    $material = Material::find($id);
    if ($material) {
        $path = public_path('assets/images/' . $filename);
        if (file_exists($path)) {
            // Clear old images first
            $material->clearMediaCollection('image');
            $material->clearMediaCollection('image_grid');
            
            // Add new professional image
            $material->addMedia($path)
                     ->preservingOriginal()
                     ->toMediaCollection('image');
            
            // Also add to grid collection for variety
            $material->addMedia($path)
                     ->preservingOriginal()
                     ->toMediaCollection('image_grid');
                     
            echo "  - Successfully updated icon for Material ID $id: $material->name\n";
        } else {
            echo "  - File not found: $path\n";
        }
    } else {
        echo "  - Material ID $id not found.\n";
    }
}

echo "\nMaterial Icons Update Completed! The 'Dolphins' have been successfully replaced.\n";
