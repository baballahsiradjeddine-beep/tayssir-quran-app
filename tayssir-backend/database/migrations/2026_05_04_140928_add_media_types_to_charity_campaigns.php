<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('charity_campaigns', function (Blueprint $table) {
            $table->enum('main_media_type', ['image', 'video'])->default('image')->after('description');
            $table->string('main_video_url')->nullable()->after('main_media_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('charity_campaigns', function (Blueprint $table) {
            //
        });
    }
};
