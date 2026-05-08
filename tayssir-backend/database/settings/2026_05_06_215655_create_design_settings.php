<?php

use Spatie\LaravelSettings\Migrations\SettingsMigration;

return new class extends SettingsMigration
{
    public function up(): void
    {
        $this->migrator->add('design.light_primary', '#064E3B');
        $this->migrator->add('design.light_secondary', '#059669');
        $this->migrator->add('design.light_accent', '#D97706');
        $this->migrator->add('design.light_background', '#FDFBF7');
        $this->migrator->add('design.light_surface', '#FFFFFF');
        $this->migrator->add('design.light_text_primary', '#064031');
        $this->migrator->add('design.light_text_secondary', '#047857');

        $this->migrator->add('design.dark_primary', '#10B981');
        $this->migrator->add('design.dark_secondary', '#059669');
        $this->migrator->add('design.dark_accent', '#F59E0B');
        $this->migrator->add('design.dark_background', '#0F172A');
        $this->migrator->add('design.dark_surface', '#1E293B');
        $this->migrator->add('design.dark_text_primary', '#FFFFFF');
        $this->migrator->add('design.dark_text_secondary', '#FFFFFFB3');
    }
};
