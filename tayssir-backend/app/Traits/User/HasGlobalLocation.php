<?php

namespace App\Traits\User;

use App\Models\Country;
use App\Models\Region;

trait HasGlobalLocation
{
    public function country()
    {
        return $this->belongsTo(Country::class);
    }

    public function region()
    {
        return $this->belongsTo(Region::class);
    }
}
