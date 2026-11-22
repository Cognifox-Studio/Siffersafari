<!--
typ: reference
syfte: Garderoben — nuläge, beslut och de bättre vägarna framåt
uppdaterad: 2026-11-22
-->

# Garderoben

> Beslut loggas i [DECISIONS_LOG.md](DECISIONS_LOG.md). Prioritering i stort: [ROI_BACKLOG.md](ROI_BACKLOG.md) #13.

## Nuläget (mätt, inte gissat)

| Sak | Fakta |
|---|---|
| Plagg | 17 i `InventoryConfig.allItems`, **11** syns i garderoben (`showInWardrobe`) |
| Slots | 8 fria strängar: `head`, `face`, `feet`, `body`, `accessory`, `front`, `camp`, `pet` — ingen enum |
| Position | `Alignment`, där **7 av 10** värden ligger utanför ±1 (t.ex. `Alignment(0, -2.8)`), samt `renderScale` 0.35–0.95 |
| Karaktärskorrigering | hårdkodad per karaktär och slot (`signe`: dy +0.35/×0.95, `astrid`: dx 0.15/dy 0.15/×1.05) |
| Offsetformat | **tre** generationer i samma map: `n,x,y,scale,rot`, `p,x,y,scale,rot` och ett äldre bart `dx,dy,scale,rot` där dx/dy tyst ignoreras |
| Equip-nyckel | `<pose>_<itemId>`, `idle_<itemId>` eller bart slotnamn — alla tre finns i riktiga profiler |
| Ett plagg kostar | asset + `allItems` + ev. karaktärskorrigering + `case 'item_x':` i hit-shape-switchen (krav från `wardrobe_hit_shape_audit_test`) |

## Beslutet: outfiten är per barn, inte per pose

`equippedItems` var nycklad per pose, och karaktären ritade bara nycklar som matchade *aktuell* pose. Posen `idle` är standard i garderoben, så en hatt sparades som `idle_item_safari_hat` och ritades aldrig när karaktären reagerade — vilket den gör i varje quiz.

**Löst:** `OutfitResolver` (`lib/domain/services/outfit_resolver.dart`). Basoutfiten ritas alltid; en pose-specifik nyckel *överrider* bara sin slot. Två plagg i samma slot ritas aldrig samtidigt, och pose-listan är en prioritetsordning (`['celebrate', 'answerCorrect']`).

Garderoben använder samma resolver, så en ruta är markerad exakt när barnet faktiskt ser plagget på karaktären.

## Steg 2 klart: posen är förhandsvisning

Poseknapparna (Vila / Fel / Rätt) ändrade *vilka kläder barnet ägde*, eftersom varje plaggyckel bars av en pose. En hatt som sattes på medan "Rätt" var vald hamnade som `answerCorrect_item_hat` och syntes bara när figuren svarade rätt.

Nu skriver garderoben alltid basoutfiten (`idle_<itemId>`), byter ut plagget i samma slot i stället för att stapla, och "av" tar bort plagget i alla poser på en gång (`equipItemInSlot` / `unequipItemById`). Poserna är kvar som förhandsvisning av animationerna — de äger inga kläder.

## Kvar att göra — i den ordning jag tar dem

1. **D. Härled positionen ur bilden.** *Klar: `scripts/prepare_wardrobe_items.py` läser varje WebP:s opaka bbox med Pillow och skriver `assets/wardrobe/manifest.json` + `lib/domain/entities/wardrobe_manifest.g.dart` (`const`).*
2. **C. Ankarpunkter i stället för `Alignment`.** *Klar: `zOrder`, tapptarget och position kommer ur manifestet. `case 'item_x':`-switchen i `_getInteractiveHitShape` är borta, handjusterade tapptarget (t.ex. hattens 0,9/0,46, trimmad för sjuåringsfingrar) lever vidare som `hitShapeOverride`, och renderaren räknar positionen med `anchoredItemOffset` (`lib/domain/services/wardrobe_layout.dart`) ur bildens ankar­punkt i stället för `Alignment(0, -2.8)`.* Kvar att titta på: Loke står exakt stilla, men Signe och Astrid knuffar sina hattar några procent (upp till ~12 px på en 200 px karaktär) eftersom deras `scaleModifier` ändrar boxens storlek och den gamla offseten var skriven som en multipel av `(1 - skala) / 2`. `wardrobe_position_audit_test` håller avvikelsen under 6 % och fäller om den växer.
3. **B. En outfit per barn i datamodellen.** *Klar sedan tidigare: basoutfit + `OutfitResolver`, en nyckel per plagg i stället för per pose.*
4. **E. Färdiga outfits för de yngsta.** *Klar: "Slumpa outfit" (`OutfitShuffler`) och namngivna set — Safari, Forskare, Pirat (`outfit_looks.dart`). En look tar på det barnet äger och lämnar resten som något att leta efter.*

## Städat: tre bilder som aldrig visades

`item_binoculars_safari.webp`, `item_compass_safari.webp` och `item_map_safari.webp` låg kvar som byte-identiska kopior av sina `_nobg`-versioner, utan en enda referens — 200 KB i APK:n som inget barn kunde se (kartan ensam 132 KB). Borttagna. `wardrobe_assets_audit_test` håller det stängt: varje plagg måste peka på en fil som finns, och varje bild i `assets/images/items/` måste ägas av ett plagg.

Samma test pinnar att `item_safari_hat` och `item_hat_safari` är **två** plagg med två olika bilder, inte en dubblett. De heter nästan likadant, men id:na får inte bytas: en namnändring kräver migrering av `unlockedItems` i alla befintliga profiler, och vinsten för barnet är noll.

## Safariskorna syntes aldrig

`_slotLayers` i `game_character.dart` listar de sex lager som faktiskt ritas: `back`, `body`, `face`, `head`, `accessory`, `front`. `item_shoes_safari` ligger i slot `feet`, som **inte** fanns i listan. Barnet kunde alltså låsa upp skorna, trycka på dem, se rutan lysa — och ingenting hände på figuren. Ingenstans klagade appen: ett plagg i en okänd slot hoppas bara över.

`feet` är nu ett riktigt lager (under skjortan, så en lång tröja kan hänga över skorna) och två tester håller det stängt:

- `wardrobe_slots_audit_test` — varje plagg i garderoben måste ha en slot som ritas, och manifestets z-ordning måste vara **identisk** med `_slotLayers`.
- `game_character_test` — frågar render-trädet, inte katalogen: skorna ska finnas som `Image` när de är på.

## "2 plagg kvar att hitta"

En look tar bara på det barnet äger, så ett tryck på Pirat kunde ge en halv outfit utan en förklaring. Nu säger garderoben hur många plagg som är kvar (`lookMissingCount` + en kort snackbar): pausen blir ett mål i stället för en lucka. Räknaren hoppar över okända id:n, så ett omdöpt plagg kan aldrig få siffran att ljuga.

## Tapptarget ur manifestet

`_getInteractiveHitShape` var en `switch` med ett `case 'item_x':` per plagg — det sista stället där ett nytt plagg krävde en ändring i widgeten, och en audit som *grep:ade källkoden* efter `case '`-rader för att ingen skulle glömma en. Nu slår den upp i manifestet: bredd/höjd mätt ur bildens opaka bbox, med de handjusterade värdena kvar som `hitShapeOverride` — och de värdena bor i `assets/wardrobe/hit_shape_overrides.json`, inte i den switch som togs bort. (Första versionen av scriptet skrapade switchen; då hade en omkörning tyst tappat alla overrides och gjort hattarna svårare att träffa.) `wardrobe_hit_shape_audit_test` kontrollerar talen i stället för texten: alla plagg som ritas har en post, tapptarget ligger inom bilden (0–1], och hattens override får inte försvinna — då blir det svårare att träffa för de yngsta, tyst.

## Manifestet: positionen härleds ur bilden

`scripts/prepare_wardrobe_items.py` läser varje WebP:s opaka bbox med Pillow och skriver:

- `assets/wardrobe/manifest.json` — granskningsbar diff, för människor
- `lib/domain/entities/wardrobe_manifest.g.dart` — `const`, så appen parsar ingen JSON vid start

Härlett: `anchor` (var i bilden det synliga sitter, 0–1), `hitShape` (bbox + 2 % padding, i stället för att gissa på slot), `zOrder` (från slotordningen) och `target` (var ankarpunkten ska landa på karaktären, som andel av dess höjd).

`target` lästes **en gång** ur den gamla `offset`/`renderScale`-paren, så bytet av modell flyttade ingenting utom avrundning. `legacy` ligger kvar i manifestet bara för att `wardrobe_position_audit_test` ska kunna hålla de två modellerna mot varandra; renderaren rör den inte längre. Ett plagg som bara anger sin slot ärver `slotAnchors` — medianen för var dess syskon i samma slot sitter — så ett nytt plagg behöver ingen handjusterad position alls:

```
offset: Alignment(0, -2.8), renderScale: 0.85   ->  slot: 'head'
```

Positionen blir då hattarnas mitt, inte en gissning. Vill plagget sitta någon annanstans än sina syskon finns `target: {x, y}` kvar att sätta för hand — men det är undantaget, inte regeln.

Kör: `python3 scripts/prepare_wardrobe_items.py` (kräver Pillow). `--check` fäller om filerna är inaktuella. CI kör aldrig scriptet; `wardrobe_slots_audit_test` jämför i stället det genererade manifestet mot katalogen, så drift fälls utan Python i CI.

## Två saker att kolla innan manifestet låses

- `item_safari_hat` ("Safarihatt") och `item_hat_safari` ("Utforskarhatt") ser ut som dubbletter — jämför bilderna innan båda skrivs in i ett manifest.
- Garderoben har `kDebugMode ||` när den avgör om ett plagg är upplåst, så i debug-bygget är allt upplåst. Testa unlocks i en riktig build.
