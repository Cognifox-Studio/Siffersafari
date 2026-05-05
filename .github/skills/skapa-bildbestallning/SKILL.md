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
6. Svara kort på svenska och föreslå bara assets som faktiskt saknas.
