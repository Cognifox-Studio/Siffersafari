# Ville Walk Animation – Usage Guide

**Skapad:** 2026-03-10  
**Fil:** `assets/ui/lottie/ville_walk.json`

## 🚶 Vad är det?

En loopande walk cycle-animation för Ville-karaktären.

**Specifikationer:**
- 24 frames @ 24fps = 1 sekund per cycle
- Loopar automatiskt
- Innehåller:
  - Body bounce (vertikal rörelse)
  - Alternativt bensvängande
  - Motsatta armrörelser
  - Huvudrörelse synkad med steg

## 🎯 Användning

### 1. Direkt med Lottie-widget

```dart
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/ui/lottie/ville_walk.json',
  width: 120,
  height: 120,
  repeat: true,
)
```

### 2. Med dedikerad VilleWalkAnimation-widget

```dart
import 'package:siffersafari/presentation/widgets/ville_walk_animation.dart';

VilleWalkAnimation(
  size: 120,
  repeat: true,
)
```

### 3. Med controller (för att starta/stoppa)

```dart
import 'package:lottie/lottie.dart';

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset(
          'assets/ui/lottie/ville_walk.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            _controller.repeat(); // Start walking
          },
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.isAnimating) {
              _controller.stop();
            } else {
              _controller.repeat();
            }
            setState(() {});
          },
          child: Text(_controller.isAnimating ? 'Stop' : 'Walk'),
        ),
      ],
    );
  }
}
```

## 🎨 Användningsfall

**Quiz-screen:**
```dart
// Visa Ville som går på plats när användaren svarar rätt
if (isCorrect) {
  VilleWalkAnimation(size: 100, repeat: true);
}
```

**Home-screen:**
```dart
// Walking mascot som bakgrund
Positioned(
  bottom: 20,
  left: 0,
  child: VilleWalkAnimation(size: 80),
)
```

**Story progress:**
```dart
// Ville "går" längs en progress bar
Stack(
  children: [
    LinearProgressIndicator(value: progress),
    Positioned(
      left: progress * maxWidth,
      child: VilleWalkAnimation(size: 60),
    ),
  ],
)
```

## 🔄 Regenerera animation

Om du vill ändra timing eller rörelse:

```bash
# 1. Editera generateVilleWalk() i scripts/generate_lottie_effects.dart
code scripts/generate_lottie_effects.dart

# 2. Regenerera
dart run scripts/generate_lottie_effects.dart

# 3. Hot reload i Flutter
# Ändringarna syns direkt!
```

## 📊 Animation detaljer

| Parameter | Värde | Beskrivning |
|-----------|-------|-------------|
| Duration | 1.0s | En komplett walk cycle |
| FPS | 24 | Frames per second |
| Bounce | 5px | Vertikal rörelse |
| Leg swing | ±20° | Rotation amplitude |
| Arm swing | ±15° | Armsvängning |
| Loop | true | Kontinuerlig upprepning |

## 🎭 Anpassa animationen

### Ändra hastighet
```dart
Lottie.asset(
  'assets/ui/lottie/ville_walk.json',
  repeat: true,
  // Dubbel hastighet
  frameRate: FrameRate(48),
)
```

### Spegelvända (gå åt andra hållet)
```dart
Transform.flip(
  flipX: true,
  child: Lottie.asset('assets/ui/lottie/ville_walk.json'),
)
```

### Fade in/out
```dart
AnimatedOpacity(
  opacity: isWalking ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: VilleWalkAnimation(),
)
```

## 🔗 Relaterade filer

- [ville_walk_animation.dart](../lib/presentation/widgets/ville_walk_animation.dart) – Widget wrapper
- [generate_lottie_effects.dart](../scripts/generate_lottie_effects.dart) – Generator source
- [AI_ASSET_PIPELINE.md](AI_ASSET_PIPELINE.md) – Fullständig asset pipeline-guide

---

**Sammanfattning:** `Lottie.asset('assets/ui/lottie/ville_walk.json')` → walking Ville! 🚶
