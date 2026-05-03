<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * هجرة لإضافة حقل تجميد الستريك (Freeze Mode)
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // عدد محاولات التجميد المتوفرة للمستخدم
            $table->integer('streak_freeze_count')->default(0)->after('longest_streak');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('streak_freeze_count');
        });
    }
};
