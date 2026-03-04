# BEFORE RELEASE

## Legal & Compliance (gör ABSOLUT FÖRST)
- [ ] [RESEARCH] Verifiera att alla lagkrav (GDPR, COPPA, etc) är uppfyllda (juridisk checklista)
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] [RESEARCH] Verifiera att privacy policy och terms of service är uppdaterade (juridisk granskning)
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Kontrollera att alla assets har korrekt copyright/licens
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Verifiera att permissions är minimala och väldokumenterade
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar

## Security Audit
- [ ] [RESEARCH] Gör final security audit (OWASP top 10 för mobila appar)
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar

## Documentation
- [ ] Säkerställ att all dokumentation är uppdaterad
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar

## Testing & Quality Assurance
- [ ] Kör fullständig regressionstestning på alla enheter
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Testa appen på lågpresterande enheter
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Testa med olika språkinställningar
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Testa installation och avinstallation på flera enheter
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Testa uppgradering från tidigare version (om relevant)
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar

## Performance & Compatibility
- [ ] Kör prestandatest och åtgärda eventuella flaskhalsar
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Kontrollera att app-storlek är acceptabel
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar

## Functionality Verification
- [ ] Säkerställ att backup och återställning fungerar
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Kontrollera att alla länkar och externa resurser fungerar
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Säkerställ att onboarding fungerar utan internet
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Arkitektur-audit: verifiera att all data hanteras via Hive och att ingen kod gör nätverksanrop
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
	- [ ] Sök igenom kodbasen efter nätverksklienter/imports och dokumentera resultat
	- [ ] Verifiera att all persistence går via Hive/repositories
	- [ ] Kör appen i flygplansläge och testa kärnflöden end-to-end
	- [ ] Sign-off: "Offline-only verifierad" i release-noteringar

## Monitoring & Analytics
- [ ] Verifiera att crash reporting fungerar
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Kontrollera att alla analytics events loggas korrekt
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar

## Build & Signing
- [ ] Verifiera att alla APK-signaturer fungerar korrekt
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar

## Final Polish
- [ ] Gör en sista UI/UX-genomgång och fixa smådetaljer
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Verifiera att alla texter är korrekt översatta
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
- [ ] Språkgranska all svensk text i appen: enkel, begriplig och med korrekt grammatik
  - [ ] Definiera scope och kriterier
  - [ ] Genomför ändringen
  - [ ] Verifiera och markera klar
	- [ ] Granska alla texter för Åk 1-3: korta meningar och enkla ord
	- [ ] Korrigera grammatik, stavning och konsekvent ton i hela appen
	- [ ] Verifiera i appen (inte bara i kod) att sluttexten blev rätt
	- [ ] Sign-off av språkgranskning före release
