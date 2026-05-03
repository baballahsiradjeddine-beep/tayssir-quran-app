<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\AdminNavigation;
use App\Filament\Admin\Resources\QuestionResource\Pages;
use App\Models\Question;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class QuestionResource extends Resource
{
    protected static ?string $model = Question::class;

    protected static ?string $navigationIcon = AdminNavigation::QUESTION_RESOURCE['icon'];

    public static function getNavigationGroup(): ?string
    {
        return __(AdminNavigation::QUESTION_RESOURCE['group']);
    }

    public static function getNavigationSort(): ?int
    {
        return AdminNavigation::QUESTION_RESOURCE['sort'];
    }

    public static function getNavigationLabel(): string
    {
        return __('custom.models.questions');
    }

    public static function getModelLabel(): string
    {
        return __('custom.models.question');
    }

    public static function getPluralModelLabel(): string
    {
        return __('custom.models.questions');
    }

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Placeholder::make('info')
                    ->label('ملاحظة')
                    ->content('لتعديل السؤال بشكل صحيح، يرجى استخدامه من خلال الفصل التابع له.'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')
                    ->label('ID')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('question_type')
                    ->label('نوع السؤال')
                    ->searchable(),
                Tables\Columns\TextColumn::make('chapters.name')
                    ->label('الفصل التابع له')
                    ->placeholder('لا يوجد فصل مرتب')
                    ->searchable()
                    ->limit(50),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\Action::make('edit_in_chapter')
                    ->label('تعديل في الفصل')
                    ->icon('heroicon-m-pencil-square')
                    ->color('success')
                    ->url(function (Question $record) {
                        $chapter = $record->chapters()->first();
                        if ($chapter) {
                            // Using full URL to ensure it works correctly
                            $baseUrl = config('app.url');
                            $path = "/dashboard/chapters/{$chapter->id}/edit?activeRelationManager=0&tableAction=edit&tableActionRecord={$record->id}";
                            return $baseUrl . $path;
                        }
                        return null;
                    })
                    ->openUrlInNewTab(),
            ])
            ->bulkActions([
                //
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
            'index' => Pages\ListQuestions::route('/'),
        ];
    }
}
