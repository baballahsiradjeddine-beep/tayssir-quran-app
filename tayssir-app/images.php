<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0);
}

$path = isset($_GET['path']) ? $_GET['path'] : '';
if (!$path) {
    http_response_code(404);
    exit;
}

// Sanitize path to prevent directory traversal
$storage_dir = realpath(__DIR__ . '/storage');
$requested_path = realpath(__DIR__ . '/storage/' . $path);

if ($requested_path && $storage_dir && strpos($requested_path, $storage_dir) === 0 && file_exists($requested_path)) {
    $mime = mime_content_type($requested_path);
    if (!$mime) {
        $ext = strtolower(pathinfo($requested_path, PATHINFO_EXTENSION));
        $mimes = [
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'svg' => 'image/svg+xml',
            'webp' => 'image/webp'
        ];
        $mime = isset($mimes[$ext]) ? $mimes[$ext] : 'application/octet-stream';
    }
    
    header("Content-Type: $mime");
    header("Cache-Control: public, max-age=604800"); // Cache for 7 days
    header("Content-Length: " . filesize($requested_path));
    
    // Obey Range requests if needed (optional, readfile handles basic)
    readfile($requested_path);
    exit;
} else {
    http_response_code(404);
    echo "Image not found or access denied.";
}
