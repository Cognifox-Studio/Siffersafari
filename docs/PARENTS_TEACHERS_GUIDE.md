# Guide – Föräldrar/Lärare

## Översikt

Appen är en matte-träningsapp för barn 6–12 år (Åk 1–9) med:
- **Profiler** – flera barn kan använda samma enhet
- **Adaptiv svårighet** – anpassas efter barnets nivå
- **Föräldraläge med PIN** – statistik och inställningar
- **Offline-first** – fungerar utan internetanslutning

## Komma igång

### 1. Skapa profil
- **Inställningar → Skapa användare**
- Ange barnets namn och välj årskurs (Åk 1–9)
- Årskursen påverkar automatiskt talområde och svårighetsgrad

### 2. Välj räknesätt
- Öppna **Föräldraläge** (lås-ikon på startsidan)
- Ange PIN (sätts vid första användningen)
- Slå av/på räknesätt: Addition, Subtraktion, Multiplikation, Division
- Justera svårighet manuellt om barnet behöver enklare/svårare frågor

### 3. Låt barnet öva
- Barnet väljer räknesätt på startsidan
- Svårighet anpassas automatiskt efter resultat
- 5–10 minuter per session rekommenderas

## Föräldraläge (PIN)

Öppna via **lås-ikonen** på startsidan.

**Inne i föräldraläget:**
- **Översikt** – senaste quiz-resultat
- **Statistik** – svagaste områden + rekommendationer
- **Inställningar per barn** – räknesätt på/av, manuell svårighetsjustering
- **Säkerhet** – byt PIN, återställningskoder

**Tips:**
- Följ barnets progression i statistik-vyn
- Om barnet fastnar: justera ner svårigheten tillfälligt
- Om barnet tycker det är för lätt: höj svårigheten eller aktivera fler räknesätt

## Datahantering

**Var sparas data?**
- Lokalt på enheten (Hive-databas)
- Ingen molnsynk eller datadelning
- Data raderas vid avinstallation

**Backup/export:**
- I föräldraläge finns export-funktion
- Spara JSON-fil för att kunna återställa profiler

**Fungerar appen offline?**
- ✅ Ja, alla funktioner fungerar utan internet
- Appen laddar aldrig ner frågor eller skickar statistik

## Vanliga frågor

**Hur ofta ska mitt barn öva?**
- 5–10 minuter dagligen är bättre än längre pass mer sällan

**Mitt barn tycker det är för svårt/lätt**
- Öppna föräldraläge och justera svårigheten manuellt
- Alternativt: ändra årskurs om den inte stämmer med barnets nivå

**Kan flera barn dela samma enhet?**
- Ja, skapa en profil per barn
- Byt aktiv profil i Inställningar

**Är det säkert för barn?**
- Appen följer COPPA (Children's Online Privacy Protection Act)
- Ingen reklam, inga köp, ingen datadelning
- Föräldraläge är PIN-skyddat
