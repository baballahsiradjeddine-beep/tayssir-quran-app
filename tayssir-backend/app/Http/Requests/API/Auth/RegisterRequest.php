<?php

namespace App\Http\Requests\API\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'email' => 'required|email|unique:users|ends_with:@gmail.com,@hotmail.com,@hotmail.fr,@outlook.com,@outlook.fr,@outlook.sa,@yahoo.com,@yahoo.fr,@icloud.com,@me.com',
            'name' => 'required|min:4|max:255',
            'password' => 'required|min:3|max:32',
            'password_confirmation' => 'required|same:password',
            'age' => 'required|numeric|min:12',
            'phone_number' => "sometimes|nullable|regex:/^([0-9\s\-\+\(\)]*)$/|min:10|unique:users,phone_number",
            'country_id' => 'sometimes|nullable|numeric|exists:countries,id',
            'region_id' => 'sometimes|nullable|numeric|exists:regions,id|exists:regions,id,country_id,' . $this->country_id,
            'wilaya_id' => 'sometimes|nullable|numeric|exists:wilayas,id',
            'commune_id' => 'sometimes|nullable|numeric|exists:communes,id',
            'division_id' => 'required|numeric|exists:divisions,id',
            'referral_source_id' => 'sometimes|nullable|numeric|exists:referral_sources,id',
        ];
    }
}
