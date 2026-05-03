<?php

namespace App\Utils;

class ArabicUtils
{
    public static function normalize($text)
    {
        if (empty($text)) return $text;

        // Remove diacritics (Tashkeel)
        // \x{064B}-\x{0652} are the standard Tashkeel
        // \x{0670} is the small Alef (Dagger Alef)
        $text = preg_replace('/[\x{064B}-\x{0652}\x{0670}]/u', '', $text);

        // Normalize Alef (أ إ آ -> ا)
        $text = preg_replace('/[أإآ]/u', 'ا', $text);

        // Optional: Normalize Teh Marbuta (ة -> ه) 
        // Some users search for 'الصلاة' as 'الصلاه'
        // $text = str_replace('ة', 'ه', $text);

        return $text;
    }
}
