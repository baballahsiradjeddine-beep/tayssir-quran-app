<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * هجرة لإنشاء جدول الآيات
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ayahs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('surah_id')->constrained()->onDelete('cascade'); // ربط بالسورة
            $table->integer('number'); // رقم الآية في السورة
            $table->text('text_ar'); // نص الآية بالعربية
            $table->text('text_en')->nullable(); // نص الآية بالإنجليزية
            $table->string('audio_url')->nullable(); // رابط الصوت للتسميع
            $table->integer('juz')->nullable(); // رقم الجزء
            $table->integer('page')->nullable(); // رقم الصفحة في المصحف
            $table->integer('hizb')->nullable(); // رقم الحزب
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ayahs');
    }
};
