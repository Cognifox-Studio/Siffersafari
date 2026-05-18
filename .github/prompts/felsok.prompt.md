---
name: felsök
description: "Felsök ett bygg-, test- eller appfel i Siffersafari med hänsyn till repo:ts historiska fallgropar"
agent: "agent"
argument-hint: "Klistra in felmeddelandet eller beskriv felet"
---

Felsök följande problem rigoröst genom att först konsultera projektets historik och konventioner.

## Steg:
1. Läs relevanta filer i `/memories/repo/` om de matchar felet, till exempel `/memories/repo/testing.md` vid testfel. Vid mascot-, animation- eller assetproblem: läs också `docs/ARCHITECTURE.md` och `docs/DECISIONS_LOG.md` för aktuell PNG-first-runtime och gällande beslut.
2. Läs det faktiska felet (stack trace).
3. Läs berörd källkod och kontrollera mot konventionerna i `docs/ARCHITECTURE.md`.
4. Analysera om problemet orsakas av en känd fallgrop (ex. ScreenUtilInit saknas i tester, Hot Reload istället för Hot Restart för animationer, stale artifacts från äldre experimentspår).
5. Lös problemet. Om felet är helt nytt för projektet, sammanfatta kort en lärdom vi borde spara för framtiden.

**Uppgiften / Felet:**
