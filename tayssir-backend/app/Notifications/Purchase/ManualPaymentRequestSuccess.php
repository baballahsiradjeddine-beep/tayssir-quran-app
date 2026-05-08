<?php

namespace App\Notifications\Purchase;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ManualPaymentRequestSuccess extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public bool $isCharity = false) {}

    public function via(object $notifiable): array
    {
        return ['database'];
    }

    public function toArray(object $notifiable): array
    {
        $name = $notifiable->name;
        return [
            'title' => $this->isCharity ? 'تم استلام تبرعك' : 'تم استلام طلب الدفع',
            'body' => $this->isCharity 
                ? 'مرحباً ' . $name . '، لقد تم استلام وصل التبرع الخاص بك بنجاح. يقوم فريقنا حالياً بمراجعته وسيتم إضافته للحملة قريباً. جزاك الله خيراً!'
                : 'مرحباً ' . $name . '، لقد تم استلام طلب الدفع اليدوي الخاص بك بنجاح. يقوم فريقنا حالياً بمراجعة التفاصيل وسيتم معالجته قريباً. سيتم إشعارك فور اكتمال عملية التحقق.'
        ];
    }
}
