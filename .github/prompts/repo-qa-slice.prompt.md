---
name: "repo-qa-slice"
description: "Välj och kör minsta tillräckliga QA-slice för aktuell diff eller ett angivet riskområde i detta repo"
argument-hint: "Valfritt: beskriv ändringen, diffens scope eller ange ett riskområde som quiz, parent mode, Android, assets eller docs"
agent: "agent"
---

Valj och kor den minsta tillrackliga QA-slice som ger hog signal for den aktuella andringen i detta repo.

Utga fran dessa kallor:

- [copilot-instructions.md](../copilot-instructions.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ROADMAP.md](../../docs/ROADMAP.md)
- [.github/skills/testa-att-appen-fungerar/SKILL.md](../skills/testa-att-appen-fungerar/SKILL.md)
- [.github/skills/dubbelkolla-andrad-kod/SKILL.md](../skills/dubbelkolla-andrad-kod/SKILL.md)
- [.github/skills/testa-att-quiz-sparas-ratt/SKILL.md](../skills/testa-att-quiz-sparas-ratt/SKILL.md)
- [.vscode/tasks.json](../../.vscode/tasks.json)

Arbetsordning:

1. Klassificera andringen i en huvudklass: docs/customizations, Dart-logik, UI/presentation, quiz-persistens, parent mode, Android/release, assets/animation eller bred blandad diff.
2. Valj en enda primar QA-slice som ger snabbast falsifierbar signal.
3. Kor verifieringen, inte bara foresla den.
4. Eskalera bara om forsta slice inte racker eller om risken tydligt korsar flera lager.

Vagledning per slice:

1. Docs eller customization-filer:
- verifiera att namnda filer, tasks, scripts och interna lankar finns
- kor inte Flutter-QA om andringen verkligen ar docs-only

2. Dart-logik eller providers:
- borja med `QA: Analyze`
- kor den smalaste relevanta testfilen
- anvand `testa-att-quiz-sparas-ratt` om diffen ror session, resume, replay eller `applyQuizResult(...)`

3. UI eller widgetar:
- borja med `QA: Analyze`
- kor fokuserat widgettest
- eskalera till integration eller Pixel_6 bara om navigation, rendering, animation, asset eller state-handoff faktiskt paverkas

4. Android, enhet eller release:
- valj relevant Android- eller releasekontroll forst
- anvand Pixel_6-task eller script nar deviceverifiering behovs
- ta `flutter analyze` om Dart/runtime berors

5. Asset- eller animationsandring:
- kor relevant generator eller workflow forst
- fortsatt med analyze och riktad verifiering av konsumtionsvyn
- inkludera Pixel_6 sync/install nar devicebeteende ar en del av risken

Prioritera dessa tasks nar de matchar behovet:

- `QA: Analyze`
- `QA: Test (valfri path)`
- `QA: Test (alla)`
- `QA: Analyze + Test (valfri path)`
- `QA: Analyze + Full Test (stora andringar)`
- `Flutter: Sync (Pixel_6 only)`
- `Flutter: Install (Pixel_6 only)`
- `Pixel_6: Sync + QA (valfri testpath)`
- `QA: Integration Smoke (core)`
- `QA: Integration Smoke (full)`

Svarskrav:

- Skriv forst vilken slice du valde och varfor.
- Kora verifieringen direkt.
- Om nagot blockerar, sag exakt vad och vad nasta minsta rimliga alternativ ar.
- Avsluta med en kort sammanfattning av vad som korde, vad som passerade eller foll, och om ytterligare QA ar motiverad.