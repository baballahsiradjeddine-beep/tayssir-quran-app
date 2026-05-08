<?php

namespace App\Notifications\Purchase;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Notification;

class ManualPaymentSucceeded extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public string $subscription_name, public bool $isCharity = false) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toArray(object $notifiable): array
    {
        $name = $notifiable->name;
        return [
            'title' => $this->isCharity ? 'جزاك الله خيراً! 💚' : 'تمت عملية الدفع بنجاح',
            'body' => $this->isCharity
                ? 'مرحباً ' . $name . '، لقد تم قبول تبرعك بنجاح وتمت إضافته لرصيد الحملة الجارية. نسأل الله أن يتقبل منك ويجعله في ميزان حسناتك!'
                : 'مرحباً ' . $name . '، لقد تمت عملية الدفع اليدوي بنجاح لاشتراك ' . $this->subscription_name . ' وأصبح اشتراكك نشطاً الآن. شكراً لاستخدامك خدماتنا!'
        ];
    }
}
