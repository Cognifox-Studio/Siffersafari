---
name: bryt-ut-delade-visuella-komponenter
description: 'Move or extract Flutter UI components into feature-first locations or shared widgets without breaking ownership, imports or tests. Use when refactoring UI out of legacy lib/presentation or splitting large screens.'
argument-hint: 'Ange vilken widget eller skärm som ska flyttas och den exakta platsen där den ska flyttas baserat på funktionalitet och användningsområde.'
---

# Bryt ut delade visuella komponenter

Använd skillen när UI behöver flyttas från legacy-struktur till feature-first eller när en stor skärm ska delas upp i mindre widgets.

## Arbetsflöde
1. Bestäm först ägare: featureägd UI hör hemma under `lib/features/<feature>/presentation/...`, medan verkligt delad UI hör hemma i `lib/presentation/widgets/`.
2. Flytta sedan filen till den valda platsen.
3. Uppdatera därefter imports och sök efter gamla fil- eller klassnamn i hela repo:t.
4. Städa sedan upp UI-sidoeffekter enligt `.github/instructions/regler-for-att-uppdatera-information-pa-skarmen.instructions.md` och `.github/instructions/regler-for-hur-skarmar-och-knappar-ska-se-ut.instructions.md`.
5. Kör `dart fix --apply` vid behov.
6. Verifiera sist med `flutter analyze` och relevanta widget- eller integrationstester.