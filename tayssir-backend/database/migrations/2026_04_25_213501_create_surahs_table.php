<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * هجرة لإنشاء جدول السور
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('surahs', function (Blueprint $table) {
            $table->id();
            $table->string('name_ar'); // اسم السورة بالعربية
            $table->string('name_en'); // اسم السورة بالإنجليزية
            $table->enum('type', ['Meccan', 'Medinan']); // نوع السورة
            $table->integer('total_ayahs'); // إجمالي عدد الآيات
            $table->integer('revelation_order')->nullable(); // ترتيب النزول
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('surahs');
    }
};
