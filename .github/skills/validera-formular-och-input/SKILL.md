---
name: validera-formular-och-input
description: 'Review and fix form validation, TextField input, TextEditingController lifecycle and async submit UX. Use when inputs behave incorrectly, validation is weak, or a dialog/screen needs a form audit.'
argument-hint: 'Beskriv vilken skärm eller dialog som ska granskas och vilket inputproblem som märks.'
---

# Validera formulär och input

Använd skillen när en skärm eller dialog har textfält, valideringsfel, controllers som läcker eller async-submit som tillåter dubbeltryck.

## Arbetsflöde
1. Identifiera alla `TextField` och `TextFormField` i den berörda vyn.
2. Kontrollera controller- och `FocusNode`-livscykel. De ska ägas av en stateful widget när livscykel behövs och stängas i `dispose()`.
3. Kontrollera valideringen: tomma värden, dubbletter, gränser, otillåtna tecken och trimning.
4. Kontrollera återkopplingen: fel ska synas nära fältet, inte bara i snackbar.
5. Om submit är async: disable CTA eller visa spinner så att dubbelsubmit blockeras.
6. Säkerställ att lösningen följer `.github/instructions/regler-for-formular-och-validering.instructions.md`.