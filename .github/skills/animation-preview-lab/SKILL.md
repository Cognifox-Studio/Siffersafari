---
name: animation-preview-lab
description: 'Refine animation previews for characters in inline SVG or HTML preview labs. Use when working on idle, walk, pivot, wave, T-pose, clean preview, motion-lab tuning, articulation, stable lower body, or when files live under artifacts/animation_preview.'
argument-hint: 'Describe the preview file, motion to refine, and what currently looks wrong.'
---

# Animation Preview Lab

## När den ska användas
- När en HTML/SVG-preview används för att hitta rätt timing, amplitud och ledmappning.
- När användaren vill förbättra idle, walk, wave, pivot eller T-pose innan Rive-arbete.
- När rörelsen känns stel, trasig, docklik eller tekniskt felmappad.

## Mål
Ta fram en ren, läsbar preview där rörelsen känns avsiktlig och går att översätta till animation-spec eller Rive-rigg.

## Arbetsflöde
1. Identifiera preview-läge och vilket rörelseproblem som ska lösas.
2. Håll previewn isolerad och läsbar.
   - Inline SVG är standard för dessa labs.
   - Separera preview-lägen via body-klass eller tydliga state-klasser.
3. Justera rörelsen i denna ordning:
   - helkroppsrytm
   - pelvis/chest/neck/head-kedja
   - armar och handled
   - ben/fot/toe endast om rörelsen kräver det
4. Prioritera läsbar motion framför fler keyframes.
5. Behåll stabil underkropp om målet är en ren överkroppsgest som vinkning eller reaktion.
6. När previewn fungerar: sammanfatta vilka vinklar, offsets och timingvärden som bör föras över till animation spec eller Rive.

## Kvalitetsgränser
- Lägg inte till komplexitet bara för att “rädda” en svag pose. Förenkla hellre.
- Om en preview känns riggad docka: minska segmentkänslan och använd större, mjukare formrörelser.
- Särskilj motion-lab från final integration. Previewn får vara ett labb, men den ska ge tydliga överförbara beslut.
- Säkerställ att previewn fortfarande fungerar på mobil bredd om den ska granskas i browsern.

## Typiska outputs
- förbättrad `artifacts/animation_preview/.../index.html`
- uppdaterade keyframes och transform-origins
- kort lista över godkända rörelsevärden att föra vidare