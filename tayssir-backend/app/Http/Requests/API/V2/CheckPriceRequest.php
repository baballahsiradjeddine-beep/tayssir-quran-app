<?php

namespace App\Http\Requests\API\V2;

use App\Models\PromoCode;
use Illuminate\Foundation\Http\FormRequest;

class CheckPriceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // Adjust authorization if needed
    }

    public function rules(): array
    {
        return [
            'subscription_id' => [
                'required',
                'integer',
                function ($attribute, $value, $fail) {
                    if ($value != 999 && !\App\Models\Subscription::where('id', $value)->exists()) {
                        $fail('The selected subscription is invalid.');
                    }
                },
            ],
            'amount' => ['nullable', 'numeric', 'min:100'],
            'promocode' => [
                'nullable',
                'string',
                'exists:promo_codes,code',
                function ($attribute, $value, $fail) {
                    if (! $value) {
                        return;
                    }
                    $promo = PromoCode::where('code', $value)->first();
                    if ($promo && ! $promo->is_active) {
                        $fail('The promo code is not active.');
                    }
                },
            ],
        ];
    }
}
