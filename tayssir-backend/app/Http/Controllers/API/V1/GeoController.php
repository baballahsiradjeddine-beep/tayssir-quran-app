<?php

namespace App\Http\Controllers\API\V1;

use App\Http\Controllers\API\BaseController;
use App\Models\Country;
use App\Models\Region;
use Illuminate\Http\Request;

class GeoController extends BaseController
{
    /**
     * Get all countries.
     */
    public function countries()
    {
        $countries = Country::where('is_active', true)
            ->ordered()
            ->get()
            ->map(fn($country) => [
                'id' => $country->id,
                'name' => $country->name,
                'code' => $country->code,
                'phone_code' => $country->phone_code,
            ]);

        return $this->sendResponse($countries, 'Countries retrieved successfully.');
    }

    /**
     * Get regions by country ID.
     */
    public function regions(Country $country)
    {
        $regions = $country->regions()
            ->orderBy('name', 'asc')
            ->get()
            ->map(fn($region) => [
                'id' => $region->id,
                'name' => $region->name,
                'code' => $region->code,
            ]);

        return $this->sendResponse($regions, 'Regions retrieved successfully.');
    }
}
