---
name: kolla-om-appen-ar-redo-att-slappas
description: 'Prepare and verify this repo for demo, handoff or release. Use when the user asks for release check, readiness, ship, preflight, tag, APK verification, final QA or a last pass over assets, tests, Pixel_6, docs and version consistency.'
argument-hint: 'Beskriv om detta gäller demo, intern överlämning eller skarp releasekandidat.'
---

# Kolla om appen är redo att släppas

## När den ska användas
- Innan taggning eller GitHub Release.
- Inför demo eller extern överlämning.
- När flera typer av ändringar landat samtidigt: kod, assets, docs och Android-build.

## Mål
Ge en kort, defensibel go/no-go-bedömning utan att missa vanliga releasefällor.

## Arbetsflöde
1. Kontrollera om assets, animationer eller Android-beteende har ändrats.
2. Kör lämplig QA-nivå via `.github/skills/testa-att-appen-fungerar/SKILL.md`.
3. Om devicebeteende är relevant: kör Pixel_6 sync/install/run enligt befintliga tasks.
4. Kontrollera versionsreferenser, release notes och andra releaserelaterade artefakter.
5. Sammanfatta blockerare, risker och rekommenderat nästa steg.

## Go/No-Go-regler
- `No-go` om analyze fallerar i releaserelevant kod.
- `No-go` om kritiska tester fallerar och orsaken inte redan är känd och accepterad.
- `No-go` om appen inte går att verifiera på avsedd Android-target när ändringen kräver det.
- `Soft go` kan ges om bara lågprioriterade docs eller polishpunkter återstår.