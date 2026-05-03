<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * نموذج السورة القرطانية
 * يحتوي على معلومات السورة مثل الاسم، النوع (مكية/مدنية)، وعدد الآيات.
 */
class Surah extends Model
{
    protected $fillable = [
        'division_id',
        'name_ar',
        'name_en',
        'type', // Meccan / Medinan
        'total_ayahs',
        'revelation_order',
    ];

    /**
     * علاقة السورة بالآيات التابعة لها
     */
    public function ayahs()
    {
        return $this->hasMany(Ayah::class);
    }

    /**
     * العودة للرواية التي تنتمي إليها هذه السورة
     */
    public function division()
    {
        return $this->belongsTo(Division::class);
    }
}
