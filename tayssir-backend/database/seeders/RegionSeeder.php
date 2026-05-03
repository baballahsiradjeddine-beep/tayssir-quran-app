<?php

namespace Database\Seeders;

use App\Models\Country;
use App\Models\Region;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class RegionSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Algeria
        $algeria = Country::where('code', 'DZ')->first();
        if ($algeria) {
            $wilayas = DB::table('wilayas')->get();
            foreach ($wilayas as $wilaya) {
                Region::updateOrCreate(
                    ['name' => $wilaya->arabic_name, 'country_id' => $algeria->id],
                    ['name' => $wilaya->arabic_name]
                );
            }
        }

        // 2. Saudi Arabia
        $saudi = Country::where('code', 'SA')->first();
        if ($saudi) {
            $saudiRegions = [
                'الرياض', 'مكة المكرمة', 'المدينة المنورة', 'القصيم', 'المنطقة الشرقية',
                'عسير', 'تبوك', 'حائل', 'الحدود الشمالية', 'جازان', 'نجران', 'الباحة', 'الجوف'
            ];
            foreach ($saudiRegions as $regionName) {
                Region::updateOrCreate(
                    ['name' => $regionName, 'country_id' => $saudi->id],
                    ['name' => $regionName]
                );
            }
        }
    }
}
