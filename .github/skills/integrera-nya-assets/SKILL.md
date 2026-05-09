---
name: integrera-nya-assets
description: 'Integrates new graphical assets from _incoming/ into the active app assets/ folder safely. Use when creating, importing, or finalizing new UI images, characters, or icons.'
argument-hint: 'Vilka filer i _incoming/ ska integreras, och var ska de i assets/?'
---

# Integrera nya assets

## Syfte
Säkerställa en konsekvent och säker hantering när grafiska assets flyttas från temporär inläsning i `_incoming/` till appens slutgiltiga miljö i `assets/`, enlighet med Siffersafaris repo-regler.

## Regler och Arbetsflöde
1. **Döp om först i _incoming:** Innan något flyttas, byt alltid namn på filerna direkt i `_incoming/` så att de följer projektets namnstandard (snake_case, beskrivande namn).
2. **Kopiera, flytta inte:** Använd alltid `Copy-Item` (eller närliggande filverktyg för kopiering) när bilder förs över från `_incoming/` till `assets/`. `Move-Item` är förbjudet. Detta bevarar originalen (och eventuella icke-frilagda varianter) i `_incoming/` som en säkerhetskopia för referens.
3. **Ignorera `_incoming/` i UI:** Filerna i `_incoming/` får inte refereras i `pubspec.yaml` eller användas direkt i UI-kod. Mappen är endast en lokal inkorg.
4. **Placering i assets:** Placera kopian i rätt undermapp i `assets/` (t.ex. `assets/characters/`, `assets/images/`, `assets/icons/`).
5. **Uppdatera referenser:** Uppdatera existerande konstanter i kodbasen (tänk `AppAssets` eller liknande) och `pubspec.yaml` (om mappen inte redan läses in med wildcard) så att koden är redo att nå den nya pathen i `assets/`.
6. **Kommunicera plattformsbehov vid omstart:** Informera användaren om att Flutter Web kräver en fullständig omstart från terminalen för att hitta nya bildfiler (Hot Restart räcker ej, resultatet är 404). Android/Pixel_6 släpar också ibland och löses bäst genom att Sync-tasken i projektet körs.

## Utförande
- Kör filkopieringen med `default_api:run_in_terminal` eller copilot API.
- Svara kort, på svenska, vad som kopierades och vart.
- Avsluta med att rekommendera en full omstart/sync för rätt runtime (Flutter Web eller Pixel 6).