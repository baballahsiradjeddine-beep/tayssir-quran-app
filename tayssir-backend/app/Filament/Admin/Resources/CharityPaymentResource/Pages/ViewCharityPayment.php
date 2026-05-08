<?php

namespace App\Filament\Admin\Resources\CharityPaymentResource\Pages;

use App\Filament\Admin\Resources\CharityPaymentResource;
use Filament\Resources\Pages\ViewRecord;

class ViewCharityPayment extends ViewRecord
{
    protected static string $resource = CharityPaymentResource::class;

    protected function getHeaderActions(): array
    {
        $record = $this->getRecord();

        $canModerate = $record->payment_type === \App\Enums\Purchase\PaymentType::MANUAL
            && $record->status === \App\Enums\Purchase\PaymentStatus::PENDING;

        if (! $canModerate) {
            return [];
        }

        return [
            \Filament\Actions\Action::make('accept')
                ->label('قبول التبرع')
                ->color('success')
                ->requiresConfirmation()
                ->action(function () use ($record) {
                    $record->status = \App\Enums\Purchase\PaymentStatus::ACCEPTED;
                    $record->save();

                    // Update Charity Campaign Raised Amount
                    if ($record->charity_campaign_id) {
                        $campaign = \App\Models\CharityCampaign::find($record->charity_campaign_id);
                        if ($campaign) {
                            $campaign->raised_amount += $record->final_price;
                            if ($campaign->raised_amount >= $campaign->target_amount) {
                                $campaign->status = 'completed';
                            }
                            $campaign->save();
                        }
                    } else {
                        // For general pool donations, pour into the ongoing campaigns and cascade overflow
                        $campaigns = \App\Models\CharityCampaign::where('status', 'ongoing')->orderBy('id', 'asc')->get();
                        $amountLeft = $record->final_price;
                        
                        foreach ($campaigns as $campaign) {
                            if ($amountLeft <= 0) break;
                            
                            $remainingNeeded = $campaign->target_amount - $campaign->raised_amount;
                            if ($remainingNeeded <= 0) {
                                $campaign->status = 'completed';
                                $campaign->save();
                                continue;
                            }
                            
                            if ($amountLeft >= $remainingNeeded) {
                                $campaign->raised_amount += $remainingNeeded;
                                $campaign->status = 'completed';
                                $campaign->save();
                                $amountLeft -= $remainingNeeded;
                            } else {
                                $campaign->raised_amount += $amountLeft;
                                $campaign->save();
                                $amountLeft = 0;
                            }
                        }
                    }

                    // Notify user
                    $record->user->notify(new \App\Notifications\Purchase\ManualPaymentSucceeded($record->subscription->name ?? 'تبرع سهم الخير', true));

                    \Filament\Notifications\Notification::make()
                        ->title('تم قبول التبرع وتحديث رصيد الحملة بنجاح')
                        ->success()
                        ->send();
                }),

            \Filament\Actions\Action::make('reject')
                ->label('رفض التبرع')
                ->color('danger')
                ->form([
                    \Filament\Forms\Components\Textarea::make('rejection_reason')
                        ->label('سبب الرفض')
                        ->required()
                        ->rows(3),
                ])
                ->requiresConfirmation()
                ->action(function (array $data) use ($record) {
                    $record->status = \App\Enums\Purchase\PaymentStatus::REJECTED;
                    $record->rejection_reason = $data['rejection_reason'];
                    $record->save();

                    $record->user->notify(new \App\Notifications\Purchase\ManualPaymentFailed($data['rejection_reason'] ?? null, $record->subscription->name ?? 'تبرع سهم الخير'));

                    \Filament\Notifications\Notification::make()
                        ->title('تم رفض التبرع')
                        ->danger()
                        ->send();
                }),
        ];
    }

    public function infolist(\Filament\Infolists\Infolist $infolist): \Filament\Infolists\Infolist
    {
        return $infolist
            ->schema([
                \Filament\Infolists\Components\Section::make('معلومات التبرع الأساسية')
                    ->schema([
                        \Filament\Infolists\Components\Grid::make(2)
                            ->schema([
                                \Filament\Infolists\Components\TextEntry::make('id')->label('ID'),
                                \Filament\Infolists\Components\TextEntry::make('created_at')->dateTime()->label('تاريخ التبرع'),
                                \Filament\Infolists\Components\TextEntry::make('status')->badge()->label('الحالة'),
                                \Filament\Infolists\Components\TextEntry::make('payment_type')->badge()->label('نوع الدفع'),
                                \Filament\Infolists\Components\TextEntry::make('user.email')
                                    ->label('حساب المتبرع')
                                    ->url(fn($record) => route('filament.dashboard.resources.users.edit', $record->user_id))
                                    ->openUrlInNewTab()
                                    ->color('primary'),
                                \Filament\Infolists\Components\TextEntry::make('charityCampaign.title')
                                    ->label('الحملة الخيرية الموجه لها التبرع')
                                    ->placeholder('تبرع عام (سهم الخير)')
                                    ->url(fn($record) => $record->charity_campaign_id ? route('filament.dashboard.resources.charity-campaigns.edit', $record->charity_campaign_id) : null)
                                    ->openUrlInNewTab()
                                    ->color('success'),
                            ]),
                    ]),

                \Filament\Infolists\Components\Section::make('المبلغ')
                    ->schema([
                        \Filament\Infolists\Components\Grid::make(2)
                            ->schema([
                                \Filament\Infolists\Components\TextEntry::make('final_price')
                                    ->label('المبلغ المتبرع به')
                                    ->formatStateUsing(fn($state) => is_null($state) ? '-' : number_format((float) $state, 2) . ' DZD')
                                    ->badge()
                                    ->color('success'),
                            ]),
                    ]),

                \Filament\Infolists\Components\Section::make('إثبات الدفع')
                    ->schema([
                        \Filament\Infolists\Components\Grid::make(1)
                            ->schema([
                                \Filament\Infolists\Components\TextEntry::make('attachment')
                                    ->label('وصل الدفع (في حالة بريدي موب)')
                                    ->visible(fn($record) => (bool) $record->getFirstMedia('attachment'))
                                    ->html()
                                    ->state("___")
                                    ->formatStateUsing(function ($state, $record) {
                                        // Use the same URL route as payments
                                        $href = url('/admin/payments/' . $record->getKey() . '/attachment');
                                        return '<a href="' . e($href) . '" target="_blank" class="text-primary-600 hover:underline">عرض الوصل المرفق</a>';
                                    }),
                            ]),
                    ]),
            ]);
    }
}
