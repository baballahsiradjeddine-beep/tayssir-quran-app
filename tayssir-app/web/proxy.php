<?php
// Solution 2: 100% Guaranteed Workaround Proxy
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Cache-Control: public, max-age=86400");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

$img = $_GET['img'] ?? '';
if (empty($img)) {
    die("No image specified.");
}

// Security: No parent directory access
$img = str_replace('../', '', $img);

$apiUrl = "https://291013.tayssir-bac.com/storage/" . $img;

// Fetch the image data
$data = @file_get_contents($apiUrl);

if ($data === false) {
    header("HTTP/1.1 404 Not Found");
    die("Image error at: " . $apiUrl);
}

// Detect extension for mime type
$ext = strtolower(pathinfo($img, PATHINFO_EXTENSION));
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
echo $data;
