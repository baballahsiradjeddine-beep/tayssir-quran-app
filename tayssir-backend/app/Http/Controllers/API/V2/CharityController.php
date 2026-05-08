<?php

namespace App\Http\Controllers\API\V2;

use App\Http\Controllers\API\BaseController;
use App\Models\CharityCampaign;
use Illuminate\Http\Request;

class CharityController extends BaseController
{
    /**
     * Get all active charity campaigns.
     */
    public function index()
    {
        $campaigns = CharityCampaign::with('milestones')
            ->where('is_visible', true)
            ->orderBy('id', 'asc') // chronological order
            ->get();

        $data = $campaigns->map(function ($campaign) {
            return [
                'id' => $campaign->id,
                'title' => $campaign->title,
                'description' => $campaign->description,
                'status' => $campaign->status,
                'target_amount' => (float) $campaign->target_amount,
                'raised_amount' => (float) $campaign->raised_amount,
                'main_media_type' => $campaign->main_media_type,
                'main_image_url' => $campaign->getFirstMediaUrl('main_image'),
                'main_video_url' => $campaign->main_video_url,
                'milestones' => $campaign->milestones->map(function ($milestone) {
                    return [
                        'label' => $milestone->label,
                        'amount' => (float) $milestone->amount,
                    ];
                }),
                'documentation_images' => $campaign->getMedia('documentation')->map(function ($media) {
                    return [
                        'id' => $media->id,
                        'url' => $media->getUrl(),
                        'thumb' => $media->getUrl('thumb'),
                    ];
                }),
                'created_at' => $campaign->created_at,
            ];
        });

        return $this->sendResponse($data, 'Charity campaigns retrieved successfully.');
    }

    /**
     * Get a specific charity campaign details.
     */
    public function show($id)
    {
        $campaign = CharityCampaign::with('milestones')->find($id);

        if (!$campaign) {
            return $this->sendError('Campaign not found.');
        }

        $data = [
            'id' => $campaign->id,
            'title' => $campaign->title,
            'description' => $campaign->description,
            'status' => $campaign->status,
            'target_amount' => (float) $campaign->target_amount,
            'raised_amount' => (float) $campaign->raised_amount,
            'main_media_type' => $campaign->main_media_type,
            'main_image_url' => $campaign->getFirstMediaUrl('main_image'),
            'main_video_url' => $campaign->main_video_url,
            'milestones' => $campaign->milestones->map(function ($milestone) {
                return [
                    'label' => $milestone->label,
                    'amount' => (float) $milestone->amount,
                ];
            }),
            'documentation_images' => $campaign->getMedia('documentation')->map(function ($media) {
                return [
                    'id' => $media->id,
                    'url' => $media->getUrl(),
                    'thumb' => $media->getUrl('thumb'),
                ];
            }),
            'created_at' => $campaign->created_at,
        ];

        return $this->sendResponse($data, 'Charity campaign details retrieved successfully.');
    }
}
