window.__PROJECT_GRAPH__ = {
  "generatedAt": "2026-05-11T21:55:27.196992",
  "repoRoot": "D:/Projects/Personal/Multiplikation",
  "stats": {
    "dartFiles": 98,
    "modules": 26,
    "edges": 125
  },
  "columns": [
    {
      "id": "entry",
      "label": "Appstart"
    },
    {
      "id": "features",
      "label": "Skärmar & UI"
    },
    {
      "id": "state",
      "label": "Tillstånd & kopplingar"
    },
    {
      "id": "services",
      "label": "Tjänster"
    },
    {
      "id": "foundation",
      "label": "Modeller & lagring"
    }
  ],
  "modules": [
    {
      "id": "main",
      "label": "Appens startfil",
      "technicalLabel": "main.dart",
      "description": "Första filen som startar Flutter-appen.",
      "path": "lib/main.dart",
      "column": "entry",
      "kind": "entrypoint",
      "kindLabel": "start",
      "fileCount": 1,
      "roleCounts": {
        "entrypoint": 1
      },
      "files": [
        "lib/main.dart"
      ]
    },
    {
      "id": "app/bootstrap",
      "label": "Appstart",
      "technicalLabel": "app/bootstrap",
      "description": "Bestämmer hur appen startar och vart användaren skickas först.",
      "path": "lib/app/bootstrap",
      "column": "entry",
      "kind": "app",
      "kindLabel": "appflöde",
      "fileCount": 2,
      "roleCounts": {
        "dart": 2
      },
      "files": [
        "lib/app/bootstrap/presentation/startup_flow_gate.dart",
        "lib/app/bootstrap/presentation/startup_splash_gate.dart"
      ]
    },
    {
      "id": "feature:daily_challenge",
      "label": "Daglig utmaning",
      "technicalLabel": "features/daily_challenge",
      "description": "Skärmar, dialoger och widgets för daglig utmaning.",
      "path": "lib/features/daily_challenge",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 2,
      "roleCounts": {
        "dart": 1,
        "provider": 1
      },
      "files": [
        "lib/features/daily_challenge/presentation/widgets/daily_challenge_card.dart",
        "lib/features/daily_challenge/providers/daily_challenge_provider.dart"
      ]
    },
    {
      "id": "presentation/widgets",
      "label": "Delad UI",
      "technicalLabel": "presentation/widgets",
      "description": "UI-komponenter som delas mellan flera delar av appen.",
      "path": "lib/presentation/widgets",
      "column": "features",
      "kind": "shared-ui",
      "kindLabel": "delad UI",
      "fileCount": 7,
      "roleCounts": {
        "dart": 7
      },
      "files": [
        "lib/presentation/widgets/confetti_overlay.dart",
        "lib/presentation/widgets/game_character.dart",
        "lib/presentation/widgets/mascot_reaction_view.dart",
        "lib/presentation/widgets/playful_panel.dart",
        "lib/presentation/widgets/progress_indicator_bar.dart",
        "lib/presentation/widgets/star_rating.dart",
        "lib/presentation/widgets/themed_background_scaffold.dart"
      ]
    },
    {
      "id": "feature:onboarding",
      "label": "Första gången",
      "technicalLabel": "features/onboarding",
      "description": "Skärmar, dialoger och widgets för första gången.",
      "path": "lib/features/onboarding",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 2,
      "roleCounts": {
        "screen": 2
      },
      "files": [
        "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart",
        "lib/features/onboarding/presentation/screens/onboarding_screen.dart"
      ]
    },
    {
      "id": "feature:parent",
      "label": "Föräldraläge",
      "technicalLabel": "features/parent",
      "description": "Skärmar, dialoger och widgets för föräldraläge.",
      "path": "lib/features/parent",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 3,
      "roleCounts": {
        "screen": 3
      },
      "files": [
        "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
        "lib/features/parent/presentation/screens/parent_pin_screen.dart",
        "lib/features/parent/presentation/screens/pin_recovery_screen.dart"
      ]
    },
    {
      "id": "feature:home",
      "label": "Hem",
      "technicalLabel": "features/home",
      "description": "Skärmar, dialoger och widgets för hem.",
      "path": "lib/features/home",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 3,
      "roleCounts": {
        "dart": 2,
        "screen": 1
      },
      "files": [
        "lib/features/home/presentation/screens/home_screen.dart",
        "lib/features/home/presentation/widgets/camp_scene_view.dart",
        "lib/features/home/presentation/widgets/home_story_progress_card.dart"
      ]
    },
    {
      "id": "feature:settings",
      "label": "Inställningar",
      "technicalLabel": "features/settings",
      "description": "Skärmar, dialoger och widgets för inställningar.",
      "path": "lib/features/settings",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 2,
      "roleCounts": {
        "screen": 2
      },
      "files": [
        "lib/features/settings/presentation/screens/privacy_policy_screen.dart",
        "lib/features/settings/presentation/screens/settings_screen.dart"
      ]
    },
    {
      "id": "feature:inventory",
      "label": "Inventory",
      "technicalLabel": "features/inventory",
      "description": "Skärmar, dialoger och widgets för inventory.",
      "path": "lib/features/inventory",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 1,
      "roleCounts": {
        "screen": 1
      },
      "files": [
        "lib/features/inventory/presentation/screens/wardrobe_screen.dart"
      ]
    },
    {
      "id": "feature:profiles",
      "label": "Profiler",
      "technicalLabel": "features/profiles",
      "description": "Skärmar, dialoger och widgets för profiler.",
      "path": "lib/features/profiles",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 2,
      "roleCounts": {
        "dialog": 1,
        "screen": 1
      },
      "files": [
        "lib/features/profiles/presentation/dialogs/create_user_dialog.dart",
        "lib/features/profiles/presentation/screens/profile_selection_screen.dart"
      ]
    },
    {
      "id": "feature:quiz",
      "label": "Quiz",
      "technicalLabel": "features/quiz",
      "description": "Skärmar, dialoger och widgets för quiz.",
      "path": "lib/features/quiz",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 5,
      "roleCounts": {
        "dart": 2,
        "dialog": 1,
        "screen": 2
      },
      "files": [
        "lib/features/quiz/presentation/dialogs/feedback_dialog.dart",
        "lib/features/quiz/presentation/screens/quiz_screen.dart",
        "lib/features/quiz/presentation/screens/results_screen.dart",
        "lib/features/quiz/presentation/widgets/answer_button.dart",
        "lib/features/quiz/presentation/widgets/question_card.dart"
      ]
    },
    {
      "id": "feature:story",
      "label": "Storykarta",
      "technicalLabel": "features/story",
      "description": "Skärmar, dialoger och widgets för storykarta.",
      "path": "lib/features/story",
      "column": "features",
      "kind": "feature",
      "kindLabel": "feature",
      "fileCount": 1,
      "roleCounts": {
        "screen": 1
      },
      "files": [
        "lib/features/story/presentation/screens/story_map_screen.dart"
      ]
    },
    {
      "id": "core/providers",
      "label": "Tillstånd",
      "technicalLabel": "core/providers",
      "description": "Riverpod-state som UI:t läser och uppdaterar.",
      "path": "lib/core/providers",
      "column": "state",
      "kind": "core",
      "kindLabel": "grundsystem",
      "fileCount": 18,
      "roleCounts": {
        "provider": 18
      },
      "files": [
        "lib/core/providers/achievement_service_provider.dart",
        "lib/core/providers/adaptive_difficulty_service_provider.dart",
        "lib/core/providers/app_analytics_provider.dart",
        "lib/core/providers/app_theme_provider.dart",
        "lib/core/providers/audio_service_provider.dart",
        "lib/core/providers/feedback_service_provider.dart",
        "lib/core/providers/local_storage_repository_provider.dart",
        "lib/core/providers/missing_number_settings_provider.dart",
        "lib/core/providers/parent_pin_service_provider.dart",
        "lib/core/providers/parent_settings_provider.dart",
        "lib/core/providers/quest_progression_service_provider.dart",
        "lib/core/providers/question_generator_service_provider.dart",
        "lib/core/providers/quiz_provider.dart",
        "lib/core/providers/spaced_repetition_service_provider.dart",
        "lib/core/providers/spaced_repetition_settings_provider.dart",
        "lib/core/providers/story_progress_provider.dart",
        "lib/core/providers/user_provider.dart",
        "lib/core/providers/word_problems_settings_provider.dart"
      ]
    },
    {
      "id": "core/di",
      "label": "Tjänstkoppling",
      "technicalLabel": "core/di",
      "description": "Registrerar vilka tjänster appen kan hämta globalt via GetIt.",
      "path": "lib/core/di",
      "column": "state",
      "kind": "core",
      "kindLabel": "grundsystem",
      "fileCount": 1,
      "roleCounts": {
        "dart": 1
      },
      "files": [
        "lib/core/di/injection.dart"
      ]
    },
    {
      "id": "core/services",
      "label": "Apptjänster",
      "technicalLabel": "core/services",
      "description": "Återanvändbar appnära logik som ljud, frågor och progression.",
      "path": "lib/core/services",
      "column": "services",
      "kind": "core",
      "kindLabel": "grundsystem",
      "fileCount": 7,
      "roleCounts": {
        "service": 7
      },
      "files": [
        "lib/core/services/achievement_service.dart",
        "lib/core/services/app_analytics_service.dart",
        "lib/core/services/audio_service.dart",
        "lib/core/services/daily_challenge_service.dart",
        "lib/core/services/quest_progression_service.dart",
        "lib/core/services/question_generator_service.dart",
        "lib/core/services/story_progression_service.dart"
      ]
    },
    {
      "id": "domain/services",
      "label": "Domänregler",
      "technicalLabel": "domain/services",
      "description": "Ren affärslogik utan UI, till exempel svårighetsgrad och PIN-regler.",
      "path": "lib/domain/services",
      "column": "services",
      "kind": "domain",
      "kindLabel": "affärsregler",
      "fileCount": 4,
      "roleCounts": {
        "service": 4
      },
      "files": [
        "lib/domain/services/adaptive_difficulty_service.dart",
        "lib/domain/services/feedback_service.dart",
        "lib/domain/services/parent_pin_service.dart",
        "lib/domain/services/spaced_repetition_service.dart"
      ]
    },
    {
      "id": "domain/entities",
      "label": "Datamodeller",
      "technicalLabel": "domain/entities",
      "description": "Grundläggande datamodeller som frågor, profiler och progression.",
      "path": "lib/domain/entities",
      "column": "foundation",
      "kind": "domain",
      "kindLabel": "affärsregler",
      "fileCount": 11,
      "roleCounts": {
        "entity": 11
      },
      "files": [
        "lib/domain/entities/inventory_item.dart",
        "lib/domain/entities/level_up_event.dart",
        "lib/domain/entities/pin_recovery_config.dart",
        "lib/domain/entities/quest.dart",
        "lib/domain/entities/question.dart",
        "lib/domain/entities/question_json.dart",
        "lib/domain/entities/quiz_session.dart",
        "lib/domain/entities/quiz_session_json.dart",
        "lib/domain/entities/story_progress.dart",
        "lib/domain/entities/user_progress.dart",
        "lib/domain/entities/user_progress.g.dart"
      ]
    },
    {
      "id": "domain/constants",
      "label": "Domänkonstanter",
      "technicalLabel": "domain/constants",
      "description": "Fasta regler och standardvärden för matte- och inlärningsdomänen.",
      "path": "lib/domain/constants",
      "column": "foundation",
      "kind": "domain",
      "kindLabel": "affärsregler",
      "fileCount": 1,
      "roleCounts": {
        "constant": 1
      },
      "files": [
        "lib/domain/constants/learning_constants.dart"
      ]
    },
    {
      "id": "gen",
      "label": "Genererad kod",
      "technicalLabel": "gen",
      "description": "Kod som genereras automatiskt och normalt inte skrivs för hand.",
      "path": "lib/gen",
      "column": "foundation",
      "kind": "generated",
      "kindLabel": "genererat",
      "fileCount": 1,
      "roleCounts": {
        "dart": 1
      },
      "files": [
        "lib/gen/assets.g.dart"
      ]
    },
    {
      "id": "core/utils",
      "label": "Hjälpfunktioner",
      "technicalLabel": "core/utils",
      "description": "Små hjälpfunktioner och stödlogik.",
      "path": "lib/core/utils",
      "column": "foundation",
      "kind": "core",
      "kindLabel": "grundsystem",
      "fileCount": 3,
      "roleCounts": {
        "dart": 3
      },
      "files": [
        "lib/core/utils/adaptive_layout.dart",
        "lib/core/utils/input_validators.dart",
        "lib/core/utils/page_transitions.dart"
      ]
    },
    {
      "id": "core/config",
      "label": "Konfiguration",
      "technicalLabel": "core/config",
      "description": "Samlad konfiguration och funktionsflaggor för appen.",
      "path": "lib/core/config",
      "column": "foundation",
      "kind": "core",
      "kindLabel": "grundsystem",
      "fileCount": 3,
      "roleCounts": {
        "config": 3
      },
      "files": [
        "lib/core/config/app_features.dart",
        "lib/core/config/difficulty_config.dart",
        "lib/core/config/quiz_feature_settings.dart"
      ]
    },
    {
      "id": "core/constants",
      "label": "Konstanter",
      "technicalLabel": "core/constants",
      "description": "Fasta värden och nycklar som används på flera ställen.",
      "path": "lib/core/constants",
      "column": "foundation",
      "kind": "core",
      "kindLabel": "grundsystem",
      "fileCount": 5,
      "roleCounts": {
        "constant": 5
      },
      "files": [
        "lib/core/constants/achievement_ids.dart",
        "lib/core/constants/app_constants.dart",
        "lib/core/constants/settings_keys.dart",
        "lib/core/constants/storage_constants.dart",
        "lib/core/constants/ui_constants.dart"
      ]
    },
    {
      "id": "data/repositories",
      "label": "Lagring",
      "technicalLabel": "data/repositories",
      "description": "Läser och sparar lokal data, främst via Hive.",
      "path": "lib/data/repositories",
      "column": "foundation",
      "kind": "data",
      "kindLabel": "lagring",
      "fileCount": 1,
      "roleCounts": {
        "repository": 1
      },
      "files": [
        "lib/data/repositories/local_storage_repository.dart"
      ]
    },
    {
      "id": "core/theme",
      "label": "Tema",
      "technicalLabel": "core/theme",
      "description": "Färger, typografi och andra visuella teman.",
      "path": "lib/core/theme",
      "column": "foundation",
      "kind": "core",
      "kindLabel": "grundsystem",
      "fileCount": 1,
      "roleCounts": {
        "dart": 1
      },
      "files": [
        "lib/core/theme/app_theme_config.dart"
      ]
    },
    {
      "id": "domain/enums",
      "label": "Typer & val",
      "technicalLabel": "domain/enums",
      "description": "Valbara typer och nivåer som används i affärslogiken.",
      "path": "lib/domain/enums",
      "column": "foundation",
      "kind": "domain",
      "kindLabel": "affärsregler",
      "fileCount": 10,
      "roleCounts": {
        "enum": 10
      },
      "files": [
        "lib/domain/enums/age_group.dart",
        "lib/domain/enums/age_group.g.dart",
        "lib/domain/enums/app_theme.dart",
        "lib/domain/enums/app_theme.g.dart",
        "lib/domain/enums/difficulty_level.dart",
        "lib/domain/enums/difficulty_level.g.dart",
        "lib/domain/enums/mastery_level.dart",
        "lib/domain/enums/mastery_level.g.dart",
        "lib/domain/enums/operation_type.dart",
        "lib/domain/enums/operation_type.g.dart"
      ]
    },
    {
      "id": "lib/wardrobe_preview.dart",
      "label": "Wardrobe Preview.dart",
      "technicalLabel": "wardrobe_preview.dart",
      "description": "Övrig kod som inte grupperats i en tydligare modul ännu.",
      "path": "lib/wardrobe_preview.dart",
      "column": "foundation",
      "kind": "other",
      "kindLabel": "övrigt",
      "fileCount": 1,
      "roleCounts": {
        "dart": 1
      },
      "files": [
        "lib/wardrobe_preview.dart"
      ]
    }
  ],
  "edges": [
    {
      "source": "domain/entities",
      "target": "domain/enums",
      "weight": 20,
      "examples": [
        {
          "from": "lib/domain/entities/quest.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/domain/entities/quest.dart",
          "to": "lib/domain/enums/mastery_level.dart"
        },
        {
          "from": "lib/domain/entities/quest.dart",
          "to": "lib/domain/enums/operation_type.dart"
        },
        {
          "from": "lib/domain/entities/question.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/domain/entities/question.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "core/providers",
      "weight": 15,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/dialogs/feedback_dialog.dart",
          "to": "lib/core/providers/user_provider.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/core/providers/app_analytics_provider.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/core/providers/audio_service_provider.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/core/providers/quiz_provider.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "core/providers",
      "weight": 11,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/providers/app_analytics_provider.dart"
        },
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/providers/audio_service_provider.dart"
        },
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/providers/local_storage_repository_provider.dart"
        },
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/providers/missing_number_settings_provider.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "core/services",
      "weight": 11,
      "examples": [
        {
          "from": "lib/core/providers/achievement_service_provider.dart",
          "to": "lib/core/services/achievement_service.dart"
        },
        {
          "from": "lib/core/providers/app_analytics_provider.dart",
          "to": "lib/core/services/app_analytics_service.dart"
        },
        {
          "from": "lib/core/providers/audio_service_provider.dart",
          "to": "lib/core/services/audio_service.dart"
        },
        {
          "from": "lib/core/providers/quest_progression_service_provider.dart",
          "to": "lib/core/services/quest_progression_service.dart"
        },
        {
          "from": "lib/core/providers/question_generator_service_provider.dart",
          "to": "lib/core/services/question_generator_service.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "core/providers",
      "weight": 10,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/providers/app_analytics_provider.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/providers/local_storage_repository_provider.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/providers/missing_number_settings_provider.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/providers/parent_settings_provider.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/providers/quiz_provider.dart"
        }
      ]
    },
    {
      "source": "core/services",
      "target": "domain/enums",
      "weight": 10,
      "examples": [
        {
          "from": "lib/core/services/daily_challenge_service.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/core/services/daily_challenge_service.dart",
          "to": "lib/domain/enums/operation_type.dart"
        },
        {
          "from": "lib/core/services/quest_progression_service.dart",
          "to": "lib/domain/enums/age_group.dart"
        },
        {
          "from": "lib/core/services/quest_progression_service.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/core/services/quest_progression_service.dart",
          "to": "lib/domain/enums/mastery_level.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "domain/entities",
      "weight": 9,
      "examples": [
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/entities/question.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/entities/quiz_session.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/entities/quiz_session_json.dart"
        },
        {
          "from": "lib/core/providers/story_progress_provider.dart",
          "to": "lib/domain/entities/story_progress.dart"
        },
        {
          "from": "lib/core/providers/user_provider.dart",
          "to": "lib/domain/entities/inventory_item.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "core/di",
      "weight": 8,
      "examples": [
        {
          "from": "lib/core/providers/achievement_service_provider.dart",
          "to": "lib/core/di/injection.dart"
        },
        {
          "from": "lib/core/providers/adaptive_difficulty_service_provider.dart",
          "to": "lib/core/di/injection.dart"
        },
        {
          "from": "lib/core/providers/audio_service_provider.dart",
          "to": "lib/core/di/injection.dart"
        },
        {
          "from": "lib/core/providers/feedback_service_provider.dart",
          "to": "lib/core/di/injection.dart"
        },
        {
          "from": "lib/core/providers/local_storage_repository_provider.dart",
          "to": "lib/core/di/injection.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "domain/enums",
      "weight": 8,
      "examples": [
        {
          "from": "lib/core/providers/app_theme_provider.dart",
          "to": "lib/domain/enums/app_theme.dart"
        },
        {
          "from": "lib/core/providers/parent_settings_provider.dart",
          "to": "lib/domain/enums/operation_type.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/enums/age_group.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "core/config",
      "weight": 8,
      "examples": [
        {
          "from": "lib/core/providers/missing_number_settings_provider.dart",
          "to": "lib/core/config/quiz_feature_settings.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/core/config/app_features.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/core/config/difficulty_config.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/core/config/quiz_feature_settings.dart"
        },
        {
          "from": "lib/core/providers/spaced_repetition_settings_provider.dart",
          "to": "lib/core/config/quiz_feature_settings.dart"
        }
      ]
    },
    {
      "source": "core/services",
      "target": "domain/entities",
      "weight": 8,
      "examples": [
        {
          "from": "lib/core/services/achievement_service.dart",
          "to": "lib/domain/entities/quiz_session.dart"
        },
        {
          "from": "lib/core/services/achievement_service.dart",
          "to": "lib/domain/entities/user_progress.dart"
        },
        {
          "from": "lib/core/services/daily_challenge_service.dart",
          "to": "lib/domain/entities/user_progress.dart"
        },
        {
          "from": "lib/core/services/quest_progression_service.dart",
          "to": "lib/domain/entities/quest.dart"
        },
        {
          "from": "lib/core/services/quest_progression_service.dart",
          "to": "lib/domain/entities/user_progress.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "domain/entities",
      "weight": 8,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/domain/entities/question.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/domain/entities/inventory_item.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/domain/entities/level_up_event.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/domain/entities/question.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/domain/entities/quiz_session.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "presentation/widgets",
      "weight": 8,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/dialogs/feedback_dialog.dart",
          "to": "lib/presentation/widgets/game_character.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/presentation/widgets/progress_indicator_bar.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/presentation/widgets/confetti_overlay.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/presentation/widgets/game_character.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "data/repositories",
      "weight": 7,
      "examples": [
        {
          "from": "lib/core/providers/local_storage_repository_provider.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        },
        {
          "from": "lib/core/providers/missing_number_settings_provider.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        },
        {
          "from": "lib/core/providers/parent_settings_provider.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        },
        {
          "from": "lib/core/providers/spaced_repetition_settings_provider.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "domain/services",
      "weight": 7,
      "examples": [
        {
          "from": "lib/core/providers/adaptive_difficulty_service_provider.dart",
          "to": "lib/domain/services/adaptive_difficulty_service.dart"
        },
        {
          "from": "lib/core/providers/feedback_service_provider.dart",
          "to": "lib/domain/services/feedback_service.dart"
        },
        {
          "from": "lib/core/providers/parent_pin_service_provider.dart",
          "to": "lib/domain/services/parent_pin_service.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/services/adaptive_difficulty_service.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/services/feedback_service.dart"
        }
      ]
    },
    {
      "source": "core/di",
      "target": "domain/enums",
      "weight": 5,
      "examples": [
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/enums/age_group.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/enums/app_theme.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/enums/mastery_level.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "core/constants",
      "weight": 5,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/dialogs/feedback_dialog.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/quiz/presentation/widgets/answer_button.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/quiz/presentation/widgets/question_card.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "presentation/widgets",
      "weight": 5,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/presentation/widgets/game_character.dart"
        },
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/presentation/widgets/playful_panel.dart"
        },
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        },
        {
          "from": "lib/features/home/presentation/widgets/camp_scene_view.dart",
          "to": "lib/presentation/widgets/game_character.dart"
        },
        {
          "from": "lib/features/home/presentation/widgets/home_story_progress_card.dart",
          "to": "lib/presentation/widgets/playful_panel.dart"
        }
      ]
    },
    {
      "source": "feature:profiles",
      "target": "core/providers",
      "weight": 5,
      "examples": [
        {
          "from": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart",
          "to": "lib/core/providers/user_provider.dart"
        },
        {
          "from": "lib/features/profiles/presentation/screens/profile_selection_screen.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/features/profiles/presentation/screens/profile_selection_screen.dart",
          "to": "lib/core/providers/audio_service_provider.dart"
        },
        {
          "from": "lib/features/profiles/presentation/screens/profile_selection_screen.dart",
          "to": "lib/core/providers/user_provider.dart"
        }
      ]
    },
    {
      "source": "presentation/widgets",
      "target": "core/constants",
      "weight": 4,
      "examples": [
        {
          "from": "lib/presentation/widgets/playful_panel.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/presentation/widgets/progress_indicator_bar.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/presentation/widgets/star_rating.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/presentation/widgets/themed_background_scaffold.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "core/utils",
      "weight": 4,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/core/utils/adaptive_layout.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/core/utils/page_transitions.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/core/utils/adaptive_layout.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/core/utils/page_transitions.dart"
        }
      ]
    },
    {
      "source": "core/di",
      "target": "core/services",
      "weight": 4,
      "examples": [
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/core/services/achievement_service.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/core/services/audio_service.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/core/services/quest_progression_service.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/core/services/question_generator_service.dart"
        }
      ]
    },
    {
      "source": "feature:onboarding",
      "target": "core/providers",
      "weight": 4,
      "examples": [
        {
          "from": "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart",
          "to": "lib/core/providers/user_provider.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/core/providers/local_storage_repository_provider.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/core/providers/parent_settings_provider.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/core/providers/user_provider.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "core/utils",
      "weight": 4,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/utils/adaptive_layout.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/utils/page_transitions.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/parent_pin_screen.dart",
          "to": "lib/core/utils/input_validators.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/pin_recovery_screen.dart",
          "to": "lib/core/utils/input_validators.dart"
        }
      ]
    },
    {
      "source": "feature:onboarding",
      "target": "presentation/widgets",
      "weight": 4,
      "examples": [
        {
          "from": "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart",
          "to": "lib/presentation/widgets/mascot_reaction_view.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/presentation/widgets/playful_panel.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "presentation/widgets",
      "weight": 3,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/parent_pin_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/pin_recovery_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        }
      ]
    },
    {
      "source": "feature:settings",
      "target": "core/providers",
      "weight": 3,
      "examples": [
        {
          "from": "lib/features/settings/presentation/screens/privacy_policy_screen.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/features/settings/presentation/screens/settings_screen.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/features/settings/presentation/screens/settings_screen.dart",
          "to": "lib/core/providers/user_provider.dart"
        }
      ]
    },
    {
      "source": "feature:profiles",
      "target": "presentation/widgets",
      "weight": 3,
      "examples": [
        {
          "from": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart",
          "to": "lib/presentation/widgets/game_character.dart"
        },
        {
          "from": "lib/features/profiles/presentation/screens/profile_selection_screen.dart",
          "to": "lib/presentation/widgets/playful_panel.dart"
        },
        {
          "from": "lib/features/profiles/presentation/screens/profile_selection_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "core/constants",
      "weight": 3,
      "examples": [
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/core/constants/settings_keys.dart"
        },
        {
          "from": "lib/core/providers/user_provider.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "feature:inventory",
      "target": "presentation/widgets",
      "weight": 3,
      "examples": [
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/presentation/widgets/game_character.dart"
        },
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/presentation/widgets/playful_panel.dart"
        },
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        }
      ]
    },
    {
      "source": "feature:inventory",
      "target": "core/providers",
      "weight": 3,
      "examples": [
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/core/providers/audio_service_provider.dart"
        },
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/core/providers/user_provider.dart"
        }
      ]
    },
    {
      "source": "core/di",
      "target": "domain/services",
      "weight": 3,
      "examples": [
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/services/adaptive_difficulty_service.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/services/feedback_service.dart"
        },
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/services/parent_pin_service.dart"
        }
      ]
    },
    {
      "source": "core/config",
      "target": "domain/enums",
      "weight": 3,
      "examples": [
        {
          "from": "lib/core/config/difficulty_config.dart",
          "to": "lib/domain/enums/age_group.dart"
        },
        {
          "from": "lib/core/config/difficulty_config.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/core/config/difficulty_config.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "core/constants",
      "weight": 3,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/parent_pin_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/pin_recovery_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "feature:daily_challenge",
      "target": "core/services",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/daily_challenge/presentation/widgets/daily_challenge_card.dart",
          "to": "lib/core/services/daily_challenge_service.dart"
        },
        {
          "from": "lib/features/daily_challenge/providers/daily_challenge_provider.dart",
          "to": "lib/core/services/daily_challenge_service.dart"
        }
      ]
    },
    {
      "source": "presentation/widgets",
      "target": "core/providers",
      "weight": 2,
      "examples": [
        {
          "from": "lib/presentation/widgets/mascot_reaction_view.dart",
          "to": "lib/core/providers/user_provider.dart"
        },
        {
          "from": "lib/presentation/widgets/themed_background_scaffold.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        }
      ]
    },
    {
      "source": "domain/services",
      "target": "domain/constants",
      "weight": 2,
      "examples": [
        {
          "from": "lib/domain/services/adaptive_difficulty_service.dart",
          "to": "lib/domain/constants/learning_constants.dart"
        },
        {
          "from": "lib/domain/services/spaced_repetition_service.dart",
          "to": "lib/domain/constants/learning_constants.dart"
        }
      ]
    },
    {
      "source": "domain/services",
      "target": "domain/enums",
      "weight": 2,
      "examples": [
        {
          "from": "lib/domain/services/adaptive_difficulty_service.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/domain/services/feedback_service.dart",
          "to": "lib/domain/enums/age_group.dart"
        }
      ]
    },
    {
      "source": "domain/services",
      "target": "domain/entities",
      "weight": 2,
      "examples": [
        {
          "from": "lib/domain/services/feedback_service.dart",
          "to": "lib/domain/entities/question.dart"
        },
        {
          "from": "lib/domain/services/parent_pin_service.dart",
          "to": "lib/domain/entities/pin_recovery_config.dart"
        }
      ]
    },
    {
      "source": "feature:daily_challenge",
      "target": "core/constants",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/daily_challenge/presentation/widgets/daily_challenge_card.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/daily_challenge/providers/daily_challenge_provider.dart",
          "to": "lib/core/constants/settings_keys.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "core/constants",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/home/presentation/widgets/home_story_progress_card.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "app/bootstrap",
      "target": "core/providers",
      "weight": 2,
      "examples": [
        {
          "from": "lib/app/bootstrap/presentation/startup_flow_gate.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/app/bootstrap/presentation/startup_flow_gate.dart",
          "to": "lib/core/providers/user_provider.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "core/utils",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/utils/adaptive_layout.dart"
        },
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/utils/page_transitions.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "domain/enums",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/domain/enums/difficulty_level.dart"
        },
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "feature:inventory",
      "target": "domain/entities",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/domain/entities/inventory_item.dart"
        },
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/domain/entities/user_progress.dart"
        }
      ]
    },
    {
      "source": "feature:onboarding",
      "target": "core/constants",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "feature:onboarding",
      "target": "core/utils",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart",
          "to": "lib/core/utils/adaptive_layout.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/core/utils/adaptive_layout.dart"
        }
      ]
    },
    {
      "source": "feature:onboarding",
      "target": "core/config",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/core/config/difficulty_config.dart"
        },
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/core/config/quiz_feature_settings.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "domain/services",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_pin_screen.dart",
          "to": "lib/domain/services/parent_pin_service.dart"
        },
        {
          "from": "lib/features/parent/presentation/screens/pin_recovery_screen.dart",
          "to": "lib/domain/services/parent_pin_service.dart"
        }
      ]
    },
    {
      "source": "feature:profiles",
      "target": "core/constants",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/profiles/presentation/screens/profile_selection_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "core/services",
      "target": "core/constants",
      "weight": 2,
      "examples": [
        {
          "from": "lib/core/services/achievement_service.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/core/services/app_analytics_service.dart",
          "to": "lib/core/constants/settings_keys.dart"
        }
      ]
    },
    {
      "source": "core/services",
      "target": "core/config",
      "weight": 2,
      "examples": [
        {
          "from": "lib/core/services/question_generator_service.dart",
          "to": "lib/core/config/app_features.dart"
        },
        {
          "from": "lib/core/services/question_generator_service.dart",
          "to": "lib/core/config/difficulty_config.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "gen",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/dialogs/feedback_dialog.dart",
          "to": "lib/gen/assets.g.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/gen/assets.g.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "core/config",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/core/config/difficulty_config.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/core/config/difficulty_config.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "domain/enums",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/domain/enums/operation_type.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "feature:home",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/screens/quiz_screen.dart",
          "to": "lib/features/home/presentation/screens/home_screen.dart"
        },
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/features/home/presentation/screens/home_screen.dart"
        }
      ]
    },
    {
      "source": "feature:settings",
      "target": "core/constants",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/settings/presentation/screens/privacy_policy_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/features/settings/presentation/screens/settings_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "data/repositories",
      "target": "core/constants",
      "weight": 2,
      "examples": [
        {
          "from": "lib/data/repositories/local_storage_repository.dart",
          "to": "lib/core/constants/app_constants.dart"
        },
        {
          "from": "lib/data/repositories/local_storage_repository.dart",
          "to": "lib/core/constants/settings_keys.dart"
        }
      ]
    },
    {
      "source": "feature:settings",
      "target": "presentation/widgets",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/settings/presentation/screens/privacy_policy_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        },
        {
          "from": "lib/features/settings/presentation/screens/settings_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        }
      ]
    },
    {
      "source": "feature:settings",
      "target": "core/utils",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/settings/presentation/screens/settings_screen.dart",
          "to": "lib/core/utils/adaptive_layout.dart"
        },
        {
          "from": "lib/features/settings/presentation/screens/settings_screen.dart",
          "to": "lib/core/utils/page_transitions.dart"
        }
      ]
    },
    {
      "source": "feature:story",
      "target": "core/providers",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/story/presentation/screens/story_map_screen.dart",
          "to": "lib/core/providers/app_theme_provider.dart"
        },
        {
          "from": "lib/features/story/presentation/screens/story_map_screen.dart",
          "to": "lib/core/providers/story_progress_provider.dart"
        }
      ]
    },
    {
      "source": "feature:story",
      "target": "presentation/widgets",
      "weight": 2,
      "examples": [
        {
          "from": "lib/features/story/presentation/screens/story_map_screen.dart",
          "to": "lib/presentation/widgets/playful_panel.dart"
        },
        {
          "from": "lib/features/story/presentation/screens/story_map_screen.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        }
      ]
    },
    {
      "source": "main",
      "target": "app/bootstrap",
      "weight": 2,
      "examples": [
        {
          "from": "lib/main.dart",
          "to": "lib/app/bootstrap/presentation/startup_flow_gate.dart"
        },
        {
          "from": "lib/main.dart",
          "to": "lib/app/bootstrap/presentation/startup_splash_gate.dart"
        }
      ]
    },
    {
      "source": "presentation/widgets",
      "target": "gen",
      "weight": 2,
      "examples": [
        {
          "from": "lib/presentation/widgets/game_character.dart",
          "to": "lib/gen/assets.g.dart"
        },
        {
          "from": "lib/presentation/widgets/mascot_reaction_view.dart",
          "to": "lib/gen/assets.g.dart"
        }
      ]
    },
    {
      "source": "feature:inventory",
      "target": "core/theme",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/core/theme/app_theme_config.dart"
        }
      ]
    },
    {
      "source": "app/bootstrap",
      "target": "presentation/widgets",
      "weight": 1,
      "examples": [
        {
          "from": "lib/app/bootstrap/presentation/startup_flow_gate.dart",
          "to": "lib/presentation/widgets/themed_background_scaffold.dart"
        }
      ]
    },
    {
      "source": "feature:daily_challenge",
      "target": "domain/enums",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/daily_challenge/presentation/widgets/daily_challenge_card.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "feature:inventory",
      "target": "gen",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/gen/assets.g.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "core/theme",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/providers/app_theme_provider.dart",
          "to": "lib/core/theme/app_theme_config.dart"
        }
      ]
    },
    {
      "source": "feature:daily_challenge",
      "target": "core/providers",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/daily_challenge/providers/daily_challenge_provider.dart",
          "to": "lib/core/providers/local_storage_repository_provider.dart"
        }
      ]
    },
    {
      "source": "core/constants",
      "target": "domain/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/constants/app_constants.dart",
          "to": "lib/domain/constants/learning_constants.dart"
        }
      ]
    },
    {
      "source": "feature:onboarding",
      "target": "core/theme",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart",
          "to": "lib/core/theme/app_theme_config.dart"
        }
      ]
    },
    {
      "source": "feature:daily_challenge",
      "target": "data/repositories",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/daily_challenge/providers/daily_challenge_provider.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        }
      ]
    },
    {
      "source": "feature:onboarding",
      "target": "feature:profiles",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart",
          "to": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart"
        }
      ]
    },
    {
      "source": "app/bootstrap",
      "target": "feature:home",
      "weight": 1,
      "examples": [
        {
          "from": "lib/app/bootstrap/presentation/startup_flow_gate.dart",
          "to": "lib/features/home/presentation/screens/home_screen.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "core/config",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/core/config/difficulty_config.dart"
        }
      ]
    },
    {
      "source": "feature:onboarding",
      "target": "domain/enums",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/onboarding/presentation/screens/onboarding_screen.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "core/config",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/core/config/difficulty_config.dart"
        }
      ]
    },
    {
      "source": "core/di",
      "target": "data/repositories",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        }
      ]
    },
    {
      "source": "core/providers",
      "target": "domain/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/providers/quiz_provider.dart",
          "to": "lib/domain/constants/learning_constants.dart"
        }
      ]
    },
    {
      "source": "core/di",
      "target": "domain/entities",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/di/injection.dart",
          "to": "lib/domain/entities/user_progress.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "domain/enums",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/domain/enums/operation_type.dart"
        }
      ]
    },
    {
      "source": "lib/wardrobe_preview.dart",
      "target": "presentation/widgets",
      "weight": 1,
      "examples": [
        {
          "from": "lib/wardrobe_preview.dart",
          "to": "lib/presentation/widgets/game_character.dart"
        }
      ]
    },
    {
      "source": "app/bootstrap",
      "target": "feature:onboarding",
      "weight": 1,
      "examples": [
        {
          "from": "lib/app/bootstrap/presentation/startup_flow_gate.dart",
          "to": "lib/features/onboarding/presentation/screens/initial_profile_setup_screen.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "domain/entities",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_pin_screen.dart",
          "to": "lib/domain/entities/pin_recovery_config.dart"
        }
      ]
    },
    {
      "source": "domain/services",
      "target": "data/repositories",
      "weight": 1,
      "examples": [
        {
          "from": "lib/domain/services/parent_pin_service.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        }
      ]
    },
    {
      "source": "feature:profiles",
      "target": "core/config",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart",
          "to": "lib/core/config/difficulty_config.dart"
        }
      ]
    },
    {
      "source": "domain/services",
      "target": "core/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/domain/services/parent_pin_service.dart",
          "to": "lib/core/constants/settings_keys.dart"
        }
      ]
    },
    {
      "source": "app/bootstrap",
      "target": "core/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/app/bootstrap/presentation/startup_flow_gate.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "feature:profiles",
      "target": "domain/enums",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart",
          "to": "lib/domain/enums/age_group.dart"
        }
      ]
    },
    {
      "source": "feature:profiles",
      "target": "gen",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart",
          "to": "lib/gen/assets.g.dart"
        }
      ]
    },
    {
      "source": "core/services",
      "target": "data/repositories",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/services/app_analytics_service.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        }
      ]
    },
    {
      "source": "feature:profiles",
      "target": "core/utils",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/profiles/presentation/screens/profile_selection_screen.dart",
          "to": "lib/core/utils/page_transitions.dart"
        }
      ]
    },
    {
      "source": "lib/wardrobe_preview.dart",
      "target": "gen",
      "weight": 1,
      "examples": [
        {
          "from": "lib/wardrobe_preview.dart",
          "to": "lib/gen/assets.g.dart"
        }
      ]
    },
    {
      "source": "app/bootstrap",
      "target": "feature:profiles",
      "weight": 1,
      "examples": [
        {
          "from": "lib/app/bootstrap/presentation/startup_flow_gate.dart",
          "to": "lib/features/profiles/presentation/screens/profile_selection_screen.dart"
        }
      ]
    },
    {
      "source": "feature:daily_challenge",
      "target": "domain/entities",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/daily_challenge/presentation/widgets/daily_challenge_card.dart",
          "to": "lib/domain/entities/user_progress.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "domain/services",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/dialogs/feedback_dialog.dart",
          "to": "lib/domain/services/feedback_service.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "feature:daily_challenge",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/features/daily_challenge/providers/daily_challenge_provider.dart"
        }
      ]
    },
    {
      "source": "core/theme",
      "target": "domain/enums",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/theme/app_theme_config.dart",
          "to": "lib/domain/enums/app_theme.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "feature:onboarding",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/features/onboarding/presentation/screens/onboarding_screen.dart"
        }
      ]
    },
    {
      "source": "core/theme",
      "target": "core/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/theme/app_theme_config.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "core/utils",
      "target": "core/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/utils/page_transitions.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "feature:parent",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/features/parent/presentation/screens/parent_pin_screen.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "feature:profiles",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart"
        }
      ]
    },
    {
      "source": "feature:quiz",
      "target": "feature:daily_challenge",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/quiz/presentation/screens/results_screen.dart",
          "to": "lib/features/daily_challenge/providers/daily_challenge_provider.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "feature:quiz",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/features/quiz/presentation/screens/quiz_screen.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "feature:settings",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/features/settings/presentation/screens/settings_screen.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "feature:story",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/screens/home_screen.dart",
          "to": "lib/features/story/presentation/screens/story_map_screen.dart"
        }
      ]
    },
    {
      "source": "core/config",
      "target": "core/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/config/quiz_feature_settings.dart",
          "to": "lib/core/constants/settings_keys.dart"
        }
      ]
    },
    {
      "source": "feature:settings",
      "target": "domain/enums",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/settings/presentation/screens/settings_screen.dart",
          "to": "lib/domain/enums/app_theme.dart"
        }
      ]
    },
    {
      "source": "feature:settings",
      "target": "feature:profiles",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/settings/presentation/screens/settings_screen.dart",
          "to": "lib/features/profiles/presentation/dialogs/create_user_dialog.dart"
        }
      ]
    },
    {
      "source": "feature:story",
      "target": "core/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/story/presentation/screens/story_map_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "feature:inventory",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/widgets/camp_scene_view.dart",
          "to": "lib/features/inventory/presentation/screens/wardrobe_screen.dart"
        }
      ]
    },
    {
      "source": "feature:story",
      "target": "core/utils",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/story/presentation/screens/story_map_screen.dart",
          "to": "lib/core/utils/adaptive_layout.dart"
        }
      ]
    },
    {
      "source": "feature:story",
      "target": "domain/entities",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/story/presentation/screens/story_map_screen.dart",
          "to": "lib/domain/entities/story_progress.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "gen",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/widgets/camp_scene_view.dart",
          "to": "lib/gen/assets.g.dart"
        }
      ]
    },
    {
      "source": "feature:home",
      "target": "domain/entities",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/home/presentation/widgets/home_story_progress_card.dart",
          "to": "lib/domain/entities/story_progress.dart"
        }
      ]
    },
    {
      "source": "presentation/widgets",
      "target": "domain/entities",
      "weight": 1,
      "examples": [
        {
          "from": "lib/presentation/widgets/game_character.dart",
          "to": "lib/domain/entities/inventory_item.dart"
        }
      ]
    },
    {
      "source": "feature:inventory",
      "target": "core/constants",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/inventory/presentation/screens/wardrobe_screen.dart",
          "to": "lib/core/constants/app_constants.dart"
        }
      ]
    },
    {
      "source": "core/config",
      "target": "data/repositories",
      "weight": 1,
      "examples": [
        {
          "from": "lib/core/config/quiz_feature_settings.dart",
          "to": "lib/data/repositories/local_storage_repository.dart"
        }
      ]
    },
    {
      "source": "presentation/widgets",
      "target": "core/theme",
      "weight": 1,
      "examples": [
        {
          "from": "lib/presentation/widgets/mascot_reaction_view.dart",
          "to": "lib/core/theme/app_theme_config.dart"
        }
      ]
    },
    {
      "source": "data/repositories",
      "target": "domain/entities",
      "weight": 1,
      "examples": [
        {
          "from": "lib/data/repositories/local_storage_repository.dart",
          "to": "lib/domain/entities/user_progress.dart"
        }
      ]
    },
    {
      "source": "lib/wardrobe_preview.dart",
      "target": "domain/entities",
      "weight": 1,
      "examples": [
        {
          "from": "lib/wardrobe_preview.dart",
          "to": "lib/domain/entities/inventory_item.dart"
        }
      ]
    },
    {
      "source": "feature:profiles",
      "target": "feature:home",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/profiles/presentation/screens/profile_selection_screen.dart",
          "to": "lib/features/home/presentation/screens/home_screen.dart"
        }
      ]
    },
    {
      "source": "feature:parent",
      "target": "feature:settings",
      "weight": 1,
      "examples": [
        {
          "from": "lib/features/parent/presentation/screens/parent_dashboard_screen.dart",
          "to": "lib/features/settings/presentation/screens/settings_screen.dart"
        }
      ]
    }
  ]
};
