<?php

namespace App\Http\Controllers\API\V2;

use App\Http\Controllers\Controller;
use App\Settings\DesignSettings;
use Illuminate\Http\JsonResponse;

class DesignSystemController extends Controller
{
    public function index(DesignSettings $settings): JsonResponse
    {
        return response()->json([
            'light' => [
                'primary' => $settings->light_primary,
                'secondary' => $settings->light_secondary,
                'accent' => $settings->light_accent,
                'background' => $settings->light_background,
                'surface' => $settings->light_surface,
                'text_primary' => $settings->light_text_primary,
                'text_secondary' => $settings->light_text_secondary,
            ],
            'dark' => [
                'primary' => $settings->dark_primary,
                'secondary' => $settings->dark_secondary,
                'accent' => $settings->dark_accent,
                'background' => $settings->dark_background,
                'surface' => $settings->dark_surface,
                'text_primary' => $settings->dark_text_primary,
                'text_secondary' => $settings->dark_text_secondary,
            ],
        ]);
    }
}
