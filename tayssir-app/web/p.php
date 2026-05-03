<?php
// Tayssir Image Proxy with Server-Side Caching
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

$img = $_GET['img'] ?? '';
if (!$img) {
    header("Content-Type: text/plain");
    die("Error: No image path provided.");
}

// Security: Clean path
$img = str_replace(['../', '..\\'], '', $img);
$img = ltrim($img, '/');

// --- CACHING LOGIC ---
$cacheDir = 'cache_imgs/';
if (!is_dir($cacheDir)) {
    mkdir($cacheDir, 0755, true);
}

// Create a safe filename for caching based on the URL
$cacheFile = $cacheDir . md5($img) . '.' . pathinfo($img, PATHINFO_EXTENSION);

// If already cached and not too old (e.g., 7 days), serve it locally
if (file_exists($cacheFile) && (time() - filemtime($cacheFile) < 86400 * 7)) {
    $mime = mime_content_type($cacheFile);
    header("Content-Type: $mime");
    header("X-Proxy-Cache: HIT");
    header("Cache-Control: public, max-age=86400");
    readfile($cacheFile);
    exit;
}

// Base storage URL
$storageBase = "https://291013.tayssir-bac.com/storage/";
$targetUrl = $storageBase . $img;

// Fetch via cURL
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $targetUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_TIMEOUT, 15);
curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/100.0.0.0");

$data = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$contentType = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
curl_close($ch);

if ($httpCode === 200 && !empty($data)) {
    // Save to cache for next time
    file_put_contents($cacheFile, $data);
    
    header("Content-Type: $contentType");
    header("X-Proxy-Cache: MISS");
    header("Cache-Control: public, max-age=86400");
    echo $data;
} else {
    http_response_code($httpCode ?: 404);
    echo "Error: Image not found at $targetUrl";
}
