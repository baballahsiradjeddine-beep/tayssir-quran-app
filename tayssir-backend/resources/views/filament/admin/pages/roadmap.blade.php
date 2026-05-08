<div class="space-y-8 p-8">
    <div class="flex items-center justify-between mb-12">
        <div>
            <h2 class="text-3xl font-black text-white tracking-tight">خريطة الرحلة التعليمية</h2>
            <p class="text-gray-400 mt-1">تتبع مسار الدروس والفصول في نظام تيسير V2</p>
        </div>
        <a href="{{ \App\Filament\Admin\Resources\ChapterResource::getUrl('create') }}" 
           class="px-6 py-3 bg-primary-600 hover:bg-primary-700 text-white font-bold rounded-xl shadow-lg shadow-primary-500/20 transition-all flex items-center gap-2">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/></svg>
            <span>إضافة فصل جديد</span>
        </a>
    </div>

    <div class="relative max-w-4xl mx-auto">
        {{-- The Connecting Line --}}
        <div class="absolute left-1/2 top-0 bottom-0 w-1 bg-gradient-to-b from-primary-500/50 via-warning-500/50 to-primary-500/50 -translate-x-1/2 rounded-full hidden md:block"></div>

        <div class="space-y-24 relative z-10">
            @php 
                $chapters = \App\Models\Chapter::with('unit')->orderBy('id', 'asc')->get();
            @endphp

            @foreach($chapters as $index => $chapter)
                <div class="flex flex-col md:flex-row items-center gap-8 {{ $index % 2 == 0 ? '' : 'md:flex-row-reverse' }}">
                    {{-- Chapter Card --}}
                    <div class="flex-1 w-full">
                        <div class="bg-[#1a2236] p-6 rounded-[2rem] border border-[#1e293b] shadow-2xl hover:border-primary-500/50 transition-all group relative overflow-hidden">
                            <div class="absolute -right-10 -top-10 w-32 h-32 bg-primary-500/5 blur-3xl rounded-full"></div>
                            
                            <div class="flex items-start gap-4">
                                <div class="w-16 h-16 rounded-2xl bg-[#0b1121] flex-shrink-0 flex items-center justify-center border border-white/5 overflow-hidden">
                                    @if($chapter->getFirstMediaUrl('chapter_photos'))
                                        <img src="{{ $chapter->getFirstMediaUrl('chapter_photos') }}" class="w-full h-full object-cover">
                                    @else
                                        <span class="text-2xl font-black text-primary-500">{{ $index + 1 }}</span>
                                    @endif
                                </div>
                                <div class="flex-1">
                                    <div class="flex items-center gap-2 mb-1">
                                        <span class="text-[10px] font-black uppercase tracking-widest text-primary-500">{{ $chapter->unit?->name ?? 'محور غير محدد' }}</span>
                                        @if(!$chapter->active)
                                            <span class="px-2 py-0.5 rounded-full bg-red-500/20 text-red-500 text-[8px] font-bold">مسودة</span>
                                        @endif
                                    </div>
                                    <h3 class="text-xl font-bold text-white leading-tight group-hover:text-primary-400 transition-colors">{{ $chapter->name }}</h3>
                                    <p class="text-sm text-gray-400 mt-2 line-clamp-2 leading-relaxed">{{ $chapter->description }}</p>
                                    
                                    <div class="mt-4 flex items-center gap-3">
                                        <a href="{{ \App\Filament\Admin\Resources\ChapterResource::getUrl('edit', ['record' => $chapter]) }}" 
                                           class="text-xs font-bold text-primary-500 hover:text-primary-400 flex items-center gap-1">
                                            <span>تعديل الإعدادات</span>
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/></svg>
                                        </a>
                                        <span class="w-1 h-1 rounded-full bg-white/10"></span>
                                        <a href="{{ \App\Filament\Admin\Resources\ChapterResource::getUrl('build-flow', ['record' => $chapter]) }}" 
                                           class="text-xs font-bold text-warning-500 hover:text-warning-400 flex items-center gap-1">
                                            <span>بناء المسار</span>
                                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/></svg>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {{-- Center Indicator --}}
                    <div class="w-12 h-12 rounded-full bg-[#1a2236] border-4 border-primary-500 flex items-center justify-center z-10 shadow-[0_0_20px_rgba(59,130,246,0.3)] shrink-0">
                        <div class="w-3 h-3 rounded-full bg-primary-500 animate-pulse"></div>
                    </div>

                    {{-- Empty spacer for alignment --}}
                    <div class="flex-1 hidden md:block"></div>
                </div>
            @endforeach
        </div>
    </div>
</div>
