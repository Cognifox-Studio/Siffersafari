# Quiz

Ansvar: sjalva spelpasset. Har genereras fragor, svar utvarderas, feedback visas och slutresultatet skickas vidare for permanent merge.

## Borja har

- `presentation/screens/quiz_screen.dart`
- `presentation/screens/results_screen.dart`
- `presentation/dialogs/feedback_dialog.dart`
- `../../core/providers/quiz_provider.dart`
- `../../core/providers/user_provider.dart`

## Viktiga services

- `../../core/services/quiz_session_planner.dart`
- `../../core/services/question_generator_service.dart`
- `../../core/services/apply_quiz_result_use_case.dart`
- `../../domain/services/feedback_service.dart`

## Sparar

- pagaende session i `quiz_history`
- slutresultat tillbaka till `user_progress`
- complete history som idempotency guard i `quiz_history`

## Bra forsta test

- `test/widget/app_quiz_flow_test.dart`
- `test/widget/quiz_screen_tts_test.dart`
- `test/unit/services/quiz_session_planner_test.dart`
- `test/unit/logic/quiz_progression_edge_cases_test.dart`