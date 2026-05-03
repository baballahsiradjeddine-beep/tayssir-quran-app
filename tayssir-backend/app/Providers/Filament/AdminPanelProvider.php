<?php

namespace App\Providers\Filament;

use App\Filament\Admin\Widgets;
use CharrafiMed\GlobalSearchModal\GlobalSearchModalPlugin;
use DutchCodingCompany\FilamentDeveloperLogins\FilamentDeveloperLoginsPlugin;
use Filament\Enums\ThemeMode;
use Filament\Http\Middleware\Authenticate;
use Filament\Http\Middleware\DisableBladeIconComponents;
use Filament\Http\Middleware\DispatchServingFilamentEvent;
use Filament\Pages;
use Filament\Panel;
use Filament\PanelProvider;
use Filament\Support\Colors\Color;
use Filament\Support\Enums\MaxWidth;
use Howdu\FilamentRecordSwitcher\FilamentRecordSwitcherPlugin;
use Illuminate\Cookie\Middleware\AddQueuedCookiesToResponse;
use Illuminate\Cookie\Middleware\EncryptCookies;
use Illuminate\Foundation\Http\Middleware\VerifyCsrfToken;
use Illuminate\Routing\Middleware\SubstituteBindings;
use Illuminate\Session\Middleware\AuthenticateSession;
use Illuminate\Session\Middleware\StartSession;
use Illuminate\Support\Facades\Blade;
use Illuminate\View\Middleware\ShareErrorsFromSession;
use Joaopaulolndev\FilamentEditProfile\FilamentEditProfilePlugin;
use Filament\Navigation\NavigationGroup;

class AdminPanelProvider extends PanelProvider
{
    public function panel(Panel $panel): Panel
    {
        return $panel
            ->default()
            ->id('dashboard')
            ->path('dashboard')
            ->login()
            ->databaseTransactions()
            ->brandLogo(fn() => view('components.brand'))
            ->darkModeBrandLogo(fn() => view('components.brand-dark'))
            ->brandLogoHeight('2rem')
            ->favicon(asset(('favicon.svg')))
            ->colors([
                'primary' => Color::Emerald,
                'success' => Color::Green,
                'warning' => Color::Amber,
                'danger' => Color::Rose,
                'info' => Color::Sky,
                'gray' => Color::Slate,
            ])
            ->defaultThemeMode(ThemeMode::Dark)
            ->databaseNotifications()
            ->databaseNotificationsPolling("30s")
            ->lazyLoadedDatabaseNotifications(false)
            ->font('Cairo') // Using Cairo for the Admin Panel as well
            ->globalSearchKeyBindings(['command+k', 'ctrl+k'])
            ->discoverResources(in: app_path('Filament/Admin/Resources'), for: 'App\\Filament\\Admin\\Resources')
            ->discoverPages(in: app_path('Filament/Admin/Pages'), for: 'App\\Filament\\Admin\\Pages')
            ->discoverClusters(in: app_path('Filament/Admin/Clusters'), for: 'App\\Filament\\Admin\\Clusters')
            ->pages([
                Pages\Dashboard::class,
            ])
            ->navigationGroups([
                NavigationGroup::make(__('custom.nav.section.platform'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.subscription_and_payment'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.content'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.management'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.points'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.app'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.reports'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.notifications'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.app_settings'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.quran'))->collapsible(),
                NavigationGroup::make(__('custom.nav.section.applications'))->collapsible(),
                NavigationGroup::make('امور اضافية')->collapsible(),
            ])
            ->discoverWidgets(in: app_path('Filament/Admin/Widgets'), for: 'App\\Filament\\Admin\\Widgets')
            ->widgets([
                // Widgets\AccountWidget::class,
                Widgets\GeneralInfos::class,
                Widgets\GrowthMetrics::class,
                Widgets\ReferralSourcesBarChart::class,
                Widgets\EngagementMetrics::class,
                Widgets\InsightsAndSuggestions::class,
            ])
            ->middleware([
                EncryptCookies::class,
                AddQueuedCookiesToResponse::class,
                StartSession::class,
                AuthenticateSession::class,
                ShareErrorsFromSession::class,
                VerifyCsrfToken::class,
                SubstituteBindings::class,
                DisableBladeIconComponents::class,
                DispatchServingFilamentEvent::class,
            ])

            ->sidebarCollapsibleOnDesktop()
            ->authMiddleware([
                Authenticate::class,
            ])->plugins([
                GlobalSearchModalPlugin::make()
                    ->slideOver(),
                FilamentEditProfilePlugin::make()
                    ->shouldShowEditProfileForm(true)
                    // ->canAccess(fn() => auth()->user()->can('page_EditProfilePage'))
                    // ->shouldShowSanctumTokens(true)
                    ->setIcon('heroicon-o-user')
                    ->shouldShowAvatarForm(
                        value: true,
                        directory: 'avatars',
                        rules: 'mimes:jpeg,png|max:1024'
                    ),
                FilamentDeveloperLoginsPlugin::make()
                    ->enabled(config('app.debug', false))
                    ->users([
                        'ADMIN' => 'admin@bayan-quran.com',
                    ]),
                FilamentRecordSwitcherPlugin::make(),

            ])
            // ->darkMode(false)
            ->renderHook('panels::scripts.after', fn (): string => Blade::render('
                <script>
                    (function() {
                        const getSidebar = () => document.querySelector(".fi-sidebar-nav");
                        
                        // Save scroll BEFORE any navigation starts
                        const saveScroll = () => {
                            const sidebar = getSidebar();
                            if (sidebar) sessionStorage.setItem("sidebar-scroll", sidebar.scrollTop);
                        };

                        // Restore scroll IMMEDIATELY after navigation
                        const restoreScroll = () => {
                            const sidebar = getSidebar();
                            const saved = sessionStorage.getItem("sidebar-scroll");
                            if (sidebar && saved) {
                                sidebar.scrollTop = parseInt(saved);
                                // Double check after a frame to be absolutely sure
                                requestAnimationFrame(() => {
                                    sidebar.scrollTop = parseInt(saved);
                                });
                            }
                        };

                        document.addEventListener("livewire:navigating", saveScroll);
                        document.addEventListener("livewire:navigated", restoreScroll);
                        
                        // Save on manual scroll too
                        window.addEventListener("scroll", (e) => {
                            if (e.target.classList && e.target.classList.contains("fi-sidebar-nav")) {
                                sessionStorage.setItem("sidebar-scroll", e.target.scrollTop);
                            }
                        }, true);
                    })();
                </script>
            '))
            ->renderHook('panels::body.end', fn(): string => Blade::render("@vite('resources/js/app.js')"))
            ->viteTheme('resources/css/filament/dashboard/theme.css');
    }
}
