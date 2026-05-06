---
description: "Hygien och sortering av rå-bilder och original från AI eller illustratör, samt import till assets."
applyTo: "_incoming/**, aassets/**/*.png, **/*inventory_item*.dart"
---

# Hantering av _incoming och assets/

När nya bilder (t.ex. från AI eller illustratör) landar i projektet gäller följande struktur:

1. **Namngivning först:** Byt namn på råa filer (t.ex. Copilot_...png) till appens logiska filnamn (t.ex. item_shoes_safari.png).
2. **_nobg-regeln:** Den transparenta/frilagda versionen MÅSTE döpas till exakt samma sak som originalet men med suffixet _nobg.png (t.ex. item_shoes_safari_nobg.png). Gamla suffix som _clear.png är strikt förbjudna. Original och _nobg ska alltid finnas som ett par.
3. **Inkorg vs Arkiv i _incoming:**
   - **Oanvända:** Ligger löst i roten av _incoming/ (fungerar som WIP-inkorg).
   - **Använda (När de kopierats in till spelet):** Sorteras in i rätt undermapp (_incoming/items/, _incoming/characters/, _incoming/ui/ eller _incoming/icons/).
4. **Kopiera - Flytta inte:** Kopiera alltid (flytta inte) från _incoming/ in till appens assets/-mapp. _incoming/ agerar säkert rå-arkiv ifall vi behöver originalets prompt eller bakgrund senare.
5. **Kräver omstart (Asset Manifest):** När HELT NYA filer kopieras in i assets/ räcker inte Hot Reload / Hot Restart i Flutter Web. Maskinen missar dem och kastar HTTP 404. Stäng processen och starta om flutter run helt och hållet för att bygga om manifestet.
