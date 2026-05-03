@php($title = config('app.name') . ' - تحقق من البريد الإلكتروني')
@php($preheader = 'رمز التحقق من البريد الإلكتروني الخاص بك: ' . ($mailData['otp'] ?? ''))
@component('emails.layout', compact('title', 'preheader'))
    @component('emails.components.heading')
        تأكيد هويتك المباركة
    @endcomponent
    @component('emails.components.paragraph')
        حياك الله وبياك،
    @endcomponent
    @component('emails.components.paragraph')
        نسعد برغبتك في الانضمام لركب الحفاظ في {{ config('app.name') }}. لإتمام عملية التسجيل وتأمين حسابك، يرجى استخدام الرمز التالي:
    @endcomponent
    @include('emails.components.code', ['code' => $mailData['otp']])
    @component('emails.components.paragraph')
        إذا لم تطلب هذا الرمز، فيرجى تجاهل هذا البريد، ونسأل الله لنا ولكم الثبات.
    @endcomponent
    @include('emails.components.spacer', ['size' => 20])
    @component('emails.components.paragraph', ['margin' => '0'])
        في أمان الله،
    @endcomponent
    @component('emails.components.paragraph', ['margin' => '0'])
        فريق {{ config('app.name') }}
    @endcomponent
@endcomponent
