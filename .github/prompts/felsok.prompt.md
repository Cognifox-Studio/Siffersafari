---
name: felsök
description: "Use when du redan har ett konkret bygg-, test- eller appfel och behöver djupare repo-medveten felsökning med hänsyn till historiska fallgropar"
agent: "agent"
argument-hint: "Klistra in felmeddelandet eller beskriv felet"
---

Felsök följande problem rigoröst efter att felet redan är tillräckligt konkret eller efter att första triage/routing redan är gjord.

## Steg:
1. Läs relevanta filer i `/memories/repo/` om de matchar felet, till exempel `/memories/repo/testing.md` vid testfel. Vid mascot-, animation- eller assetproblem: läs också `docs/ARCHITECTURE.md` och `docs/DECISIONS_LOG.md` för aktuell PNG-first-runtime och gällande beslut.
	Vid Hive-, local storage-, resume- eller annan persistensproblematik: peka tidigt vidare till `.github/skills/felsok-sparad-data/SKILL.md`.
2. Läs det faktiska felet (stack trace).
3. Läs berörd källkod och kontrollera mot konventionerna i `docs/ARCHITECTURE.md`.
4. Analysera om problemet orsakas av en känd fallgrop (ex. ScreenUtilInit saknas i tester, Hot Reload istället för Hot Restart för animationer, stale artifacts från äldre experimentspår).
5. Lös problemet. Om felet är helt nytt för projektet, sammanfatta kort en lärdom vi borde spara för framtiden.

**Uppgiften / Felet:**
