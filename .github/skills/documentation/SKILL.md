## Mallar/checklistor för varje Diátaxis-typ

### Tutorial ("Kom igång")
**Syfte:** Lär användaren genom att göra

**Mall:**
---
Diátaxis-typ: Tutorial

# [Titel]

1. Steg 1: ...
2. Steg 2: ...
3. ...

Tips: Håll det linjärt, inga sidospår, visa resultat efter varje steg.
---

### How-to guide ("Så gör du X")
**Syfte:** Lös ett specifikt problem

**Mall:**
---
Diátaxis-typ: How-to guide

# [Hur du ...]

Problem: [Kort beskrivning]

Steg:
1. ...
2. ...

Tips: Kort, direkt, inga förklaringar – bara lösning.
---

### Reference ("Fakta/API")
**Syfte:** Uppslagsverk, fakta, API, konfiguration

**Mall:**
---
Diátaxis-typ: Reference

# [API/Struktur/Config]

- [Fält/metod/parameter]: Beskrivning
- ...

Tips: Ingen vägledning, inga exempel, bara fakta.
---

### Explanation ("Varför/förståelse")
**Syfte:** Förklara bakgrund, design, resonemang

**Mall:**
---
Diátaxis-typ: Explanation

# [Varför ...]

Bakgrund:
- ...

Designval:
- ...

Tips: Ingen instruktion, inga steg, bara kontext och resonemang.
---
---
description: "Dokumentations-skill: Diátaxis-baserad vägledning, struktur och tips för dokumentation i projektet."
applyTo: "**"
---




# Dokumentations-skill (Diátaxis, fullständig spegling)

## Syfte

Styr all dokumentation enligt Diátaxis-ramverket. Dokumentationen ska **alltid** vara fullständigt synkad med faktisk kod, struktur, tjänster, assets och arbetsflöden. Minsta avvikelse ska omedelbart åtgärdas.

## Regler

1. All dokumentation ska klassificeras enligt Diátaxis (tutorial, how-to, reference, explanation).
2. Varje dokument ska ha tydlig typangivelse och syfte.
3. Dokumentationen ska **alltid** vara up-to-date och spegla exakt all faktisk kod, struktur, tjänster, assets och arbetsflöden.
4. Vid **minsta** förändring i kod, struktur, tjänster, assets eller arbetsflöde ska motsvarande dokumentation uppdateras direkt.
5. Om information krockar mellan dokument, gäller facitordningen i docs/README.md.
6. Om något nytt tillkommer (mappar, filer, tjänster, assets, arbetsflöden) ska det omedelbart läggas till i dokumentationen.
7. Om något tas bort ska det tas bort eller markeras som deprecated i dokumentationen.

## Workflow

1. Vid **varje** ändring i kod, struktur, tjänster, assets eller arbetsflöde:
	- Identifiera **alla** berörda dokument.
	- Uppdatera dokumentationen så att den exakt och fullständigt speglar verkligheten.
	- Kontrollera att Diátaxis-klassificering och typangivelse är korrekt.
2. Vid granskning:
	- Läs in **alla** relevanta dokument.
	- Jämför mot faktisk kodbas och struktur.
	- Om **minsta** avvikelse hittas: uppdatera dokumentet så att det är heltäckande och korrekt.
	- Om nya mappar, filer, tjänster, assets eller arbetsflöden tillkommit: lägg till dem i dokumentationen.
	- Om något tagits bort: ta bort eller markera som deprecated i dokumentationen.
3. Vid osäkerhet: fråga användaren om tolkning eller prioritet.

## Mallar

### Diátaxis-typ
```md
<!--
typ: tutorial | how-to | reference | explanation
syfte: ...
uppdaterad: YYYY-MM-DD
-->
```

### Checklista för varje dokument
- [ ] Typ och syfte är tydligt angivna
- [ ] Innehållet är aktuellt och speglar verkligheten
- [ ] Diátaxis-klassificering är korrekt
- [ ] **Alla** nya mappar, filer, tjänster, assets och arbetsflöden är dokumenterade
- [ ] Inget föråldrat eller felaktigt finns kvar

## Exempel på Diátaxis-index (docs/README.md)

... (exempeltext, se faktisk README.md)
**Reference**
- ARCHITECTURE.md ("Systemarkitektur")
- PROJECT_STRUCTURE.md ("Repo-struktur")
- SERVICES_API.md ("Service-API")

**Explanation**
- DECISIONS_LOG.md ("Designbeslut och varför")
- RIVERPOD_PATTERNS.md ("Provider-mönster och resonemang")


## Relaterade filer
- docs/README.md (index och typangivelser)
- docs/GETTING_STARTED.md (tutorial)
- docs/ADD_FEATURE.md (tutorial)
- docs/DEPLOY_ANDROID.md (how-to)
- docs/ASSET_GENERATION.md (how-to)
- docs/ARCHITECTURE.md (reference)
- docs/PROJECT_STRUCTURE.md (reference)
- docs/SERVICES_API.md (reference)
- docs/DECISIONS_LOG.md (explanation)
- docs/RIVERPOD_PATTERNS.md (explanation)

---
## Mallar/checklistor för varje Diátaxis-typ

### Tutorial ("Kom igång")
**Syfte:** Lär genom att göra, första gången

**Mall:**
---
Diátaxis-typ: Tutorial

# [Titel]

1. Steg 1: ...
2. Steg 2: ...
3. ...

Tips: Håll det linjärt, inga sidospår, visa resultat efter varje steg. Ingen bakgrund eller teori.
---

### How-to guide ("Så gör du X")
**Syfte:** Lös ett specifikt problem, snabbt

**Mall:**
---
Diátaxis-typ: How-to guide

# [Hur du ...]

Problem: [Kort beskrivning]

Steg:
1. ...
2. ...

Tips: Kort, direkt, inga förklaringar – bara lösning. Länka till tutorial eller explanation vid behov.
---

### Reference ("Fakta/API")
**Syfte:** Fakta, API, konfiguration, uppslagsverk

**Mall:**
---
Diátaxis-typ: Reference

# [API/Struktur/Config]

- [Fält/metod/parameter]: Beskrivning
- ...

Tips: Ingen vägledning, inga exempel, bara fakta. Länka till how-to eller tutorial för användningsexempel.
---

### Explanation ("Varför/förståelse")
**Syfte:** Förklara bakgrund, design, resonemang

**Mall:**
---
Diátaxis-typ: Explanation

# [Varför ...]

Bakgrund:
- ...

Designval:
- ...

Tips: Ingen instruktion, inga steg, bara kontext och resonemang. Länka till reference eller how-to för detaljer.
---

