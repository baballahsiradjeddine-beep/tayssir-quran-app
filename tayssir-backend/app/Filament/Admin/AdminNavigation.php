<?php

namespace App\Filament\Admin;

class AdminNavigation
{

    public const PLATFORM_GROUP = 'custom.nav.section.platform';
    public const SUBSCRIPTION_AND_PAYMENT_GROUP = 'custom.nav.section.subscription_and_payment';
    public const CONTENT_GROUP = 'custom.nav.section.content';
    public const MANAGEMENT_GROUP = 'custom.nav.section.management';
    public const POINTS_GROUP = 'custom.nav.section.points';
    public const APP_GROUP = 'custom.nav.section.app';
    public const REPORTS_GROUP = 'custom.nav.section.reports';
    public const NOTIFICATIONS_GROUP = 'custom.nav.section.notifications';
    public const APP_SETTINGS_GROUP = 'custom.nav.section.app_settings';
    public const QURAN_GROUP = 'custom.nav.section.quran';
    public const APPLICATIONS_GROUP = 'custom.nav.section.applications';

    public const SURAH_RESOURCE = [
        'icon' => 'heroicon-o-book-open',
        'sort' => 602,
        'group' => self::QURAN_GROUP,
    ];

    public const AYAH_RESOURCE = [
        'icon' => 'heroicon-o-document-text',
        'sort' => 603,
        'group' => self::QURAN_GROUP,
    ];

    public const PLATFORM_SETTINGS = [
        'icon' => 'heroicon-o-globe-alt',
        'sort' => 102,
        'group' => self::APP_SETTINGS_GROUP,
    ];

    public const APP_SETTINGS = [
        'icon' => 'heroicon-o-cog-6-tooth',
        'sort' => 101,
        'group' => self::APP_SETTINGS_GROUP,
    ];

    public const BANNER_RESOURCE = [
        'icon' => 'heroicon-o-photo',
        'sort' => 304,
        'group' => self::NOTIFICATIONS_GROUP,
    ];

    public const USERS = [
        'icon' => 'heroicon-o-users',
        'sort' => 201,
        'group' => self::MANAGEMENT_GROUP,
    ];

    public const LEADER_BOARD_RESOURCE = [
        'icon' => 'heroicon-o-numbered-list',
        'sort' => 202,
        'group' => self::MANAGEMENT_GROUP,
    ];

    public const REFERRAL_SOURCE_RESOURCE = [
        'icon' => 'heroicon-o-share',
        'sort' => 203,
        'group' => self::MANAGEMENT_GROUP,
    ];

    public const SUBSCRIPTION_RESOURCE = [
        'icon' => 'heroicon-o-banknotes',
        'sort' => 401,
        'group' => self::SUBSCRIPTION_AND_PAYMENT_GROUP,
    ];

    public const DISCOUNT_RESOURCE = [
        'icon' => 'heroicon-o-percent-badge',
        'sort' => 402,
        'group' => self::SUBSCRIPTION_AND_PAYMENT_GROUP,
    ];

    public const PROMOTER_RESOURCE = [
        'icon' => 'heroicon-o-megaphone',
        'sort' => 403,
        'group' => self::SUBSCRIPTION_AND_PAYMENT_GROUP,
    ];

    public const PAYMENT_RESOURCE = [
        'icon' => 'heroicon-o-banknotes',
        'sort' => 404,
        'group' => self::SUBSCRIPTION_AND_PAYMENT_GROUP,
    ];

    public const CHAPTER_LEVEL_RESOURCE = [
        'icon' => 'heroicon-o-rectangle-stack',
        'sort' => 501,
        'group' => self::POINTS_GROUP,
    ];

    public const BADGE_RESOURCE = [
        'icon' => 'heroicon-o-sparkles',
        'sort' => 502,
        'group' => self::POINTS_GROUP,
    ];

    public const DIVISION_RESOURCE = [
        'icon' => "heroicon-o-tag",
        'sort' => 601,
        'group' => self::QURAN_GROUP,
    ];

    public const MATERIAL_RESOURCE = [
        'icon' => "heroicon-o-book-open",
        'sort' => 651,
        'group' => self::APPLICATIONS_GROUP,
    ];

    public const UNIT_RESOURCE = [
        'icon' => "heroicon-o-bookmark",
        'sort' => 652,
        'group' => self::APPLICATIONS_GROUP,
    ];

    public const CHAPTER_RESOURCE = [
        'icon' => "heroicon-o-list-bullet",
        'sort' => 653,
        'group' => self::APPLICATIONS_GROUP,
    ];

    public const QUESTION_RESOURCE = [
        'icon' => "heroicon-o-sparkles",
        'sort' => 654,
        'group' => self::APPLICATIONS_GROUP,
    ];

    public const GEMINI_SETTING_RESOURCE = [
        'icon' => "heroicon-o-cpu-chip",
        'sort' => 103,
        'group' => self::APP_SETTINGS_GROUP,
    ];

    public const GEMINI_CHAT_PAGE = [
        'icon' => "heroicon-o-chat-bubble-left-right",
        'sort' => 210,
        'group' => self::MANAGEMENT_GROUP,
    ];

    public const QUESTION_REPORT_RESOURCE = [
        'icon' => "heroicon-o-chat-bubble-left-right",
        'sort' => 701,
        'group' => self::REPORTS_GROUP,
    ];

    public const CONTACT_FORM_RESOURCE = [
        'icon' => 'heroicon-o-envelope',
        'sort' => 702,
        'group' => self::REPORTS_GROUP,
    ];

    public const AUTOMATED_NOTIFICATION_RESOURCE = [
        'icon' => 'heroicon-o-cpu-chip',
        'sort' => 302,
        'group' => self::NOTIFICATIONS_GROUP,
    ];

    public const FCM_LOG_RESOURCE = [
        'icon' => 'heroicon-o-document-magnifying-glass',
        'sort' => 303,
        'group' => self::NOTIFICATIONS_GROUP,
    ];

    public const MANAGE_NOTIFICATIONS_PAGE = [
        'icon' => 'heroicon-o-chat-bubble-bottom-center-text',
        'sort' => 301,
        'group' => self::NOTIFICATIONS_GROUP,
    ];

    public const NOTIFICATION_CLUSTER = [
        'icon' => 'heroicon-o-bell',
        'sort' => 300,
        'group' => self::NOTIFICATIONS_GROUP,
    ];

    public const APP_ASSET_RESOURCE = [
        'icon' => 'heroicon-o-photo',
        'sort' => 104,
        'group' => self::APP_SETTINGS_GROUP,
    ];

    public const PLATFORM_SETTINGS_PAGE = [
        'icon' => 'heroicon-o-globe-alt',
        'sort' => 105,
        'group' => self::APP_SETTINGS_GROUP,
    ];

    public const CHARITY_CAMPAIGN_RESOURCE = [
        'icon' => 'heroicon-o-heart',
        'sort' => 250,
        'group' => self::MANAGEMENT_GROUP,
    ];

    public const CHARITY_PAYMENT_RESOURCE = [
        'icon' => 'heroicon-o-banknotes',
        'sort' => 251,
        'group' => self::MANAGEMENT_GROUP,
    ];
}
