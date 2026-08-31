---
name: felsök
description: "Use when du redan har ett konkret bygg-, test- eller appfel och behöver djupare repo-medveten felsökning med hänsyn till historiska fallgropar"
agent: "agent"
argument-hint: "Klistra in felmeddelandet eller beskriv felet"
---

Felsök följande problem rigoröst. Anta att felet redan är konkret nog — gör **egen kort triage** här (ingen separat router-prompt).

## Steg

1. Klassificera snabbt: analyze/compile, unit/widget-test, integration, Pixel_6/adb, asset/runtime, eller persistens/Hive.
2. Läs relevanta filer i `/memories/repo/` om de matchar felet (t.ex. testing). Vid mascot/animation/asset: `docs/ARCHITECTURE.md` + `docs/DECISIONS_LOG.md` (PNG-first).
3. Vid Hive, local storage, resume eller annan persistens: följ `.github/skills/felsok-sparad-data/SKILL.md` tidigt.
4. Vid Pixel_6/adb/stale APK: `.github/skills/felsok-android-emulatorn/SKILL.md`.
5. Läs stack trace och berörd källkod mot `docs/ARCHITECTURE.md` / feature `START_HERE`.
6. Kolla kända fallgropar (ScreenUtilInit i tester, Hot Reload vs restart för animationer/assets, stale APK).
7. Lös problemet. Om felet är nytt för projektet: en kort lärdom att spara.

**Uppgiften / Felet:**
