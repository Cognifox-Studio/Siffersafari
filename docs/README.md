<!--
typ: reference
syfte: Sammanställning och index för all dokumentation
uppdaterad: 2026-04-25
-->

# Dokumentationshub (Diátaxis-index)

Detta är ingångspunkten till dokumentationen. All dokumentation är organiserad enligt Diátaxis-ramverket.

Senast uppdaterad: 2026-04-18.

## Naming-baseline

- Tekniska filnamn ska vara engelska och använda `snake_case`.
- Feature-ägd UI ska ligga under `lib/features/<feature>/presentation/widgets/`.
- `lib/presentation/widgets/` är reserverad för verkligt delad UI och app-shell-komponenter.

## Diátaxis-typer och index

### Tutorials (lär genom att göra)
- `GETTING_STARTED.md` – Kom igång med projektet
- `ADD_FEATURE.md` – Lägg till en feature


### How-to guides (lös ett specifikt problem)
- `DEPLOY_ANDROID.md` – Så deployar du till Android
- `ASSET_GENERATION.md` – Så genererar du assets
- `AI_ASSET_PIPELINE.md` – Generera AI-baserade assets
- `NAMING_STRUCTURE_REFACTOR_PLAN.md` – Genomför namn- och strukturstädning stegvis
- `SETUP_ENVIRONMENT.md` – Sätt upp miljön
- `CONTRIBUTING.md` – Bidra till projektet

### Reference (fakta, API, struktur)
- `ARCHITECTURE.md` – Systemets faktiska implementation
- `PROJECT_STRUCTURE.md` – Repo-struktur
- `SERVICES_API.md` – Servicekontrakt
- `KUNSKAPSNIVA_PER_AK.md` – Nivåspecifikationer
- `CHARACTER_ANIMATIONS.md` – Animation API
- `AI_ASSET_PIPELINE.md` – Asset pipeline

### Explanation (förklaringar, design, varför)
- `DECISIONS_LOG.md` – Beslutslogg och varför
- `RIVERPOD_PATTERNS.md` – Provider-mönster och resonemang

### Övrigt
- `PRIVACY_POLICY.md` – Policy (källtext för publik privacy policy-sida)
- `PARENTS_TEACHERS_GUIDE.md` – Guide för föräldrar/lärare
- `SESSION_BRIEF.md` – Historisk logg

---
Om information krockar mellan filer, använd dessa som facit (i ordning):
1. `ARCHITECTURE.md`
2. `PROJECT_STRUCTURE.md`
3. `SERVICES_API.md`
(empty)
