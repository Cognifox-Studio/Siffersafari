# Ville (character_v2) — 3D basmodell (brief)

Syfte: skapa en **kanonisk 3D‑modell av Ville** som matchar `assets/images/themes/jungle/character_v2.png`, så att vi kan:
- rendera konsekventa 2D‑sprites/animationer (offline), och/eller
- återanvända samma karaktär i framtida 3D‑scener.

## Stil (måste matcha character_v2)
- Barnvänlig, mjuk, “cartoon” (inte realistisk).
- Enkla former, tydlig siluett.
- Stora ögon, mjukt leende, rosiga kinder.
- Outfit och färger ska vara **konsekventa** mellan poses/animationer.

## Siluett & proportioner (observationsbaserat)
- **Stor hatt** (safarihatt) som dominerar toppsilhuetten.
- Huvud relativt stort jämfört med kropp (”kid mascot”‑proportion).
- Kroppen smal/kompakt, korta armar/ben.
- Full‑body, stående neutral pose.

Teknisk referens från bilden:
- Bild: 512×512, alpha‑png.
- Icke‑transparent bbox: x=112..388, y=16..505 (w≈277, h≈490).

## Kläder & detaljer (det som ska modelleras)
- Safarihatt:
  - Off‑white/krämfärgad, rund brätte.
  - Band runt kullen.
- Hår:
  - Mörkbrunt, syns under hatt.
- Ansikte:
  - Tjocka ögonbryn.
  - Stora mörka pupiller.
  - Rosiga kinder.
  - Litet leende.
- Överkropp:
  - Gul t‑shirt.
  - Teal/grön väst/jacka med enkel front (knappar/sömmar).
  - Ryggsäck/axelremmar (grön ton) + små fästen.
- Underkropp:
  - Gröna byxor (enkel form, lätt “cartoon”-cuff).
- Skor:
  - Gula skor med **vit tå** och vit sula.

## Färgpalett (approx från `character_v2.png`)
Det här är grova dominantfärger (kvantiserade). Använd som start:
- Hår/mörka konturer: ~#3E151D
- Hud (bas): ~#FBA080 (och ljusare nyanser runt ~#FBA980)
- Hat/highlights: ~#FFFFD2 / ~#FFFFCA
- Vit (skor/ögon-highlights): ~#FFFFFF
- Gul (t‑shirt/skor): ~#FFF315
- Grön (byxor/remmar): ~#15C16F / ~#15B96F
- Teal (väst): ~#77FFCA / ~#77FFC1

Tips: behåll material **matta**; vi vill inte ha “plastig realism”.

## Material / shading
Välj en av dessa två spår (håll dig till ett):

A) **Toon/stylized render (rekommenderat för att matcha 2D)**
- BaseColor‑textur + enkel toon‑ramp.
- Låg specular, hög roughness.
- Outline via inverted‑hull eller postprocess.

B) **Enkel PBR (för framtida 3D)**
- BaseColor + Roughness (och ev. Normal väldigt subtilt).
- Undvik stark metallness (nästan allt är icke‑metall).

## Modellering (tekniska krav)
- Poly‑budget: sikta på ca 5k–15k tris (mobilvänligt).
- Ren quad‑topologi där deformation sker (axlar, armbågar, knän, ansikte).
- Separata mesh‑delar där det hjälper:
  - hatt (separat), huvud, kropp, skor (kan vara separata), ryggsäck/remmar.

## Rigg (miniminivå)
- Humanoid-skelett: pelvis/spine/chest/neck/head.
- Armar: clavicle, upperarm, forearm, hand.
- Ben: thigh, shin, foot.
- Ögon som separata objekt eller bones för look‑at.

Blendshapes (om vi vill ha expressivitet utan tung rigg):
- blink_L, blink_R
- smile
- brow_up, brow_down

## Export/format
- Primärt: `glTF 2.0` (`.glb`) med inbakade texturer.
- Skala: 1.0 ≈ 1 meter (valfritt men konsekvent).
- Pivot/origin vid fötterna (så den står “på marken”).

## Leverabler (det vi vill ha ut)
1) `Ville_Base.glb` (neutral pose)
2) `Ville_Rigged.glb` (om rigg ingår)
3) Texturatlas (om separat): `Ville_BaseColor.png` (+ ev. roughness)
4) Preview-renders: front/side/back + 3/4 view

## Vanliga fallgropar (utifrån vår 2D‑pipeline)
- För “realistisk” hud/ljus → tappar barnvänliga looken.
- För små detaljer i textur → flimrar i små storlekar.
- För smal hatt/brätte → siluetten blir inte Ville.

