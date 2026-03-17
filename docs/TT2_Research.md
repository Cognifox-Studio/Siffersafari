# Game Hive’s Titan Asset and Animation Pipeline in Tap Titans 2  
## A Detailed Open Source Workflow Analysis

---

## Inledning

Tap Titans 2, utvecklat av det kanadensiska företaget Game Hive, är ett av de mest framgångsrika mobilspelen inom idle/clicker-genren. Spelets framgång vilar inte bara på dess engagerande mekanik, utan också på dess distinkta och polerade visuella stil – särskilt de ikoniska titanerna som utgör spelets huvudsakliga motståndare. Denna rapport syftar till att ge en tekniskt detaljerad och praktiskt användbar genomlysning av hur Game Hive kan ha skapat sina titan-assets och animationer, med särskilt fokus på hur en liknande pipeline kan återskapas med enbart gratis och open source-verktyg. Rapporten riktar sig till utvecklare och kreatörer som vill inspireras av eller återskapa ett liknande arbetsflöde, särskilt inom ramen för vibe coding och kreativa kodningsmiljöer.

---

## 1. Game Hive och Tap Titans 2 – Företags- och Teknisk Översikt

Game Hive är en Toronto-baserad spelstudio med fokus på mobilspel, där Tap Titans-serien är deras mest kända varumärke. Tap Titans 2 har kontinuerligt uppdaterats sedan lanseringen och har en stor, aktiv community. Spelet är känt för sitt snabba gameplay, progression genom stages, och ett rikt system av utrustning, hjältar och framför allt – titan-fiender.

Tekniskt sett är Tap Titans 2 utvecklat för mobilplattformar (iOS och Android) och använder en 2D-grafikmotor. Även om den exakta motorn inte är officiellt bekräftad, är det troligt att den bygger på Unity, vilket är vanligt för mobilspel av denna typ. Spelet använder sig av sprites, texture-atlases och skelettbaserad animation för att skapa sina karaktärer och effekter.

---

## 2. Visuell Stil och Titan-Design i Tap Titans 2

Tap Titans 2:s visuella identitet kännetecknas av färgstarka, stiliserade och lättlästa karaktärer. Titanerna är ofta överdrivna i proportioner, med tydliga siluetter och distinkta färgpaletter. Bakgrunder och miljöer är målade i en semi-realistisk stil, medan titanerna och hjältarna har en mer cartoon-liknande estetik.

Denna stil lämpar sig väl för vektorbaserad grafik och skelettanimation, eftersom formerna är tydliga och animationerna ofta bygger på stora, svepande rörelser snarare än detaljerad frame-by-frame-animation. Detta möjliggör effektiv assetproduktion och optimering för mobila enheter.

---

## 3. Typiska Asset-Typer i Tap Titans 2

För att förstå pipeline-kraven är det viktigt att identifiera de vanligaste asset-typerna i spelet:

- **Sprites**: Individuella bilder för karaktärsdelar, effekter och UI.  
- **Rigs/Skelett**: Benstrukturer för skelettanimation av titanerna.  
- **Meshes**: Polygonala nät för mesh-deformation och skinning.  
- **VFX**: Partikelsystem och specialeffekter (t.ex. explosioner, magi).  
- **Texture Atlases**: Samlade sprites i en eller flera texturatlasser för att minimera draw calls.  
- **UI-assets**: Ikoner, knappar och overlays.

Varje asset-typ kräver olika verktyg och exportformat, men de flesta kan hanteras inom en pipeline som bygger på fria och open source-verktyg.

---

## 4. Verktyg Game Hive Kan Ha Använt – och Fria/Open Source-Alternativ

Det finns inga officiella uttalanden om exakt vilka verktyg Game Hive använder, men baserat på industristandard och community-resurser är det sannolikt att deras pipeline inkluderar:

- Adobe Photoshop/Illustrator  
- Spine eller DragonBones  
- TexturePacker  
- Unity  

För en pipeline som uteslutande bygger på fria och open source-verktyg finns det dock starka alternativ:

| Pipelinesteg | Kommersiellt verktyg | Gratis/Open Source-alternativ |
|--------------|----------------------|-------------------------------|
| Vektorgrafik | Adobe Illustrator | Inkscape |
| Rastergrafik | Adobe Photoshop | Krita, GIMP, Piskel |
| 2D-animation/rigg | Spine, DragonBones | DragonBones, SkelForm, Blender (Grease Pencil) |
| Sprite sheet/atlas | TexturePacker | Free Texture Packer, ShoeBox, Sprite Sheet Packer |
| Spelmotor | Unity | Godot |
| VFX/partiklar | After Effects | Godot Particle Editor, Blender |
| Automatisering | Photoshop Scripts | Python, GDScript, Node.js |

---

## 5. Vektorbaserad Pipeline med Inkscape och SVG

Inkscape är ett kraftfullt open source-verktyg för vektorgrafik och lämpar sig utmärkt för att skapa titanernas olika kroppsdelar och rekvisita.

### Fördelar:

- Skalbarhet  
- Enkla justeringar  
- Batch-export via CLI  

### Pipeline-exempel:

1. Skapa varje kroppsdel som separata grupper/lager.  
2. Exportera varje del som PNG via batch-export.  
3. Alternativt exportera hela figuren som SVG för vidare bearbetning.

---

## 6. Rasterverktyg för Målning och Frame-by-Frame

Rasterbaserade verktyg:

- **Krita** – målning, frame-by-frame, spritesheet-export  
- **GIMP** – batch-export, Python-skript  
- **Piskel** – pixelart och enklare animationer  

---

## 7. 2D-skelettanimation: DragonBones och Alternativ

### DragonBones – Funktioner:

- Bone-rigging  
- Mesh-deformation  
- IK  
- Atlas-export  
- JSON-format  

### Automatisering:

- CLI-verktyg för batch-export  
- Konvertering mellan format (Spine ↔ DragonBones)

### Alternativ:

- SkelForm  
- Blender (Grease Pencil + Armature)

---

## 8. Blender för 2D/2.5D-artwork

Blender erbjuder:

- Grease Pencil  
- Armature-riggning  
- PNG-sekvens-export  
- Python-automatisering  

Pipeline-exempel:

1. Importera SVG → Grease Pencil  
2. Rigg och animera  
3. Rendera PNG-sekvens  
4. Packa spritesheet med PixTract  

---

## 9. Godot 2D-pipeline

Godot erbjuder:

- Skeleton2D  
- MeshInstance2D  
- Atlasgenerering  
- DragonBones-plugin  
- Hot-reload  

---

## 10. Sprite Sheet Packers och Atlasverktyg

Gratisverktyg:

- Free Texture Packer  
- ShoeBox  
- PixTract  

Alla kan automatiseras via CLI.

---

## 11. Automatisering och Skript i Asset-pipelines

Exempel:

- Blender Python-skript  
- GIMP Script-Fu  
- Node.js JSON-konvertering  
- Godot GDScript för import-automation  

---

## 12. Mesh-deformation, Skinning och Viktning

Stöd i:

- DragonBones  
- Godot  
- Blender  

---

## 13. Exportformat och Runtime-integration

Vanliga format:

- JSON  
- PNG  
- Atlas-metadata  
- Godot .tres/.import  

---

## 14. Mobiloptimering

- Atlasstorlek 2048–4096  
- Minimera draw calls  
- Texturkomprimering (Basis/KTX2)  

---

## 15. Texture-komprimering

Basis Universal:

- Plattformskompatibelt  
- Snabb transcoding  
- CLI-stöd  

---

## 16. Exempel på Indie-pipelines

- Blender Studio (DOGWALK)  
- Inkscape → Blender → Godot pipelines  

---

## 17. Community-verktyg och Resurser

- TT2 Compendium  
- GitHub-projekt  
- Discord/Reddit  

---

## 18. Juridik och Upphovsrätt

All originalgrafik i Tap Titans 2 är upphovsrättsskyddad.  
Pipeline bör användas för **egna** assets.

---

## 19. Integration med Vibe Coding och VibeGame

Fördelar:

- Hot-reload  
- JSON-driven animation  
- Live-uppdatering  
- AI-assisterad iteration  

---

## 20. Live-verktyg och Hot-Reload

Stöd i:

- Godot  
- VibeGame  
- Blender  
- DragonBones  

---

## 21. Partiklar, VFX och UI-verktyg

Gratisverktyg:

- Godot Particle Editor  
- Blender  
- Krita flipbooks  

---

## 22. Jämförelsetabell: Open Source-verktyg

| Steg | Verktyg | Automatisering |
|------|---------|----------------|
| Vektorgrafik | Inkscape | CLI, Python |
| Rastergrafik | Krita, GIMP | Plugins, Script-Fu |
| Animation | DragonBones, Blender | CLI, Python |
| Atlas | Free Texture Packer | CLI |
| Motor | Godot | GDScript |
| VFX | Godot, Blender | Scripts |
| Komprimering | Basis | CLI |

---

## 23. Automatiserade Exempelprojekt

- Godot-DragonBones  
- DB-Reborn  
- BlenderSpriter  
- PixTract  
- Krita Spritesheet Exporter  
- GIMP Batch Export Script  

---

## 24. Rekommenderad Pipeline – Steg-för-steg

1. **Design** i Inkscape/Krita  
2. **Riggning** i DragonBones  
3. **Export** till JSON + PNG  
4. **Atlas** via Free Texture Packer  
5. **Import** i Godot  
6. **VFX** i Godot/Blender  
7. **Komprimering** via Basis  
8. **Automatisering** via Python/GDScript  

---

## 25. Anpassning för Vibe Coding

Pipeline är:

- Deklarativ  
- Modulär  
- Hot-reload-kompatibel  
- Automatiserbar  
- AI-vänlig  

---

## Slutsats

Det är fullt möjligt att återskapa eller inspireras av Game Hives arbetsflöde för titan-assets och animationer i Tap Titans 2 med en pipeline som uteslutande bygger på gratis och open source-verktyg. Genom att kombinera Inkscape, Krita, DragonBones, Blender, Free Texture Packer och Godot – samt automatisera med Python, GDScript och CLI-verktyg – kan du skapa en professionell, effektiv och mobiloptimerad asset-pipeline. Denna pipeline är dessutom idealisk för vibe coding och kreativa kodningsmiljöer, där snabb iteration, live-uppdatering och AI-assisterad utveckling står i centrum.

Viktig notering: All originalgrafik från Tap Titans 2 är upphovsrättsskyddad. Använd denna pipeline för att skapa egna assets, inte för att extrahera eller återanvända Game Hives material utan tillstånd.
