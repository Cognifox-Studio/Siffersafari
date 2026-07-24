# Services Index

Detta ar snabbkartan till `lib/core/services/`. Fulla kontrakt finns i `../../docs/SERVICES_API.md`.

## Om du vill andra

- hur fragor byggs: borja i `question_generator_service.dart`
- hur ett nytt quizpass planeras: borja i `quiz_session_planner.dart`
- hur due-fragor valjs: borja i `quiz_due_question_planner.dart`
- vad som hander nar ett quiz avslutas: borja i `apply_quiz_result_use_case.dart`
- hur storykartan byggs: borja i `story_progression_service.dart`
- hur pathen filtreras och normaliseras: borja i `quest_progression_service.dart`

## Fragor och quizplanering

- `question_generator_service.dart`: facade for att bygga fragor
- `question_generator_service__helpers_part.dart`: gemensamma generatorhelpers
- `question_generator_service__impl_part.dart`: faktiska generatorgrenar per fragtyp
- `question_mix_policy.dart`: gates och sannolikheter for mix-specialer
- `quiz_session_planner.dart`: bygger start-, custom- och replaypass
- `quiz_due_question_planner.dart`: valjer due-fragor och pending due keys
- `quiz_review_schedule_service.dart`: intervall och due-berakning

## Resultatmerge

- `apply_quiz_result_use_case.dart`: idempotent orkestrering efter avslutat quiz
- `apply_quiz_result__progress_merger_part.dart`: stats, mastery och reward-grund
- `apply_quiz_result__quest_coordinator_part.dart`: questpointer, completion och notice
- `apply_quiz_result__history_writer_part.dart`: complete history till lagring
- `apply_quiz_result__level_reward_unlocker_part.dart`: level rewards och item unlocks
- `apply_quiz_result__helpers_part.dart`: delade hjalpresultat och tomvarden

## Story och progression

- `quest_progression_service.dart`: filtrerar questpool och normaliserar kartlangd
- `story_progression_service.dart`: bygger UI-fardig `StoryProgress`
- `user_quest_state_service.dart`: intern hantering av quest-state kring resultatflodet

## Upplevelse och integrationer

- `audio_service.dart`: ljudeffekter och musik
- `text_to_speech_service.dart`: upplasning i quizflodet
- `app_analytics_service.dart`: lokal eventlogg utan molnsynk
- `achievement_service.dart`: badges och bonusrewards
- `user_audio_settings_service.dart`: profilscopade ljudinstallningar

## Viktiga grenser

- Services ska inte navigera eller ta `BuildContext`.
- UI laser helst providers eller read models, inte repository direkt.
- Permanent lagring gar via `../../data/repositories/local_storage_repository.dart` genom providers eller use cases.