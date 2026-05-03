<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * هجرة لإضافة حقول مستويات الولاية والنقاط للمستخدمين
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // رتبة الولاية (مبتدئ، مثابر، متقن، مجاز)
            $table->string('wilayah_rank')->default('beginner')->after('name');
            
            // نقاط الخبرة (Experience Points)
            $table->unsignedBigInteger('xp_points')->default(0)->after('wilayah_rank');
            
            // عدد الأجزاء المحفوظة (للمتابعة السريعة)
            $table->integer('juz_memorized_count')->default(0)->after('xp_points');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['wilayah_rank', 'xp_points', 'juz_memorized_count']);
        });
    }
};
