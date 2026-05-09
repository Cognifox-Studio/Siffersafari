---
name: laga-kraschande-tester
description: "Focus on identifying root causes for timeout errors in integration tests or UI testing sync issues. Evaluates finders, timers, animations, and onboarding sync."
argument-hint: "Klistra in felmeddelandet eller ange vilken testfil som kraschar."
---

# Laga Kraschande Tester (Integration / UI)

## När den ska användas
- När ett integrationstest (t.ex. `app_smoke_test.dart`) failar med en `TimeoutException`.
- När integrationstesterna fastnar meddelandet: "Timed out waiting for...".
- När widget tester (eller integration) slänger varningar som "animation callback still active after dispose".
- När `find.text('...')` letar efter gamla UI-titlar.

## Verktygslåda och felsökningsordning

1. **Studera output-loggen / "Visible texts":** 
   Integrationstesternas `it.waitFor` spottar ofta ut en lista i loggen med vilka texter som var synliga på skärmen när testet failade. Läs av dem för att fastställa vilken av appens skärmar (ex. Onboarding eller Home) testet faktiskt fastnade i.
2. **Korskolla UI mot UI-Finders:**
   Kolla om gränssnittet nyss genomgått en justering av texter eller element. Ofta failar äldre tester för att de pekar på copy som numer kortats ner till följd av barn-UX-regler (t.ex. från "Vilken årskurs kör du?" till "Välj årskurs"). Sök i kodbasen efter gamla textsträngar.
3. **Oändliga animationer och Timeouts:**
   För applikationer med procedurella animationer, faller tester lätt på `tester.pumpAndSettle()`. Om ingen lösning finns, överväg testrutinerna i `test_utils.dart` (såsom `_cleanupAfterTest` eller loopade korta `tester.pump(Duration(milliseconds: 50))`).
4. **Kolla av teardown / Cleanup:** 
   Om felen rör tickers och dispose-säkringar, överväg att säkerställa att testverktygens cleanup byter ut widget-trädet the `const SizedBox.shrink()` innan testavslut för att stoppa tickers.