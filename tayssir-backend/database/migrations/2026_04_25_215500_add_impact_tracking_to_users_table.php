<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * هجرة لإضافة تتبع الأثر المجتمعي (احفظ لتطعم فقيراً)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // عدد الوجبات التي ساهم المستخدم في توفيرها من خلال حفظه
            $table->integer('meals_provided_count')->default(0)->after('xp_points');
            // إجمالي المبلغ المتبرع به (افتراضياً)
            $table->decimal('total_sadaqah_amount', 10, 2)->default(0)->after('meals_provided_count');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['meals_provided_count', 'total_sadaqah_amount']);
        });
    }
};
