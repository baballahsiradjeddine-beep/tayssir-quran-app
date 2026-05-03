<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Cache-Control: public, max-age=86400");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

$path = $_GET['path'] ?? '';
if (empty($path)) {
    echo "No path provided.";
    exit;
}

// Security: Prevent directory traversal
$path = str_replace('../', '', $path);

$imageUrl = "https://291013.tayssir-bac.com/storage/" . $path;

// Basic headers for the request
$options = [
    "http" => [
        "method" => "GET",
        "header" => "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36\r\n"
    ]
];

$context = stream_context_create($options);
$imageData = @file_get_contents($imageUrl, false, $context);

if ($imageData === false) {
    header("HTTP/1.1 404 Not Found");
    echo "Image not found at: " . $imageUrl;
    exit;
}

// Detect Mime Type
$ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
$mimes = [
    'png' => 'image/png',
    'jpg' => 'image/jpeg',
    'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'svg' => 'image/svg+xml',
    'webp' => 'image/webp'
];

$mime = $mimes[$ext] ?? 'image/jpeg';
header("Content-Type: $mime");
echo $imageData;
