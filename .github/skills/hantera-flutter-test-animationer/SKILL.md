---
name: hantera-flutter-test-animationer
description: 'Use when fixing widget tests that timeout or fail due to continuous animations (like Confetti, looping mascots) or encoding issues in text finders.'
argument-hint: 'Beskriv vilket test som faller, vilken animation eller finder som verkar orsaka det, och om felet syns lokalt eller i CI.'
---

# Hantera Flutter-test och animationer

## Context
Continuous animations prevent the Flutter test engine from ever reaching a "settled" state. Calls to `tester.pumpAndSettle()` will throw a timeout exception. Dessutom kan dynamiska textbyten och teckenkodningsfel få textbaserade sökningar att fallera plötsligt.

## Felsökningsregler

1. **Undvik pumpAndSettle:** 
   Om en skärm har oändliga eller långa procedur-animationer (t.ex. `ConfettiOverlay` eller `GameCharacter`-loopar), ersätt `tester.pumpAndSettle()` med en kontrollerad loop av `tester.pump(Duration(...))` eller den befintliga hjälpmetoden `pumpUntilFound(tester, finder)`.
   
2. **Robusta Finders:**
   Hårdkodade strängsökningar (som `find.text('Nästa')` eller `find.textContaining('Fråga')`) är sällan robusta i CI-miljöer på grund av encoding-fel (blir ofta `NÃ¤sta`) eller avsiktliga UX-justeringar för barn.
   - Byt till komponent- eller nyckelsökningar: `find.byType(ElevatedButton)`, `find.byType(QuestionCard)` eller `find.byKey(...)`.
   
3. **Hit Testing och Hitboxar:**
   När visuella komponenter (som konfetti eller badges) svävar över skärmen, se alltid till att de är inpackade i en `IgnorePointer` ifall de inte har interaktivitet. Detta säkerställer att `finder.hitTestable()` i interaktionstesterna fortsätter fungera för underliggande knappar.
