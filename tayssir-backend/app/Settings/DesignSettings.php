<?php

namespace App\Settings;

use Spatie\LaravelSettings\Settings;

class DesignSettings extends Settings
{
    public string $light_primary;
    public string $light_secondary;
    public string $light_accent;
    public string $light_background;
    public string $light_surface;
    public string $light_text_primary;
    public string $light_text_secondary;

    public string $dark_primary;
    public string $dark_secondary;
    public string $dark_accent;
    public string $dark_background;
    public string $dark_surface;
    public string $dark_text_primary;
    public string $dark_text_secondary;

    public static function group(): string
    {
        return 'design';
    }
}
