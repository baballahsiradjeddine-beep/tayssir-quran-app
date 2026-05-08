<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CharityMilestone extends Model
{
    use HasFactory;

    protected $fillable = [
        'charity_campaign_id',
        'label',
        'amount',
        'sort_order',
    ];

    public function campaign()
    {
        return $this->belongsTo(CharityCampaign::class, 'charity_campaign_id');
    }
}
