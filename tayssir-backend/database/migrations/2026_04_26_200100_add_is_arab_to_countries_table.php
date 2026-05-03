<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('countries', 'is_arab')) {
            Schema::table('countries', function (Blueprint $table) {
                $table->boolean('is_arab')->default(false)->after('name');
            });
        }

        // Delete Netherlands Antilles if it exists
        DB::table('countries')
            ->where('name', 'like', '%Netherlands Antilles%')
            ->orWhere('name', 'like', '%الأنتيل الهولندية%')
            ->delete();

        // Mark Arab countries
        $arabCountryCodes = [
            'DZ', 'BH', 'KM', 'DJ', 'EG', 'IQ', 'JO', 'KW', 
            'LB', 'LY', 'MR', 'MA', 'OM', 'PS', 'QA', 'SA', 
            'SO', 'SD', 'SY', 'TN', 'AE', 'YE'
        ];

        DB::table('countries')
            ->whereIn('code', $arabCountryCodes)
            ->update(['is_arab' => true]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('countries', function (Blueprint $table) {
            $table->dropColumn('is_arab');
        });
    }
};
