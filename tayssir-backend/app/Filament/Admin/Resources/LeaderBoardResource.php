<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\LeaderBoardResource\Pages;
use App\Filament\Admin\Resources\UserResource;
use App\Models\LeaderBoard;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class LeaderBoardResource extends Resource
{
    public static function getNavigationGroup(): ?string
    {
        return __(AdminNavigation::LEADER_BOARD_RESOURCE['group']);
    }

    public static function getModelLabel(): string
    {
        return __('custom.models.leaderboard');
    }

    public static function getPluralModelLabel(): string
    {
        return __('custom.models.leaderboard');
    }

    protected static ?string $model = LeaderBoard::class;

    protected static ?string $navigationIcon = AdminNavigation::LEADER_BOARD_RESOURCE['icon'];

    protected static ?int $navigationSort = AdminNavigation::LEADER_BOARD_RESOURCE['sort'];

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                //
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('points', 'desc')
            ->striped()
            ->columns([
                Tables\Columns\TextColumn::make('index')->label('')
                    ->rowIndex(),
                Tables\Columns\TextColumn::make('user.avatar_image')
                    ->toggleable()
                    ->label(__('custom.models.user.avatar'))
                    ->html()
                    ->width('60px')
                    ->alignment('center')
                    ->getStateUsing(fn($record) => $record->user ? view('components.filament-ui.avatar', [
                        'name'       => $record->user->name ?? 'N/A',
                        'avatar_url' => $record->user->avatar_image,
                    ])->render() : '—'),
                Tables\Columns\TextColumn::make('user.name')
                    ->label('المتسابق')
                    ->url(fn($record) => $record->user ? UserResource::getUrl('edit', ['record' => $record->user_id]) : null)
                    ->searchable(),
                Tables\Columns\TextColumn::make('user.wilayah_rank')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'beginner' => 'gray',
                        'perserverant' => 'info',
                        'master' => 'success',
                        'certified' => 'warning',
                        default => 'gray',
                    })
                    ->label('رتبة الولاية')
                    ->getStateUsing(fn($record) => $record->user?->wilayah_rank_name),
                Tables\Columns\TextColumn::make('points')
                    ->badge()
                    ->color('primary')
                    ->label(__('custom.models.leaderboard.points'))
                    ->sortable(),
                // Show weekly/daily points when tab is active (stored in display_points via join)
                Tables\Columns\TextColumn::make('display_points')
                    ->badge()
                    ->color('warning')
                    ->label('نقاط الفترة')
                    ->default('—')
                    ->toggleable(),
                Tables\Columns\TextColumn::make('max')
                    ->badge()
                    ->color('primary')
                    ->label(__('custom.models.leaderboard.max'))
                    ->sortable(),
                Tables\Columns\TextColumn::make('progress')
                    ->badge()
                    ->color(fn($state) => match (true) {
                        $state >= 80 => 'success',
                        $state >= 50 => 'warning',
                        $state < 20  => 'danger',
                        default      => 'gray',
                    })
                    ->label(__('custom.models.leaderboard.progress'))
                    ->getStateUsing(fn($record) => $record->user
                        ? number_format($record->user->progress_percentage, 1) . '%'
                        : '0.0%'),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\Action::make('view_user')
                    ->label(__('custom.models.user'))
                    ->url(fn($record) => $record->user ? UserResource::getUrl('edit', ['record' => $record->user_id]) : null)
                    ->icon('heroicon-o-user'),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    // Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index'  => Pages\ListLeaderBoards::route('/'),
            // 'create' => Pages\CreateLeaderBoard::route('/create'),
            // 'edit'   => Pages\EditLeaderBoard::route('/{record}/edit'),
        ];
    }
}
