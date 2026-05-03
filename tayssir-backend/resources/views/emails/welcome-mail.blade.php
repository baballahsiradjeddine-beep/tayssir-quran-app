@php($title = config('app.name') . ' - رسالة ترحيب')
@php($preheader = 'أهلاً بك في ' . config('app.name'))
@component('emails.layout', compact('title', 'preheader'))
    @component('emails.components.heading')
        أهلاً بك في رحاب {{ config('app.name') }} ✨
    @endcomponent

    @component('emails.components.paragraph')
        مرحباً بك يا حامل القرآن،
    @endcomponent

    @component('emails.components.paragraph')
        يسعدنا انضمامك إلى مجتمع {{ config('app.name') }}. لقد بدأت اليوم رحلة مباركة في حفظ كتاب الله وتدبر آياته، ونسأل الله أن يجعلنا وإياك من أهل القرآن الذين هم أهله وخاصته.
    @endcomponent

    @component('emails.components.paragraph')
        يمكنك الآن البدء في رحلة الحفظ، المراجعة، والتثبيت باستخدام الأدوات الذكية المتاحة في تطبيقنا.
    @endcomponent

    @include('emails.components.spacer', ['size' => 20])

    @component('emails.components.paragraph', ['margin' => '0'])
        مع خالص الدعوات،
    @endcomponent

    @component('emails.components.paragraph', ['margin' => '0'])
        فريق {{ config('app.name') }}
    @endcomponent
@endcomponent
