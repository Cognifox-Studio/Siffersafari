/// High-level source paths used by [QuestionGeneratorPipeline] dispatch.
///
/// Bank-driven generators live in `question_generator_service__impl_part.dart`
/// (M4/M5a/M5b and grade-bank helpers). Procedural paths use operation switches.
enum QuestionSourceKind {
  mixSpecialM4,
  mixSpecialM5,
  lowGradeSpecial,
  bankCurriculum,
  proceduralOperation,
  recursiveMixed,
}
