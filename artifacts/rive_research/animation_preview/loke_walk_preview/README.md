# Loke Walk Preview

Denna preview visar nya Loke som en ljus, vanlig djungelpojke med glasogon, gron keps och bla klader i en fardig walk-loop.

## Lokal korning

1. Starta en enkel server i repo-roten, till exempel `py -m http.server 8765`.
2. Oppna sedan `http://127.0.0.1:8765/artifacts/animation_preview/loke_walk_preview/` i webblasaren.

## Syfte

- visa Lokes nuvarande walk-animation i browser utan Flutter-korning
- ge en tydlig preview av timing, blink och helkroppsrytm
- fungera som aktuell Loke-preview i animation-hubben

Previewn ar en lokal HTML/SVG-animation, inte en `.riv`-export eller runtime-asset.
