<?php

namespace App\Traits\User;

use Carbon\Carbon;

/**
 * Trait [HasQuranProgress]
 * مسؤول عن إدارة تقدم المستخدم في مشروع القرآن، بما في ذلك الـ Streak وحماية الورد.
 */
trait HasQuranProgress
{
    /**
     * تحديث الستريك الخاص بالمستخدم مع دعم ميزة "حماية الورد" (Freeze Mode).
     * 
     * المنطق:
     * 1. إذا كان آخر يوم دراسة هو الأمس، يزداد الستريك.
     * 2. إذا كان اليوم، لا يتغير شيء.
     * 3. إذا فات يوم أو أكثر، نستخدم "التجميد" إن وجد، وإلا يعود الستريك لـ 1.
     */
    public function updateQuranStreak()
    {
        $today = Carbon::today();
        $lastStudy = $this->last_study_date ? Carbon::parse($this->last_study_date) : null;

        if (!$lastStudy) {
            $this->current_streak = 1;
        } elseif ($lastStudy->isToday()) {
            return; // تمت الدراسة اليوم مسبقاً
        } elseif ($lastStudy->isYesterday()) {
            $this->current_streak++;
        } else {
            // هناك انقطاع
            if ($this->streak_freeze_count > 0) {
                $this->streak_freeze_count--;
                // يتم استهلاك تجميد واحد للحفاظ على الستريك الحالي
            } else {
                $this->current_streak = 1;
            }
        }

        $this->last_study_date = $today;
        
        if ($this->current_streak > $this->longest_streak) {
            $this->longest_streak = $this->current_streak;
        }

        $this->save();
    }

    /**
     * شراء أو إضافة "تجميد" جديد باستخدام النقاط (اختياري لاحقاً)
     */
    public function addStreakFreeze(int $count = 1)
    {
        $this->streak_freeze_count += $count;
        $this->save();
    }
}
