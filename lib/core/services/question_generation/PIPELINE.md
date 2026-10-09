# Question generation pipeline

Flow: **QuestionRequest** → **QuestionGenerationContext** (MixPolicy + flags) → **dispatch** → **Question**.

| Module | Role |
|--------|------|
| [question_request.dart](question_request.dart) | Stable input DTO |
| [question_generation_context.dart](question_generation_context.dart) | MixPolicy, steps, format toggles |
| [question_mix_policy.dart](../question_mix_policy.dart) | Step-bound mix gates |
| [question_generator_service__pipeline_part.dart](../question_generator_service__pipeline_part.dart) | Source dispatch (bank vs procedural) |
| [question_generator_service__impl_part.dart](../question_generator_service__impl_part.dart) | Bank + M4/M5 + procedural generators |
| [question_generator_service__helpers_part.dart](../question_generator_service__helpers_part.dart) | Shared helpers, wrong answers |

New curriculum slices should add a dispatch branch + impl generator (or bank loader), then extend bank/runtime audits under `test/unit/audits/`.
