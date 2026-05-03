@php($title = config('app.name') . ' - نسيت كلمة المرور')
@php($preheader = 'طلب إعادة تعيين كلمة المرور - رمز: ' . ($mailData['otp'] ?? ''))
@component('emails.layout', compact('title', 'preheader'))
    @component('emails.components.heading')
        استعادة الوصول إلى حسابك
    @endcomponent
    @component('emails.components.paragraph')
        أهلاً بك مجدداً،
    @endcomponent
    @component('emails.components.paragraph')
        لقد تلقينا طلباً لإعادة تعيين كلمة المرور الخاصة بحسابك في {{ config('app.name') }}. للمتابعة في استعادة الوصول إلى حسابك، يرجى إدخال الرمز التالي:
    @endcomponent
    @include('emails.components.code', ['code' => $mailData['otp']])
    @component('emails.components.paragraph')
        إذا لم تكن أنت من طلب هذا التغيير، فيرجى تجاهل هذا البريد، وكن مطمئناً فبياناتك في أمان.
    @endcomponent
    @include('emails.components.spacer', ['size' => 20])
    @component('emails.components.paragraph', ['margin' => '0'])
        حفظكم الله ورعاكم،
    @endcomponent
    @component('emails.components.paragraph', ['margin' => '0'])
        فريق {{ config('app.name') }}
    @endcomponent
@endcomponent
