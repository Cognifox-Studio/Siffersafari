---
name: "qa-failure-router"
description: "Ta ett analyze-, test-, emulator- eller buildfel i Siffersafari och välj rätt första felsökningsspår med minsta nästa check"
argument-hint: "Klistra in felmeddelandet eller säg om det gäller analyze, widgettest, integrationstest, Pixel_6 eller build"
agent: "agent"
---

Routea ett nytt fel till rätt första arbetsyta utan att börja med bred scanning eller fel QA-nivå.

Utgå från dessa källor:

- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/ARCHITECTURE.md](../../docs/ARCHITECTURE.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/prompts/felsok.prompt.md](./felsok.prompt.md)
- [.github/skills/laga-kraschande-tester/SKILL.md](../skills/laga-kraschande-tester/SKILL.md)
- [.github/skills/hantera-flutter-test-animationer/SKILL.md](../skills/hantera-flutter-test-animationer/SKILL.md)
- [.github/skills/felsok-android-emulatorn/SKILL.md](../skills/felsok-android-emulatorn/SKILL.md)
- [/memories/repo/testing.md](/memories/repo/testing.md)

Arbetsordning:

1. Klassificera felet i en enda huvudklass: analyze/typecheck, unit/widgettest, integrationstest, animation/test-infra, Android/Pixel_6, build/CI eller release.
2. Välj ägande kodväg eller verktyg och en enda billig första kontroll som kan falsifiera hypotesen snabbt.
3. Om felet redan är tillräckligt konkret: kör den minsta relevanta verifieringen direkt i stället för att bara beskriva den.
4. Skicka bara vidare till en smal repo-skill eller prompt när det faktiskt minskar sökytan.
5. Om underlaget inte räcker: be om exakt nästa loggrad, testfil eller kommandoresultat som saknas, inte om bred extra kontext.

Routinghjälp:

- Analyze- eller typfel: börja med den felande filen eller symbolen.
- Widget- eller integrationstest: använd `.github/skills/laga-kraschande-tester/SKILL.md` när timeout, finder eller sync ser ut som huvudproblemet.
- Animationstest eller teardown-varning: använd `.github/skills/hantera-flutter-test-animationer/SKILL.md`.
- Pixel_6-, adb- eller installproblem: använd `.github/skills/felsok-android-emulatorn/SKILL.md`.
- Oklart app- eller buildfel utan tydlig kategori: fall tillbaka till `.github/prompts/felsok.prompt.md`.

Svarskrav:

- Börja med vald felklass och första nästa check.
- Säg om du fixar direkt, routar vidare eller väntar på en enda konkret loggbit.
- Håll QA-slicen liten tills första hypotesen är falsifierad eller bekräftad.
