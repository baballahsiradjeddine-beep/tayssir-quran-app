<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * هجرة لإنشاء جدول تتبع التقدم في الحفظ
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('quran_progress', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // ربط بالمستخدم
            $table->foreignId('ayah_id')->constrained()->onDelete('cascade'); // ربط بالآية
            $table->enum('status', ['read', 'memorized', 'reviewed'])->default('read'); // الحالة
            $table->timestamp('last_reviewed_at')->nullable(); // تاريخ آخر مراجعة
            $table->timestamps();
            
            // منع تكرار نفس الآية لنفس المستخدم
            $table->unique(['user_id', 'ayah_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('quran_progress');
    }
};
