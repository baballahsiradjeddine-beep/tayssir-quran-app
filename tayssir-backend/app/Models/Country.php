<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Country extends Model
{
    protected $fillable = ['name', 'code', 'phone_code', 'is_active', 'is_arab'];

    public function regions()
    {
        return $this->hasMany(Region::class);
    }

    public function scopeOrdered($query)
    {
        return $query->orderByRaw('is_arab DESC, name ASC');
    }
}
