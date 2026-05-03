<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * نموذج الآية القرآنية
 * يحتوي على نص الآية باللغتين، رقمها، ومكانها في المصحف (الجزء، الصفحة، الحزب).
 */
class Ayah extends Model
{
    protected $fillable = [
        'surah_id',
        'division_id',
        'number',
        'text_ar',
        'text_plain',
        'text_en',
        'audio_url',
        'juz',
        'page',
        'hizb',
    ];

    protected static function booted()
    {
        static::saving(function ($ayah) {
            if ($ayah->isDirty('text_ar')) {
                $ayah->text_plain = \App\Utils\ArabicUtils::normalize($ayah->text_ar);
            }
        });
    }

    /**
     * العودة للسورة التي تنتمي إليها هذه الآية
     */
    public function surah()
    {
        return $this->belongsTo(Surah::class);
    }

    /**
     * العودة للرواية التي تنتمي إليها هذه الآية
     */
    public function division()
    {
        return $this->belongsTo(Division::class);
    }
}
