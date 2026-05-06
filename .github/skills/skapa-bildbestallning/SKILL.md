---
name: skapa-bildbestallning
description: 'Generate a repo-specific illustrator brief and AI image prompts for missing assets. Use when UI art is missing, placeholders exist, or the user asks for an asset brief or image prompts.'
argument-hint: 'Beskriv vilken vy, ikon eller scen som saknar grafik.'
---

# Skapa bildbeställning

## Syfte
Den här skillen identifierar saknade eller svaga UI-assets i befintlig kod och genererar en kort beställningsbrief för illustratör samt engelska AI-prompter när användaren vill iterera bilder med externa verktyg.

## Arbetsflöde
1. Analysera relevant UI-kod i `lib/features/` och kontrollera att behovet gäller redan byggd funktionalitet, inte framtida roadmap-idéer.
2. Sök i `assets/` och `artifacts/` efter befintliga filer innan du föreslår något nytt.
3. Skapa en illustratörsbrief i två delar:
   - **Globala krav:** platt 2D-stil, barnvänlig form, tydliga siluetter, inga gradients eller 3D-effekter, och leverans som transparent PNG eller annat format som enkelt kan exporteras till transparent PNG för repoets PNG-first-runtime.
   - **Asset-lista:** Markdown-tabell med `| Föreslaget filnamn | Kategori | Target size i UI | Plats och syfte | Beskrivning |`.
4. Generera engelska AI-prompter för ChatGPT/Copilot. Inled med: `CRITICAL INSTRUCTION: Do not rewrite this prompt. Use it EXACTLY as written.`
5. Promptarna ska vara COPPA-säkra: inga fotorealistiska ansikten, inga verkliga personer, inga texter eller bakgrundsscener om de inte uttryckligen behövs.
6. **Automatiskt utförande (när du ges tillåtelse):**
   - **Steg 1 (Skapa):** Öppna `https://copilot.microsoft.com/` med browser-verktyget, fyll i prompten och skicka. Använd därefter en `run_playwright_code`-polling-loop med `deferredResultId` för att invänta en sparad bild (url med `th/id/` eller `OIG`).
   - **Steg 2 (Spara Original):** Använd terminalen (`Invoke-WebRequest`) för att spara url:en till `_incoming/<filnamn>.png`.
   - **Steg 3 (Frilägg via API):** Använd `curl.exe` i terminalen för att anropa Remove.bg API helt i bakgrunden: `curl.exe -H "X-Api-Key: <NYCKEL>" -F "image_file=@_incoming\<filnamn>.png" -F "size=auto" -o "_incoming\<filnamn>_nobg.png" https://api.remove.bg/v1.0/removebg`. Be användaren tillhandahålla nyckeln om du inte redan har den i minnet.
   - **Steg 4 (Klart):** Kontrollera att `_nobg.png`-filen skapades felfritt i `_incoming/`.
   - **Steg 5 (Integrering):** När användaren ber dig implementera bilderna från `_incoming/`, ska du **alltid kopiera** filerna (t.ex. med `Copy-Item`) till rätt plats i `assets/` istället för att flytta (`Move-Item`), så att originalen bevaras.
7. Svara kort på svenska och meddela därefter att filerna ligger klara i `_incoming`.
