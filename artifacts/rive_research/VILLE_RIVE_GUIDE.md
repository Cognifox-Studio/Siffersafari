# Rive-guide för Karaktären "Ville"

Denna guide bygger på originalbilden och används för att bygga upp Villes rigg och animationer i Rive enligt appens ramverk för spelarupplevelsen.

## Bildanalys
- **Karaktärstyp:** Ung äventyrare/barn med väska och hatt.
- **Visuell stil:** Vektor-flata färger, cartoon, tydliga svarta eller mörka outlines.
- **Proportioner:** Relativt stort huvud gentemot kroppen (barn-proportioner), trubbiga korta ben och armar.
- **Färgpalett:** Grön skjorta/skjorts, gul T-shirt-ärm/knappar, blågrön ryggsäck, beige stråhatt.
- **Vad som ska behållas:** Hatten (viktig siluett-byggare), hängslen/väsk-remmar, tummen upp-handen (som symbol för rätt svar).
- **Vad som ska förenklas:** Händerna reduceras från detaljerade femfingers-händer till rundare former, med undantag för "Tummen upp" som kan ligga som ett separat utbytbart lager (`hand_thumbs_up.svg`).

## 1. Förberedelse (SVG)
Alla SVG-delar måste exporteras med en ren outline och rena färgfält, utan inbrända skuggor som krånglar till rotationen. Bygg dem i storlek 1024x1024 (eller liknande, med centrerat ankarpunkt) i `assets/characters/ville/svg/`.

Delar att importera i Rive:
- `ville_head.svg` (utan ansiktsdrag)
- `ville_hat.svg` (kan antingen hänga bakom eller på huvudet)
- `ville_eyes_open.svg` & `ville_eyes_blink.svg` (styrs med opacity i blink-cykel)
- `ville_mouth_neutral.svg`, `ville_mouth_happy.svg`, `ville_mouth_sad.svg` (opacity eller vertex-animering)
- `ville_torso.svg` (inkluderar remmarna för att slipa rigga fram-baksida för remmarna)
- `ville_backpack.svg` (Ligger bakom torson med egen pivot point)
- `ville_arm_left.svg` & `ville_arm_right.svg` (Mjuka rör)
- `ville_leg_left.svg` & `ville_leg_right.svg` (Korta mjuka stubbar)
- `ville_shoe_left.svg` & `ville_shoe_right.svg` (Sluta former)

## 2. Riggnings-schema
Rive Bones-uppsättningen följer standarden från `humanoid_base_form_v1.json`:
- `root` (Mitten/mellan fötter)
  - `pelvis` (Strax under bältet)
    - `spine` -> `chest` -> `neck` -> `head` -> (eyes / mouth / hat)
    - `chest` -> `shoulder_L` -> arm_L -> wrist_L -> hand_L
    - `chest` -> `shoulder_R` -> arm_R -> wrist_R -> hand_R
  - `hip_L` -> leg_L -> ankle_L -> shoe_L
  - `hip_R` -> leg_R -> ankle_R -> shoe_R
  - *Extraben:* `backpack_pivot` kopplas på `chest` och hänger bakåt så att den gungar lite vid gång/hopp.

## 3. Constraints & Begränsningar
- Huvudet (`head`) bör ej rotera mer än cirka 15–20 grader för att behålla outline-sambandet med nacken intakt.
- Ryggsäcken (`backpack`) ska följa `chest` rullning, men hänga lite efter under rörelse (Delayed constraint eller mjuka nyckelbilder).
- Armar böjs enklast som mjuka IK-kedjor eller enkla böjningar i en riktning, inga fulla 360-rotationer i armbågen annars spricker formen.

## 4. State Machine: `ville_main_sm`

Bygg en primär State Machine med följande Triggers och Booleans:
- **Inputs:**
  - `isWalking` (Bool) – Går mellan `idle` och `walk`.
  - `triggerCorrect` (Trigger) – River av `answer_correct` (och byter till happy mouth/tumme upp).
  - `triggerWrong` (Trigger) – River av `answer_wrong` (huvud hänger ner, sad mouth).
  - `triggerTap` (Trigger) – "Easter egg", t.ex. att han trycker upp hatten lite.

Vid export, generera filen som bygger den slutgiltiga integrerade mascot-filen och lägg den under `artifacts/ville_rig.riv`.