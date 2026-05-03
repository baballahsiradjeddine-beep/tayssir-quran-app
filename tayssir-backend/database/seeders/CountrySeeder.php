<?php

namespace Database\Seeders;

use App\Models\Country;
use Illuminate\Database\Seeder;

class CountrySeeder extends Seeder
{
    public function run(): void
    {
        $countries = [
            ['name' => 'الجزائر', 'code' => 'DZ', 'phone_code' => '+213'],
            ['name' => 'السعودية', 'code' => 'SA', 'phone_code' => '+966'],
            ['name' => 'مصر', 'code' => 'EG', 'phone_code' => '+20'],
            ['name' => 'الإمارات', 'code' => 'AE', 'phone_code' => '+971'],
            ['name' => 'قطر', 'code' => 'QA', 'phone_code' => '+974'],
            ['name' => 'الكويت', 'code' => 'KW', 'phone_code' => '+965'],
            ['name' => 'عمان', 'code' => 'OM', 'phone_code' => '+968'],
            ['name' => 'البحرين', 'code' => 'BH', 'phone_code' => '+973'],
            ['name' => 'الأردن', 'code' => 'JO', 'phone_code' => '+962'],
            ['name' => 'لبنان', 'code' => 'LB', 'phone_code' => '+961'],
            ['name' => 'سوريا', 'code' => 'SY', 'phone_code' => '+963'],
            ['name' => 'العراق', 'code' => 'IQ', 'phone_code' => '+964'],
            ['name' => 'فلسطين', 'code' => 'PS', 'phone_code' => '+970'],
            ['name' => 'اليمن', 'code' => 'YE', 'phone_code' => '+967'],
            ['name' => 'ليبيا', 'code' => 'LY', 'phone_code' => '+218'],
            ['name' => 'تونس', 'code' => 'TN', 'phone_code' => '+216'],
            ['name' => 'المغرب', 'code' => 'MA', 'phone_code' => '+212'],
            ['name' => 'موريتانيا', 'code' => 'MR', 'phone_code' => '+222'],
            ['name' => 'السودان', 'code' => 'SD', 'phone_code' => '+249'],
            ['name' => 'جيبوتي', 'code' => 'DJ', 'phone_code' => '+253'],
            ['name' => 'الصومال', 'code' => 'SO', 'phone_code' => '+252'],
            ['name' => 'فرنسا', 'code' => 'FR', 'phone_code' => '+33'],
            ['name' => 'تركيا', 'code' => 'TR', 'phone_code' => '+90'],
            ['name' => 'الولايات المتحدة', 'code' => 'US', 'phone_code' => '+1'],
            ['name' => 'كندا', 'code' => 'CA', 'phone_code' => '+1'],
            ['name' => 'بريطانيا', 'code' => 'GB', 'phone_code' => '+44'],
            ['name' => 'ألمانيا', 'code' => 'DE', 'phone_code' => '+49'],
        ];

        foreach ($countries as $country) {
            Country::updateOrCreate(['code' => $country['code']], $country);
        }
    }
}
