<?php

namespace App\Console\Commands;

use App\Models\Country;
use App\Models\Region;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class ImportGlobalData extends Command
{
    protected $signature = 'app:import-global-data';
    protected $description = 'Import all countries and their states with Arabic names';

    public function handle()
    {
        ini_set('memory_limit', '512M');
        $this->info('Step 1: Fetching and updating countries with Arabic names...');

        try {
            // Source 1: Countries with Arabic names and phone codes
            $countriesResponse = Http::timeout(60)->get('https://raw.githubusercontent.com/mledoze/countries/master/dist/countries.json');
            
            if ($countriesResponse->failed()) {
                $this->error('Failed to fetch countries data.');
                return 1;
            }

            $countriesData = $countriesResponse->json();
            
            foreach ($countriesData as $cData) {
                $nameAr = $cData['translations']['ara']['common'] ?? $cData['name']['common'];
                $code = $cData['cca2'];
                
                // Get phone code
                $root = $cData['idd']['root'] ?? '';
                $suffix = $cData['idd']['suffixes'][0] ?? '';
                $phoneCode = $root . $suffix;

                Country::updateOrCreate(
                    ['code' => $code],
                    [
                        'name' => $nameAr,
                        'phone_code' => $phoneCode,
                        'is_active' => true,
                    ]
                );
            }

            $this->info('Countries updated successfully.');

            $this->info('Step 2: Fetching and updating regions with Arabic names...');
            // Source 2: States with Arabic translations
            $statesResponse = Http::timeout(120)->get('https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/master/json/states.json');

            if ($statesResponse->failed()) {
                $this->error('Failed to fetch states data.');
                return 1;
            }

            $statesData = $statesResponse->json();
            
            $this->withProgressBar($statesData, function ($sData) {
                $countryCode = $sData['country_code'];
                $country = Country::where('code', $countryCode)->first();
                
                if ($country) {
                    $nameAr = $sData['translations']['ar'] ?? $sData['name'];
                    
                    Region::updateOrCreate(
                        [
                            'country_id' => $country->id,
                            'name' => $nameAr, // Use Arabic name if available
                        ],
                        [
                            'name' => $nameAr
                        ]
                    );
                }
            });

            $this->newLine();
            $this->info('Import completed successfully with Arabic names!');
            return 0;

        } catch (\Exception $e) {
            $this->error('Error: ' . $e->getMessage());
            return 1;
        }
    }
}
