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
        Schema::create('charity_campaigns', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description')->nullable();
            $table->json('images')->nullable(); // For multiple image paths
            $table->json('video_urls')->nullable(); // For YouTube/Vimeo links
            $table->decimal('target_amount', 15, 2)->nullable();
            $table->decimal('raised_amount', 15, 2)->default(0);
            $table->enum('status', ['ongoing', 'completed'])->default('ongoing');
            $table->boolean('is_visible')->default(true);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('charity_campaigns');
    }
};
