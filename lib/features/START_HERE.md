# Start Har i features

`features/` ar dar du oftast borjar nar du vill forsta vad anvandaren faktiskt ser och gor.

## Namnsignaler i featuremappar

- `presentation/screens/`: featurets riktiga entry-skarmar
- `presentation/dialogs/`: korta modalfloden
- `presentation/widgets/`: featureagda UI-bitar
- `providers/`: harledd state eller featurewiring
- `__*_part.dart`: intern del som ags av filen bredvid

## Valj feature

- `home/`: hubben efter profilval
- `quiz/`: fragor, feedback och resultatskarm
- `story/`: kartan och questflodet
- `parent/`: PIN, installningar och historik for vuxenlaget
- `inventory/`: garderob och utrustning
- `profiles/`: profilval och skapa profil
- `onboarding/`: forsta-gangen-flodet
- `settings/`: vanliga installningar och privacy policy

## For tvarsnitt genom flera features

- Quiz till resultat: `../core/services/SERVICES_INDEX.md` och `../../docs/TRACE_MAP.md`
- Start och routing: `../app/bootstrap/presentation/`