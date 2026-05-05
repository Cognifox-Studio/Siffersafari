# Project Map

Den här sidan beskriver hur du genererar och öppnar den lokala, självuponterande projektkartan för appen.

## Syfte

Projektkartan visar en levande modulöversikt över:

- `main.dart` och bootstrap
- features och delad UI
- Riverpod/DI
- services
- domain/data/foundation

Kartan byggs från faktiska Dart-importer under `lib/` och grupperar filerna till läsbara moduler.

## Starta kartan

Kör generatorn i watch-läge från repo-roten:

```sh
dart run scripts/generate_project_map.dart --watch
```

Öppna sedan sidan:

- `site/project-map/index.html`

Sidan läser `site/project-map/graph-data.js` och laddar om grafdata automatiskt var tredje sekund.

## Vad du ser

- kolumner för appens huvudsakliga lager
- noder för varje modulgrupp
- edges mellan moduler baserat på importer
- detaljpanel med filer, roller, inkommande och utgående beroenden

## Begränsningar

- Kartan visar statiska kodberoenden, inte runtime-state eller navigation i realtid.
- Mycket små kopplingar kan behöva filtreras bort via reglaget för edge-vikt för att grafen ska bli läsbar.
- Dynamiska flöden som skapas utan tydliga importer syns inte alltid i grafen.