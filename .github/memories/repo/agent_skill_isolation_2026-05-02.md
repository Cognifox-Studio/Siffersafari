# Lärdom: Agent-konfiguration och Skill-isolering (2026-05-02)

**Kontext:** Genomgång och uppdatering av AI-agentens instruktioner och automation i Siffersafari.

**Insikt & Regel:**
Projektet använder framgångsrikt principen "Link, don't embed" för att hålla AI-kontexten ren. När vi definierar nya arbetsflöden (som `extract-ui-component` eller `pre-commit-test-guard`) är det bäst att:
1. **Isolera** dem i dedikerade `.github/skills/<namn>/SKILL.md`-filer framför att foga in dem i den centrala `copilot-instructions.md`.
2. **Trigga** dem via starka signalord i `description`-blocket högst upp i filen. 
3. **Länka** till andra instruktionsdokument (t.ex. `.github/instructions/regler-for-att-uppdatera-information-pa-skarmen.instructions.md`) inifrån skillen istället för att upprepa arkitekturregler.

Detta mönster garanterar att Beast Mode och Plan-agenterna förblir blixtsnabba och endast laddar in det arbetsflöde som faktiskt behövs för stunden.