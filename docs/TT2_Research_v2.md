# TT2 Research v2
## Praktisk, gratis och Flutter-native asset-pipeline med minimum effort

---

## Syfte

Detta dokument ersätter inte [TT2_Research.md](d:\Projects\Personal\Multiplikation\docs\TT2_Research.md), utan fungerar som en v2-riktning: en mer praktisk, repo-anpassad och Flutter-fokuserad tolkning av samma problem.

Målet är inte att beskriva alla möjliga 2D-pipelines. Målet är att definiera den enklaste pipeline som kan ge många användbara assets med så lite manuellt arbete som möjligt.

Kärnkrav:

- Gratis verktyg.
- Minimum effort från dig.
- Hög automation.
- Egna/original assets.
- Bra stöd för 2D-karaktärer, UI-effekter, sprites och enklare animationer.
- Flutter som enda runtime.

---

## Sammanfattning

Den viktigaste förbättringen jämfört med v1 är att pipelinen måste sluta vara verktygscentrerad och i stället bli spec-driven och Flutter-native.

Den rekommenderade målbilden är:

- `YAML specs -> Python pipeline -> befintliga Dart-generatorer -> Rive/Lottie/spritesheets -> Dart codegen -> Flutter`

Det innebär i praktiken:

- Du underhåller textspecar i stället för att klicka runt i flera editorer.
- Du gör mastermallar en gång.
- Du använder editorer bara för undantag, kvalitetshöjning och master-setup.
- Nya assets skapas främst genom att lägga till eller ändra poster i specs.

---

## Vad som är svagt i originaldokumentet

Originalet är användbart som bred research, men för generellt för ett Flutter-projekt som redan har generatorer för SVG-delar, Lottie-effekter och Rive-blueprints.

### För generellt

- Godot får för stor plats trots att runtime är Flutter.
- Blender beskrivs som central trots att 2D-fokus och low-effort gör den för tung i normalfallet.
- DragonBones behandlas som ett realistiskt val trots svag Flutter-anpassning.
- Komprimering, mesh deformation och flera motorrelaterade sidospår är överrepresenterade jämfört med det verkliga behovet.

### För tungt

- Blender -> Godot -> importer -> atlas -> komprimering är för många steg.
- Basis/KTX2 ger extra komplexitet utan tydlig payoff för vanlig Flutter-2D.
- Mesh- och skinningfokus är onödigt för majoriteten av de assets detta repo verkar behöva.

### Felprioriterat för minimum effort

- Dokumentet prioriterar verktyg och möjligheter mer än driftbar automation.
- Det saknas en tydlig uppdelning mellan vad som ska vara manuellt, halvautomatiskt och helt automatiskt.
- Det saknas en konkret målarkitektur för hur detta ska landa i Flutter-kod och repo-struktur.

---

## Hårdare verktygsbeslut

Följande är den rekommenderade sorteringen om målet verkligen är gratis och minimum effort.

| Verktyg | Status | Motivering |
|---|---|---|
| Inkscape | KEEP | Bästa gratis vektorbasen för SVG-delar, ikoner och karaktärsmallar. |
| Krita | KEEP | Bra för paintovers, bakgrunder och rastertouchups. |
| Free Texture Packer | KEEP | Enkel och användbar för automatiska spritesheets. |
| Python | KEEP | Bra orkestreringslager för specs, generators och manifest. |
| Dart codegen | KEEP | Ger typed asset-access i Flutter och minskar handskriven boilerplate. |
| Rive | KEEP | Gratis att komma igång med, stark Flutter-integration, bra för riggade karaktärer. |
| Lottie | KEEP | Passar UI-effekter och enklare tidslinjebaserad animation väl. |
| Flame | OPTIONAL | Bra för spriteanimationer och FX, men inte nödvändigt om ren Flutter räcker. |
| DragonBones | DROP | För svag Flutter-story, extra friktion och dubbla arbetsmodeller. |
| Blender | DROP | Overkill för denna pipeline om målet är låg manuell insats. |
| Godot | DROP | Fel runtime och onödig mellanmotor. |
| Basis / basisu | DROP | För hög komplexitet i relation till nyttan för vanlig Flutter-2D. |

Notering:

- `Rive` är gratis att använda som verktyg i den här riktningen, men inte open source. Om kravet senare blir strikt FOSS i varje led behöver riggade karaktärer antingen förenklas till spritesheets eller flyttas till en annan kompromisslösning.

---

## Rekommenderad målstack

Det här är den exakta målstacken för v2.

### Skapa originalart

- Inkscape för vektorbaserade karaktärsdelar, UI-komponenter, rekvisita och FX-shapes.
- Krita för bakgrunder, texturer, paintovers och enstaka hero-finishar.

### Generera och bygga assets

- YAML som källa för variationsdata och exportregler.
- Python som orchestration-lager.
- Befintliga Dart-generatorer för att skapa eller uppdatera konkreta outputs.

### Animation och runtime-format

- Rive för riggade karaktärer och state machines.
- Lottie för UI-effekter.
- Spritesheets för massproducerade FX, projektiler och enklare mob-animationsfall.

### Flutter-integration

- Flutter + `rive` för karaktärer.
- Flutter + `lottie` för UI- och feedback-animationer.
- Flutter eller optional `flame` för spritesheets.
- Dart codegen för typed asset-API.

---

## Vad som redan finns i repot i dag

Följande delar finns redan och bör användas som bas, inte ersättas:

- [generate_mascot_svg_parts.dart](d:\Projects\Personal\Multiplikation\scripts\generate_mascot_svg_parts.dart)
- [generate_lottie_effects.dart](d:\Projects\Personal\Multiplikation\scripts\generate_lottie_effects.dart)
- [generate_rive_blueprint.dart](d:\Projects\Personal\Multiplikation\scripts\generate_rive_blueprint.dart)
- [generate_mascot_composite.dart](d:\Projects\Personal\Multiplikation\scripts\generate_mascot_composite.dart)
- [pipeline.py](d:\Projects\Personal\Multiplikation\tools\pipeline.py)
- [assets.g.dart](d:\Projects\Personal\Multiplikation\lib\gen\assets.g.dart)
- [characters.yaml](d:\Projects\Personal\Multiplikation\specs\characters.yaml)
- [ui_effects.yaml](d:\Projects\Personal\Multiplikation\specs\ui_effects.yaml)

Det finns också redan en taskkedja för assetgenerering i workspace-konfigurationen:

- `Assets: Generate All (SVG + Lottie + Rive Blueprint)`

Det betyder att v2 inte ska börja om från noll. Den ska lägga ett spec- och orchestrationslager ovanpå det som redan finns.

Nuvarande runtime-status for maskoten i appen:

- interaktiva ytor kor `Rive` via `MascotCharacter`
- passiva mascotytor kor `Rive -> SVG fallback`
- `Lottie` ar reserverat for godkanda UI-effekter, inte for theme-specifika mascot-statefiler

---

## Den viktigaste arkitekturändringen

I stället för att tänka:

- "Vilket verktyg ska jag öppna nu?"

ska pipelinen tänka:

- "Vilken spec har ändrats, och vilka outputs ska genereras från den?"

Detta är kärnan i low-effort-varianten.

### Målflöde

1. Du ändrar en spec.
2. Ett pipeline-script läser specen.
3. Scriptet anropar generatorer.
4. Scriptet bygger manifest och typed access.
5. Flutter använder endast färdiga filer och genererad kod.

---

## Ultimate Low-Effort Pipeline

Den föreslagna v2-pipelinen är:

### Nivå 1: Master templates

Du bygger ett litet antal stabila grundmallar:

- En masterstilguide.
- En masterkaraktärsmall i SVG.
- En eller två master-riggar i Rive.
- Ett UI-komponentbibliotek.
- Några standardmallar för FX.

Detta är engångsarbetet som gör resten billigt.

### Nivå 2: Specs

Du beskriver variationer och assets i YAML:

- vilken del som används
- vilka färgteman som används
- vilka animationer som ska finnas
- vilket exportformat som behövs
- om asseten ska bli Rive, Lottie, spritesheet eller statisk fallback

### Nivå 3: Generatorer

Pipeline-scriptet orkestrerar befintliga och nya generatorer:

- SVG-delgeneratorer
- sammanslagning av delar
- Rive-blueprint-generering
- Lottie-generering
- spritesheet-packning
- asset-manifest
- Dart-codegen

### Nivå 4: Flutter

Appen konsumerar bara:

- `.riv`
- `.json` för Lottie
- spritesheets + metadata
- genererad Dart-kod

---

## Rekommenderad katalogstruktur

Det här är den rekommenderade målstrukturen. Det är en föreslagen struktur, inte en beskrivning av att allt redan finns.

```text
assets/
  characters/
    <slug>/
      config/
      svg/
      rive/
      sprites/
  ui/
    lottie/
    icons/
  effects/
    sprites/
  backgrounds/

artifacts/
  previews/
  blueprints/
  review/

specs/
  characters.yaml
  ui_effects.yaml
  effects.yaml
  backgrounds.yaml
  palettes.yaml
  rigs.yaml

templates/
  characters/
  ui/
  fx/

tools/
  pipeline.py
  manifest_builder.py
  validators/

lib/
  gen/
    assets.g.dart
```

### Praktisk tolkning för detta repo

- `assets/` fortsätter vara platsen för godkända runtime-assets.
- `artifacts/` fortsätter vara platsen för previews, blueprints och reviewmaterial.
- `specs/` bör bli ny källa för variationer och styrning.
- `templates/` bör samla de få manuellt skapade grundmallarna.
- `tools/` bör innehålla orchestration, validering och manifestbygge.

---

## Rekommenderad spec-struktur

Det viktiga är inte exakt YAML-dialekt, utan att varje specpost är liten, stabil och lätt att generera från.

### Exempel: characters.yaml

```yaml
characters:
  - id: forest_guard_01
    rig: humanoid_small
    template: humanoid_base_v1
    layers:
      head: heads/guard_round_01.svg
      torso: torsos/leather_guard_01.svg
      weapon: weapons/spear_01.svg
      accessory: accessories/cape_green_01.svg
    palette: forest_day
    animations: [idle, attack, hit, celebrate]
    export:
      rive: true
      spritesheet: false
      static_fallback: true
```

### Exempel: ui_effects.yaml

```yaml
effects:
  - id: primary_button_press
    type: lottie
    target: primary_button
    duration_ms: 150
    keyframes:
      - property: scale
        from: 1.0
        to: 0.92
        easing: easeOutBack
      - property: glow_opacity
        from: 0.0
        to: 1.0
        easing: easeOut
```

### Exempel: effects.yaml

```yaml
effects:
  - id: dust_puff_small
    type: spritesheet
    template: fx/dust_puff.svg
    frames: 10
    size: 256
    atlas: combat_fx_small
```

### Exempel: rigs.yaml

```yaml
rigs:
  - id: humanoid_small
    rive_template: templates/characters/humanoid_small.riv
    slots: [head, torso, weapon, accessory]
    animations: [idle, attack, hit, celebrate]
```

---

## One-command build

Den viktigaste förbättringen från ett produktionsperspektiv är att allt ska kunna köras från ett enda kommando.

### Föreslaget målkommando

```bash
python tools/pipeline.py build-all
```

### Vad det kommandot ska göra

1. Läsa alla specs.
2. Validera referenser mot mallar, SVG-delar och riggar.
3. Köra befintliga Dart-generatorer för SVG, Lottie och Rive-blueprints.
4. Generera eventuella sammansatta SVG-varianter.
5. Bygga spritesheets när en spec kräver det.
6. Skriva eller uppdatera ett asset-manifest.
7. Generera `assets.g.dart` eller motsvarande typed helper-fil.
8. Misslyckas tidigt om specen är trasig.

### Vad som är viktigt här

- Det här kommandot är en målbild. Det finns inte som färdig implementation i repot i dag.
- I dagens läge finns redan separata genereringssteg. V2 ska samla dem under en orchestrator i stället för att ersätta dem.

---

## Vad som ska vara manuellt, halvautomatiskt och helt automatiskt

Den här uppdelningen är central. Den saknas i praktiskt användbar form i v1.

### Manuellt en gång

- Definiera stilguide.
- Skapa masterkaraktärsmall i Inkscape.
- Skapa 1-2 master-riggar i Rive.
- Skapa grundbibliotek för UI-komponenter.
- Skapa några återanvändbara FX-mallar.
- Definiera YAML-format och valideringsregler.
- Sätta upp pipeline-orchestrator och codegen.

Detta är den dyra delen. Den ska göras få gånger och sedan skyddas från drift.

### Halvautomatiskt ibland

- Finjustera hero-karaktärer som behöver högre konstnärlig kvalitet.
- Förbättra master-riggen när nya karaktärstyper kräver det.
- Justera Lottie- eller Rive-output när en generator når gränsen för vad som ser bra ut.
- Lägga till nya templates när en ny familj av assets uppstår.

Detta ska ske undantagsvis, inte som normalflöde.

### Helt automatiskt varje gång

- Läsa specs.
- Generera variationer från delar och paletter.
- Exportera SVG-output.
- Skapa eller uppdatera Lottie-filer.
- Skapa eller uppdatera Rive-blueprints.
- Packa spritesheets.
- Bygga manifest.
- Generera typed Dart-access.
- Validera att alla outputs och referenser finns.

---

## Hur man undviker handarbete när många nya assets behövs snabbt

Det här är den verkliga kärnan i ett low-effort-system.

### 1. Spec-driven allt

Nya assets ska i första hand vara nya poster i YAML, inte nya manuella arbetsflöden.

### 2. Parametriska delar

SVG-generatorerna bör tänka i familjer:

- huvudformer
- kroppstyper
- plagg
- tillbehör
- vapen
- färgteman

När dessa delar väl finns kan många kombinationer produceras utan nytt handarbete.

### 3. Små riggfamiljer i stället för rigg per karaktär

Målet ska vara få stabila riggar:

- `humanoid_small`
- `humanoid_large`
- eventuellt `creature_simple`

Varje ny asset ska försöka mappas till en befintlig riggfamilj innan ny rigg skapas.

### 4. Hero vs bulk

Pipelinen ska skilja på:

- hero-assets: halvautomatiska, mer finputs
- bulk-assets: full automation, lägre manuell finish

Denna gräns sparar mycket tid.

### 5. AI som text- och variationshjälp, inte som produktionslåsning

AI kan användas för:

- idéer
- palettförslag
- namngivning
- generering av specposter
- batching av variationer

AI ska inte vara ett obligatoriskt runtime- eller buildkrav.

---

## Rekommenderad Flutter-strategi

För att hålla systemet enkelt bör runtime delas upp så här:

### Karaktärer

- Primärt: Rive.
- Fallback: statisk SVG/PNG eller sammanslagen statisk variant.

### UI-effekter

- Primärt: Lottie.

### Gameplay-FX

- Primärt: spritesheets.
- Optional: Rive om en effekt verkligen tjänar på parametrisk styrning.

### Kodnivå

- Flutter ska konsumera typed asset-helpers i stället för hårdkodade paths.
- Generatorer ska producera en stabil API-yta för assets så att featurekod inte behöver känna till filstrukturen.

---

## Vad som bör tas bort eller tonas ned från originaldokumentet

Följande delar bör antingen tas bort helt eller tonas ned kraftigt i en verklig v2.

### Ta bort helt

- Godot som central del av pipelinen.
- GDScript som rekommenderad automationsväg.
- DragonBones som primär rigg- eller runtimeväg.
- Blender som standardrekommendation.
- Basis/KTX2 som generellt krav.

### Tona ned kraftigt

- Mesh deformation, skinning och viktning.
- 2.5D-resonemang.
- generella indie-exempel som inte leder till beslut för detta repo.
- breda community-listor utan direkt pipelinevärde.

### Behåll men skriv om

- Inkscape och Krita ska beskrivas som källor till master assets, inte som löpande manuella flaskhalsar.
- Atlas/spritesheet-packning ska beskrivas som ett automatiserat steg, inte ett separat manuellt verktygsval.
- AI-stöd ska beskrivas som hjälp för idéer och specs, inte som huvudproducent av slutassets.

---

## Förslag på struktur för TT2_Research_v2

En bättre dokumentstruktur är:

```text
1. Mål och principer
2. Problem med v1
3. KEEP / OPTIONAL / DROP
4. Målarkitektur för Flutter
5. Existerande generatorer i repot
6. Master templates
7. Spec-format
8. One-command pipeline
9. Automationsnivåer
10. Flutter-integration
11. Vad som tas bort eller tonas ned från v1
12. Rekommenderad genomförandeordning
```

---

## Rekommenderad genomförandeordning

Det här är den praktiska ordningen för att närma sig målbilden utan att göra för mycket samtidigt.

1. Behåll nuvarande generatorer som bas.
2. Inför `specs/` med ett litet första format för karaktärer och UI-effekter.
3. Skapa `tools/pipeline.py` som bara orkestrerar redan befintliga steg.
4. Lägg till manifestbyggare och enkel typed Dart-access.
5. Standardisera 1 master-rigg och 1 masterkaraktärsmall.
6. Lägg till spritesheet-generering för bulk-FX.
7. Utöka antalet variationer först när pipelineflödet är stabilt.

Det viktiga är att börja med orchestrering och specs, inte med nya verktyg.

---

## Slutsats

Den bästa förbättringen av originaldokumentet är inte fler verktyg, utan färre beslut och tydligare ansvar i varje led.

För detta repo är den starkaste riktningen:

- Flutter som enda runtime.
- Rive för riggade karaktärer.
- Lottie för UI-effekter.
- Spritesheets för bulk-FX.
- Inkscape och Krita som källor till masterart.
- YAML specs som primär arbetsyta.
- Python som orchestrator.
- Dart codegen som sista lager före appen.

Detta är den gratis och mest low-effort-vänliga versionen av en TT2-inspirerad pipeline som samtidigt passar repoets nuvarande generatorer och struktur.