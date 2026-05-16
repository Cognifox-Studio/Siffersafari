---
name: "release-go-no-go"
description: "Gör en kort go/no-go-bedömning inför demo, handoff, taggning eller Play-flöde i Siffersafari med rätt QA- och policykontroller"
argument-hint: "Beskriv om det gäller demo, intern överlämning, closed beta eller skarp release"
agent: "agent"
---

Gör en snabb men defensibel go/no-go-bedömning för aktuell releaseyta utan att missa policy, versionsdrift eller fel QA-nivå.

Utgå från dessa källor:

- [docs/SESSION_BRIEF.md](../../docs/SESSION_BRIEF.md)
- [docs/DEPLOY_ANDROID.md](../../docs/DEPLOY_ANDROID.md)
- [.github/copilot-instructions.md](../copilot-instructions.md)
- [.github/skills/kolla-om-appen-ar-redo-att-slappas/SKILL.md](../skills/kolla-om-appen-ar-redo-att-slappas/SKILL.md)
- [.github/skills/verifiera-coppa-regler/SKILL.md](../skills/verifiera-coppa-regler/SKILL.md)
- [pubspec.yaml](../../pubspec.yaml)
- [android/app/build.gradle.kts](../../android/app/build.gradle.kts)
- [.github/workflows/build.yml](../workflows/build.yml)
- [.github/workflows/play-closed-beta.yml](../workflows/play-closed-beta.yml)

Arbetsordning:

1. Klassificera målet: demo, intern handoff, closed beta eller skarp release.
2. Välj minsta rimliga QA-slice för just den releaseytan och kör den i stället för att hoppa direkt till fullsvit.
3. Kontrollera att version, artifacts, workflow och releaseväg matchar scope.
4. Om Android- eller Play-flödet berörs: gör även en liten COPPA- och policykontroll.
5. Avsluta med `Go`, `Soft go` eller `No-go` och ange exakt vad som blockerar eller återstår.

Go/No-go-format:

- `Go`: inga kända blockerare i verifierad releaseyta.
- `Soft go`: låg risk återstår, men inte releaseblockerande.
- `No-go`: analyze-, test-, policy-, versions- eller deviceblockerare finns.

Svarskrav:

- Lista blockerare först.
- Ange vad som faktiskt verifierades, inte bara vad som borde ha körts.
- Nämn minsta nästa steg om status inte är ren `Go`.
