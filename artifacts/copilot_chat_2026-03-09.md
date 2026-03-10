# Kuraterade Copilot-insikter for Siffersafari

- Datum: 2026-03-09
- Notering: Bara forslag som passar ett enkelt offline-flode och den nuvarande appen finns kvar har.

## Bra forslag att behalla

### 1. Fortsatt hardning av integrationstester

Varfor detta ar bra:
- Appen har redan tester for onboarding, quizstart och PIN-floden.
- Detta minskar risken for regressionsfel i viktiga offline-floden.

Konkreta riktningar:
- utoka tester for profil, quiz och foraldralage
- fortsatta harda onboarding- och dialogfloden

### 2. Forbattra tillganglighet

Varfor detta ar bra:
- Det gor appen enklare att anvanda for fler barn och vuxna.
- Detta passar nuvarande app utan att skapa nya system.

Konkreta riktningar:
- battre textskalning
- tydligare kontrast
- tydligare fokus och upplasning

### 3. Polera prestanda i quiz, animation och ljud

Varfor detta ar bra:
- Små prestandalyft i karnloopen marks direkt.
- Detta ar battre an att bygga nya speciallagen eller avancerade extra-funktioner.

Konkreta riktningar:
- snabbare ratt/fel-feedback
- mindre seghet i animationer och ljud

### 4. Forenkla och forbattra onboarding

Varfor detta ar bra:
- Det finns redan en fungerande onboarding.
- Det som behovs ar att gora den snabbare och tydligare, inte mer avancerad.

Konkreta riktningar:
- mindre text
- tydligare val
- snabbare vag till forsta quizet

### 5. Tydligare feedback i ovningarna

Varfor detta ar bra:
- Barnet marker detta direkt i varje fraga.
- Detta gor appen tydligare utan att forandra offline-flodet.

Konkreta riktningar:
- snabb och positiv respons vid ratt svar
- lugn och enkel guidning vid fel svar

### 6. Tydligare progression for barn och foraldrar

Varfor detta ar bra:
- Appen har redan progression och historik.
- Det som behovs ar tydligare presentation, inte fler avancerade system.

Konkreta riktningar:
- tydligare kansla av framsteg efter quiz
- enklare sammanfattning i foraldralaget

### 7. Gora den adaptiva logiken mer begriplig

Varfor detta ar bra:
- Den adaptiva logiken finns redan.
- Fokus bor vara att forklara den enklare, inte att bygga om den till nagot mer komplicerat.

Konkreta riktningar:
- kort forklaring till varfor nivan andras
- stabil och tydlig progression

## Viktiga saker att komma ihag

- Hall fast vid offline-first.
- Bygg inte in analytics eller annan spårning.
- Bygg inte nya avancerade sidospår som riskerar att forvirra barn eller foraldrar.
- Forbattra det som redan finns i karnflodet i stallet for att lagga till fler system.

## Slutsats

Det som verkar mest vardefullt ar enkla forbattringar i den befintliga appen:

- testhardning
- tillganglighet
- snabbare och tydligare quizfeedback
- enklare onboarding
- tydligare progression
- forsiktig polering av den adaptiva upplevelsen

Detta ligger i linje med ert offline-flode och undviker onodigt avancerade funktioner.

## Konkret 2-veckors plan

Malet med de har 2 veckorna ar att ge tydlig anvandarnytta utan att bygga nya system. Fokus ar quizfeedback, onboarding, progression och hardning av kansliga floden.

### Vecka 1

#### Dag 1. Kartlagg och avgransa

Mal:
- bestam exakt vilka sma forbattringar som ska in nu

Leverabler:
- en kort lista med 3 delspår:
	- quizfeedback
	- onboarding
	- progression
- beslut om vad som uttryckligen inte ska goras i denna sprint

Definition of done:
- alla andringar ska vara inom befintligt offline-flode
- inga nya system som analytics, feature flags eller performance mode

#### Dag 2. Quizfeedback - nulagesjustering

Mal:
- gora ratt/fel-responsen tydligare och snabbare

Leverabler:
- justerad timing for feedbackdialog eller feedbacksteg
- tydligare positiv respons vid ratt svar
- lugnare och kortare guidning vid fel svar

Kontroll:
- feedbacken ska kannas snabbare utan att bli stökig
- inga extra steg som sinkar fragerundan

#### Dag 3. Quizfeedback - finslipning

Mal:
- gora feedbacken konsekvent i hela flodet

Leverabler:
- enhetligare copy i ratt/fel-feedback
- bort med eventuell overtydlighet eller overstimulans
- snabb manuell kontroll av 10-15 fragesvar i rad

Kontroll:
- barnet ska forsta vad som hande direkt
- inget extra brus i UI eller ljud

#### Dag 4. Onboarding - forenkla text och val

Mal:
- gora onboarding snabbare att ta sig igenom

Leverabler:
- kortare texter
- tydligare rubriker
- mindre tvekan i val som arskurs och raknesatt

Kontroll:
- varje steg ska vara begripligt pa nagra sekunder
- inget steg ska kannas som en instruktionstext eller manual

#### Dag 5. Onboarding - snabbare vag till forsta quizet

Mal:
- minska friktionen mellan profilskapande och forsta spelstart

Leverabler:
- tydligare slutpunkt i onboarding
- kontroll att barnet snabbt landar i Home/forsta valbara quiz
- riktad test av onboardingflodet

Kontroll:
- ny anvandare ska kunna komma till quiz utan osakerhet

### Vecka 2

#### Dag 6. Progression - tydligare barnvy

Mal:
- gora framsteg mer synliga for barnet

Leverabler:
- tydligare kansla efter avslutat quiz av att ha gjort framsteg
- enklare formuleringar kring niva, poang eller uppdrag

Kontroll:
- barnet ska kanna "jag kom vidare" utan att lasa mycket

#### Dag 7. Progression - tydligare foraldravy

Mal:
- gora utvecklingen enklare att tolka for foraldrar

Leverabler:
- enklare sammanfattning i foraldralaget
- tydligare koppling mellan resultat och utveckling

Kontroll:
- foralder ska snabbt kunna forsta om det gar bra, star still eller behovs mer ovning

#### Dag 8. Hardning av kansliga floden

Mal:
- minska regressionsrisk i det ni just andrat

Leverabler:
- uppdaterade integrationstester for onboarding, quizstart eller parent-floden
- manuell kontroll av profilbyte, onboarding och quizstart

Kontroll:
- inga dubbla onboarding-pushar
- inga konstiga hopp mellan skarmar

#### Dag 9. Tillganglighet och små polish-fixar

Mal:
- ta de enkla A11y-vinsterna i samma svep

Leverabler:
- kontroll av textskalning i berorda vyer
- kontrastkontroll i dialoger och viktiga kort
- enkel genomgang av fokusordning och upplasning dar det ar relevant

Kontroll:
- inget ska bli svarlasligt eller plottrigt vid storre text

#### Dag 10. Stabilisering och QA

Mal:
- avsluta sprinten med ett stabilt och begripligt resultat

Leverabler:
- slutlig manuell genomgang av hela huvudflodet
- analyze + relevanta tester
- kort notering om vad som faktiskt blev battre och vad som skjuts till senare

Kontroll:
- huvudflodet ska kannas snabbare, tydligare och tryggare an fore sprinten

## Prioriteringsordning om tiden inte racker

Om allt inte hinns med, gor detta i ordning:

1. quizfeedback
2. onboarding
3. progression for barnet
4. hardning av tester
5. foraldravy-polish
6. extra tillganglighetspolish

## Det vi uttryckligen inte gor i dessa 2 veckor

- inga analytics- eller sparningsspår utover befintlig lokal data
- inga feature flags
- inget performance mode
- ingen stor ombyggnad av adaptiva logiken
- inga nya sidospår som gor appen mer tekniskt komplicerad