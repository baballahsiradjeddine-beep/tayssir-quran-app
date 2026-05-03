<?php

namespace App\Http\Controllers\API;

use Carbon\Carbon;

class ResponseController
{
    public static function CountryRes($country)
    {
        return [
            'id' => $country->id,
            'name' => $country->name,
            'code' => $country->code,
            'phone_code' => $country->phone_code,
        ];
    }

    public static function RegionRes($region)
    {
        return [
            'id' => $region->id,
            'name' => $region->name,
        ];
    }

    public static function WilayaRes($wilaya)
    {
        return [
            'id' => $wilaya->id,
            'name' => $wilaya->name,
            'arabic_name' => $wilaya->arabic_name,
        ];
    }

    public static function CommuneRes($commune)
    {
        return [
            'id' => $commune->id,
            'name' => $commune->name,
            'arabic_name' => $commune->arabic_name,
        ];
    }

    public static function userRes($user)
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'age' => $user->age ? $user->age : null,
            // 'image_url' => config('app.url') . '/storage/' . $user->avatar_url,
            'image_url' => $user->avatar_image,
            'phone_number' => $user->phone_number,
            'email_verified' => $user->email_verified_at !== null,
            'country' => $user->country ? ResponseController::CountryRes($user->country) : null,
            'region' => $user->region ? ResponseController::RegionRes($user->region) : null,
            'wilaya' => $user->wilaya ? ResponseController::WilayaRes($user->wilaya) : null,
            'commune' => $user->wilaya && $user->commune ? ResponseController::CommuneRes($user->commune) : null,
            'division' => $user->division,
            'subscriptions' => $user->subscriptions,
            'points' => $user->points(),
            'badge' => $user->current_badge ? [
                'name' => $user->current_badge->name,
                'color' => $user->current_badge->color,
                'icon_url' => $user->current_badge->icon,
            ] : null,
            "has_new_notifications"  => $user->unreadNotifications()->exists(),
            "new_notifications_count"  => $user->unreadNotifications()->count(),
            // 'subscribed' => $subscriptionCard && $subscriptionCard->subscription && Carbon::now()->lessThan($user->subscriptionCard->subscription->ending_date),
        ];
    }
}
