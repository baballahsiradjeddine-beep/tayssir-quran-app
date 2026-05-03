<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

/**
 * نموذج تتبع تقدم المستخدم في الحفظ والقراءة
 * يربط بين المستخدم والآية لتحديد حالة الحفظ (قراءة، حفظ، مراجعة).
 */
class QuranProgress extends Model
{
    protected $table = 'quran_progress';

    protected $fillable = [
        'user_id',
        'ayah_id',
        'status', // 'read' (قرأت), 'memorized' (حفظت), 'reviewed' (روجعت)
        'last_reviewed_at',
    ];

    /**
     * المستخدم صاحب هذا التقدم
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * الآية المرتبطة بهذا التقدم
     */
    public function ayah()
    {
        return $this->belongsTo(Ayah::class);
    }
}
