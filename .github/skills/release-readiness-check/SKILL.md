---
name: release-readiness-check
description: 'Prepare and verify this repo for demo, handoff, or release. Use when the user asks release check, readiness, ship, preflight, tag, APK verification, final QA, or wants a last pass over assets, tests, Pixel_6 install, docs, and version consistency.'
argument-hint: 'Describe whether this is a demo build, internal handoff, or real release candidate.'
---

# Release Readiness Check

## När den ska användas
- Innan taggning eller GitHub Release.
- Inför demo eller extern överlämning.
- När flera typer av ändringar landat samtidigt: kod, assets, docs och Android-build.

## Mål
Ge en kort, defensibel go/no-go-bedömning för repo:t utan att missa de vanligaste release-fällorna.

## Arbetsflöde
1. Kolla om assets eller animation specs har ändrats.
   - Vid behov: kör asset-generering innan QA.
2. Kör lämplig QA-nivå.
   - minst analyze
   - full testsvit vid större ändringar
3. Om Android-beteende är relevant:
   - kör Pixel_6 sync/install/run enligt befintliga tasks
4. Kontrollera att dokumentation/release artifacts är rimliga.
   - versionsreferenser
   - release notes eller artifacts vid behov
   - inga uppenbart bortglömda genererade filer
5. Sammanfatta:
   - blockerare
   - risker
   - rekommenderat nästa steg

## Go/No-Go-regler
- `No-go` om analyze fallerar i releaserelevant kod.
- `No-go` om kritiska tester fallerar och orsaken inte är känd sedan tidigare.
- `No-go` om appen inte går att verifiera på avsedd Android-target när ändringen kräver det.
- `Soft go` kan ges om bara lågprioriterade docs eller icke-kritiska polishpunkter återstår.

## När skillen ska kombineras
- Använd `asset-generation-runner` om release innehåller nya genererade assets.
- Använd `flutter-qa-guard` för fokuserad eller full QA-körning.