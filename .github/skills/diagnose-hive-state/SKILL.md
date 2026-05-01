# Diagnose Hive State

Använd denna skill när användaren ber om att felsöka, inspektera eller diagnostisera den lokala Hive-databasen (t.ex. när adaptiv svårighetsgrad beter sig oväntat, profildata inte sparas, eller vid offline-data-kraschar).

## Trigger-ord
`diagnose hive`, `debug hive`, `inspektera hive data`, `kolla hive db`, `varför sparas inte profilen`, `dump hive`

## Kontex & Syfte
Eftersom appen är 100% offline-first sparas allt i Hive. Ibland kan data bli korrupt, få fel datatyp (t.ex. `int` istället för `double`), eller så glöms temporär session-state (quiz) bort att mergas med den permanenta profilen. Denna skill hjälper AI:n att systematiskt inspektera vad Hive *faktiskt* har på disk eller i minnet just nu.

## Arbetsflöde (Workflow)

1. **Identifiera Target Box:** Fråga användaren eller analysera felet för att avgöra vilken Hive-box som strular (vanligtvis `user_progress`, `quiz_sessions`, eller `settings`).
2. **Välj Inspektionsmetod:**
   - *Metod A (Live i Emulator):* Injicera temporära `print(box.toMap())` eller loggar direkt inuti `LocalStorageRepository` vid `get()` eller `put()`, och be användaren köra appen och återskapa felet för att fånga utdatan.
   - *Metod B (Ad-hoc Test):* Skapa ett tillfälligt test i `test/debug_hive_state_test.dart` där isolerad data skapas, sparas och läses ut, för att bevisa om felet ligger i hur `dynamic`-data parsas (typ-validering).
3. **Analysera Datan:**
   - Kolla om obligatoriska nycklar saknas.
   - Kontrollera exakt datatyp (särskilt viktigt för siffror och listor som kommer från Hive).
   - Jämför skillnaden mellan vad appen förväntar sig (typade modeller) och vad den råa `dynamic`-strukturen från disk ger.
4. **Rapportera & Föreslå Lösning (på Svenska!):** 
   - Ge användaren en kort, koncis sammanfattning av vad som är fel. Undvik att dumpa 100 rader JSON.
   - Åberopa regeln om "Defensiv Data-validering" (`hive.instructions.md`) och skriv koden som säkert parsar datan.
5. **Städa upp (Cleanup):** Återställ ändringarna i `LocalStorageRepository` eller ta bort det temporära testskriptet innan felsökningen anses klar.