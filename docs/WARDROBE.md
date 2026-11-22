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

1. **D. Härled positionen ur bilden.** `scripts/prepare_wardrobe_items.py` läser varje WebP:s opaka bbox, räknar ankarpunkt och skala relativt karaktärens huvud-/kroppsbox, och skriver ett manifest **plus** hit-shape. Då försvinner både de magiska talen och `case 'item_x':`-switchen: nytt plagg = lägg in filen, kör scriptet.
2. **C. Ankarpunkter i stället för `Alignment`.** Per slot en normaliserad ankarpunkt + `zOrder` i manifestet; drag finns kvar som finjustering men lagras bara som `n,`. En audit kräver att varje plagg har känd slot, existerande asset och unik z-ordning.
3. **B. En outfit per barn i datamodellen.** `equippedItems` blir `slot → itemId`, med en liten explicit override-map för de få poser som verkligen behöver det. Migrering kollapsar befintliga nycklar (idle vinner), idempotent och testad.
4. **E. Färdiga outfits för de yngsta.** *Klar: "Slumpa outfit" ger ett helt set (`OutfitShuffler`), och namngivna set — Safari, Forskare, Pirat — sitter som chips ovanför plaggallret (`outfit_looks.dart`). En look tar på det barnet äger och lämnar resten kvar som något att leta efter, en plagg per slot, en sparning via `applyBaseOutfit`.* "Safari", "Pirat", "Forskare" + "Slumpa": ett tryck i stället för att dra och rotera med sjuåringsfingrar. Bygger ovanpå B–D.

## Två saker att kolla innan manifestet låses

- `item_safari_hat` ("Safarihatt") och `item_hat_safari` ("Utforskarhatt") ser ut som dubbletter — jämför bilderna innan båda skrivs in i ett manifest.
- Garderoben har `kDebugMode ||` när den avgör om ett plagg är upplåst, så i debug-bygget är allt upplåst. Testa unlocks i en riktig build.
