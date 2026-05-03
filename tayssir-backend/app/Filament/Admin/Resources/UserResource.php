<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Group;
use Filament\Forms\Components\Placeholder;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Support\Enums\FontWeight;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ToggleColumn;
use Filament\Tables\Table;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Database\Eloquent\Builder;  // Add this line
// Add this to use statements
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Date;
use Illuminate\Support\HtmlString;
use Kossa\AlgerianCities\Commune;
use Ysfkaya\FilamentPhoneInput\Tables\PhoneColumn;

class UserResource extends Resource
{
    protected static ?string $recordTitleAttribute = 'recordTitle';

    public static function getGlobalSearchResultTitle(Model $record): string|Htmlable
    {
        return $record->name . ' (' . $record->email . ')';
    }

    public static function getNavigationGroup(): ?string
    {
        return __(AdminNavigation::USERS['group']);
    }

    public static function getModelLabel(): string
    {
        return __('custom.models.user');
    }

    public static function getPluralModelLabel(): string
    {
        return __('custom.models.users');
    }

    public static function getNavigationBadge(): ?string
    {
        return static::getModel()::withinPlatformPeriod()->count();
    }

    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = AdminNavigation::USERS['icon'];

    protected static ?int $navigationSort = AdminNavigation::USERS['sort'];

    protected static bool $isGloballySearchable = true;

    public static function getGloballySearchableAttributes(): array
    {
        return ['name', 'phone_number', 'email', 'new_email', 'country.name', 'region.name'];
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Section::make(__('custom.models.user.perfonal_info'))
                    ->schema([
                        TextInput::make('name')
                            ->required()
                            ->label(__('custom.models.user.name'))
                            ->columnSpan(2),

                        TextInput::make('email')
                            ->disabledOn('edit')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->email()
                            ->label(__('custom.models.user.email')),

                        TextInput::make('password')
                            ->password()
                            ->required()
                            ->label(__('custom.models.user.password'))
                            ->visibleOn('create'),

                        Select::make('country_id')
                            ->label(__('custom.models.user.country'))
                            ->relationship('country', 'name', fn($query) => $query->ordered())
                            ->searchable()
                            ->preload()
                            ->live()
                            ->afterStateUpdated(fn(callable $set) => $set('region_id', null)),

                        Select::make('region_id')
                            ->label(__('custom.models.user.region'))
                            ->options(function (callable $get) {
                                $countryId = $get('country_id');
                                if ($countryId) {
                                    return \App\Models\Region::where('country_id', $countryId)
                                        ->pluck('name', 'id')
                                        ->toArray();
                                }
                                return [];
                            })
                            ->searchable()
                            ->preload()
                            ->disabled(fn(callable $get) => ! $get('country_id')),

                        \Ysfkaya\FilamentPhoneInput\Forms\PhoneInput::make('phone_number')
                            ->label(__('custom.models.user.phone'))
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->validateFor(lenient: true)
                            ->formatStateUsing(fn($state) => $state)
                            ->columnSpanFull(),

                        Select::make('division')
                            ->label(__('custom.models.division'))
                            ->relationship('division', 'name')
                            ->preload()
                            ->searchable()
                            ->columnSpan(2),

                        Select::make('referral_source_id')
                            ->label(__('custom.models.referral_source'))
                            ->relationship('referralSource', 'name')
                            ->preload()
                            ->searchable()
                            ->columnSpan(2),

                        Placeholder::make('active_subscriptions')
                            ->label(__('custom.models.user.subscribtion'))
                            ->content(function ($record) {
                                if (! $record) {
                                    return '';
                                }

                                return new HtmlString(
                                    $record->active_subscriptions
                                        ->map(fn($sub) => sprintf(
                                            '<div class="inline-flex items-center px-3 py-1 rounded-lg text-sm font-medium bg-primary-500 text-white">%s</div>',
                                            $sub->name
                                        ))
                                        ->join(' ')
                                );
                            })
                            ->columnSpan(2),

                    ])->columnSpan(2)->columns(2),
                Group::make()->schema([
                    Section::make(__('custom.models.user.avatar'))->schema([
                        Placeholder::make('current_avatar')
                            ->label('')
                            ->content(function ($record) {
                                if (! $record || ! $record->avatar_url || ! str_starts_with($record->avatar_url, 'http')) {
                                    return '';
                                }
                                return new HtmlString(
                                    '<img src="' . $record->avatar_image . '" style="width: 100px; height: 100px; border-radius: 50%; object-fit: cover; margin: 0 auto 10px auto;" />'
                                );
                            })
                            ->hidden(fn ($record) => ! $record || ! str_starts_with($record->avatar_url ?? '', 'http')),
                        FileUpload::make('avatar_url')->image()->imageEditor()
                            ->directory('avatars')
                            ->deletable()
                            ->label(''),
                    ]),
                ]),

            ])->columns(3);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                // TextColumn::make('avatar_image')->copyable(),
                TextColumn::make('avatar_image')
                    ->toggleable()
                    ->label(__('custom.models.user.avatar'))
                    ->html()
                    ->getStateUsing(fn($record) => view('components.filament-ui.avatar', [
                        'name' => $record->name,
                        'avatar_url' => $record->avatar_image,
                    ])->render()),
                TextColumn::make('email')
                    ->label(__('custom.models.user.email'))
                    ->searchable()
                    ->sortable()
                    ->toggleable()
                    ->weight(FontWeight::Bold)
                    ->size('sm'),
                TextColumn::make('name')
                    ->label(__('custom.models.user.name'))
                    ->searchable()
                    ->sortable()
                    ->toggleable()
                    ->weight(FontWeight::Bold)
                    ->size('sm'),
                // ->description(fn($record) => view('components.small-text')->with([
                //     'text' => $record->email
                // ])),

                PhoneColumn::make('phone_number')
                    ->label(__('custom.models.user.phone'))
                    ->default(__('custom.models.user.phone.empty'))
                    ->searchable()
                    ->toggleable()
                    ->copyable()
                    ->size('sm')
                    ->copyMessage('Phone number copied')
                    ->copyMessageDuration(1500),

                // TextColumn::make('points')
                //     ->label(__('custom.models.user.points'))
                //     ->badge()
                //     ->color(fn($state) => $state > 1000 ? 'success' : 'warning')
                //     ->alignCenter()
                //     ->sortable()
                //     ->toggleable()
                //     ->size('sm')
                //     ->numeric(),

                TextColumn::make('roles.name')
                    ->label(__('custom.models.user.roles'))
                    ->badge()
                    ->toggleable()
                    ->color('primary')
                    ->separator(', ')
                    ->size('sm')
                    ->default(__('custom.models.user.roles.empty'))
                    ->wrap(),

                TextColumn::make('subscriptions')
                    ->label(__('custom.models.user.subscribtion'))
                    ->badge()
                    ->wrap()
                    ->toggleable()
                    ->color('success')
                    ->size('sm')
                    ->getStateUsing(function ($record) {
                        return $record->active_subscriptions
                            ->map(fn($sub) => $sub->name)
                            ->values()
                            ->toArray() ?: ['-'];
                    })
                    ->wrap(),

                TextColumn::make('country.name')
                    ->label(__('custom.models.user.country'))
                    ->searchable()
                    ->toggleable()
                    ->sortable()
                    ->size('sm')
                    ->default(__('custom.models.generic.empty'))
                    ->description(fn($record) => $record->region?->name ?? __('custom.models.generic.empty')),

                ToggleColumn::make('email_verified_at')
                    ->label(__('custom.models.user.verified'))
                    ->sortable()
                    ->toggleable()
                    ->alignCenter()
                    ->afterStateUpdated(function ($state, $record) {
                        if ($state) {
                            $record->email_verified_at = Date::now();
                            $record->save();
                        } else {
                            // $record->forceFill(['email_verified_at' => null])->save();

                            $record->email_verified_at = null;
                            $record->save();
                        }
                    }),
                TextColumn::make('created_at')
                    ->label(__('custom.table.created_at'))
                    ->getStateUsing(fn($record) => $record->created_at?->diffForHumans())
                    ->tooltip(fn($record) => $record->created_at?->format('Y-m-d H:i:s'))
                    ->sortable()
                    ->toggleable()
                    ->size('sm'),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('roles')
                    ->relationship('roles', 'name')
                    ->multiple()
                    ->preload()
                    ->searchable()
                    ->label(__('custom.models.user.roles')),

                Tables\Filters\SelectFilter::make('country')
                    ->relationship('country', 'name', fn($query) => $query->ordered())
                    ->multiple()
                    ->preload()
                    ->searchable()
                    ->label(__('custom.models.user.country')),

                Tables\Filters\TernaryFilter::make('email_verified')
                    ->label(__('custom.models.user.email_verified'))
                    ->placeholder(__('custom.models.user.tabs.all'))
                    ->trueLabel(__('custom.models.user.email_verified'))
                    ->falseLabel(__('custom.models.user.email_not_verified'))
                    ->queries(
                        true: fn(Builder $query) => $query->whereNotNull('email_verified_at'),
                        false: fn(Builder $query) => $query->whereNull('email_verified_at'),
                    ),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            \App\Filament\Admin\Resources\UserResource\RelationManagers\SubscriptionCardsRelationManager::class,
            \App\Filament\Admin\Resources\UserResource\RelationManagers\AnswersRelationManager::class,
            \App\Filament\Admin\Resources\UserResource\RelationManagers\NotificationsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
