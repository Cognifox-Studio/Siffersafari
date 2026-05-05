<!--
typ: reference
syfte: Sammanställning och index för all dokumentation
uppdaterad: 2026-05-01
-->

# Dokumentationshub (Diátaxis-index)

Detta är ingångspunkten till dokumentationen. All dokumentation är organiserad enligt Diátaxis-ramverket.

Senast uppdaterad: 2026-05-01.

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
- `PROJECT_MAP.md` – Generera och öppna den lokala live-kartan över projektets moduler
- `SETUP_ENVIRONMENT.md` – Sätt upp miljön
- `CONTRIBUTING.md` – Bidra till projektet

### Reference (fakta, API, struktur)
- `ARCHITECTURE.md` – Systemets faktiska implementation
- `PROJECT_STRUCTURE.md` – Repo-struktur
- `SERVICES_API.md` – Servicekontrakt
- `KUNSKAPSNIVA_PER_AK.md` – Nivåspecifikationer

### Explanation (förklaringar, design, varför)
- `ROADMAP.md` – Prioriterad release- och genomförandeplan
- `DECISIONS_LOG.md` – Beslutslogg och varför
- `RIVERPOD_PATTERNS.md` – Provider-mönster och resonemang
- `NAMING_STRUCTURE_REFACTOR_PLAN.md` – Historisk migrationsplan och naming-principer

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
