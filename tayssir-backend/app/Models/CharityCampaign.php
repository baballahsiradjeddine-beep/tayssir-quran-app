<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Spatie\MediaLibrary\HasMedia;
use Spatie\MediaLibrary\InteractsWithMedia;
use Spatie\MediaLibrary\MediaCollections\Models\Media;

class CharityCampaign extends Model implements HasMedia
{
    use HasFactory, InteractsWithMedia;

    protected $fillable = [
        'title',
        'description',
        'main_media_type',
        'main_video_url',
        'images',
        'video_urls',
        'target_amount',
        'raised_amount',
        'status',
        'is_visible',
    ];

    protected $casts = [
        'images' => 'array',
        'video_urls' => 'array',
        'target_amount' => 'decimal:2',
        'raised_amount' => 'decimal:2',
        'is_visible' => 'boolean',
    ];

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    public function milestones()
    {
        return $this->hasMany(CharityMilestone::class)->orderBy('sort_order');
    }

    public function registerMediaConversions(Media $media = null): void
    {
        $this->addMediaConversion('thumb')
            ->width(150)
            ->height(150)
            ->sharpen(10);

        $this->addMediaConversion('preview')
            ->width(400)
            ->height(400)
            ->sharpen(10);
    }
}
