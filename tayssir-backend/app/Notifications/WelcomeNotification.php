<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class WelcomeNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public string $name) {}

    public function via(object $notifiable): array
    {
        return ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $mailData = [
            'name' => $this->name,
        ];

        return (new MailMessage)
            ->subject(config('app.name') . ' - رسالة ترحيب')
            ->view('emails.welcome-mail', compact('mailData'));
    }

    public function toDatabase(object $notifiable): array
    {
        return [
            'title' => 'مرحباً بك في رحاب ' . config('app.name'),
            'body' => 'أهلاً بك يا حامل القرآن. نسأل الله أن يجعل القرآن ربيع قلبك ونور صدرك، وأن يوفقك لختم كتابه الكريم والعمل به.',
        ];
    }
}
