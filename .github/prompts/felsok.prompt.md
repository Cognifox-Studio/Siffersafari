---
name: felsök
description: "Felsök ett bygg-, test- eller appfel i Siffersafari med hänsyn till repo:ts historiska fallgropar"
agent: "agent"
argument-hint: "Klistra in felmeddelandet eller beskriv felet"
---

Felsök följande problem rigoröst genom att först konsultera projektets historik och konventioner.

## Steg:
1. Läs relevanta filer i \/memories/repo/\ om de matchar felet (t.ex. \	esting.md\ vid testfel, eller \lottie_only_mascot_2026-03-09.md\ vid mascot-krasch).
2. Läs det faktiska felet (stack trace).
3. Läs berörd källkod och kontrollera mot konventionerna i \docs/ARCHITECTURE.md\.
4. Analysera om problemet orsakas av en känd fallgrop (ex. ScreenUtilInit saknas i tester, Hot Reload istället för Hot Restart för animationer, Rive-rester).
5. Lös problemet. Om felet är helt nytt för projektet, sammanfatta kort en lärdom vi borde spara för framtiden.

**Uppgiften / Felet:**
