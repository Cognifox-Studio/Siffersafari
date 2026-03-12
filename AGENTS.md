## Skills
A skill is a set of local instructions to follow that is stored in a `SKILL.md` file. Below is the list of skills that can be used. Each entry includes a name, description, and file path so you can open the source for full instructions when using a specific skill.

### Available skills
- imagegen: Use when the user asks to generate or edit images via the OpenAI Image API (for example: generate image, edit/inpaint/mask, background removal or replacement, transparent background, product shots, concept art, covers, or batch variants); run the bundled CLI (`scripts/image_gen.py`) and require `OPENAI_API_KEY` for live calls. (file: C:/Users/Ropbe/.codex/skills/imagegen/SKILL.md)
- openai-docs: Use when the user asks how to build with OpenAI products or APIs and needs up-to-date official documentation with citations, help choosing the latest model for a use case, or explicit GPT-5.4 upgrade and prompt-upgrade guidance; prioritize OpenAI docs MCP tools, use bundled references only as helper context, and restrict any fallback browsing to official OpenAI domains. (file: C:/Users/Ropbe/.codex/skills/.system/openai-docs/SKILL.md)
- skill-creator: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Codex's capabilities with specialized knowledge, workflows, or tool integrations. (file: C:/Users/Ropbe/.codex/skills/.system/skill-creator/SKILL.md)
- skill-installer: Install Codex skills into $CODEX_HOME/skills from a curated list or a GitHub repo path. Use when a user asks to list installable skills, install a curated skill, or install a skill from another repo (including private repos). (file: C:/Users/Ropbe/.codex/skills/.system/skill-installer/SKILL.md)
- animation-preview-lab: Refine animation previews for characters in inline SVG or HTML preview labs. Use when working on idle, walk, pivot, wave, T-pose, clean preview, motion-lab tuning, articulation, stable lower body, or when files live under artifacts/animation_preview. (file: .github/skills/animation-preview-lab/SKILL.md)
- asset-generation-runner: Generate or regenerate game assets for Siffersafari. Use when changing character specs, SVG parts, Lottie effects, Rive blueprints, composite SVG output, or when the user says generate assets, regenerera assets, rebuild visuals, uppdatera animation assets, or sync generated files. (file: .github/skills/asset-generation-runner/SKILL.md)
- flutter-qa-guard: Run focused Flutter QA for this repo. Use when validating analyze, widget tests, integration tests, screenshot regression, Pixel_6 sync/install, asset integration, or when the user asks verify, testa, QA, regression, or analyze after code or asset changes. (file: .github/skills/flutter-qa-guard/SKILL.md)
- game-character-pipeline: Create a usable, game-ready character pipeline from an image, concept, or existing preview. Use when the user asks for spelklar karaktär, användbar karaktär, SVG layers, rig spec, animation spec, Rive guide, character pipeline, mascot rebuild, or Gör en användbar karaktär av denna. (file: .github/skills/game-character-pipeline/SKILL.md)
- release-readiness-check: Prepare and verify this repo for demo, handoff, or release. Use when the user asks release check, readiness, ship, preflight, tag, APK verification, final QA, or wants a last pass over assets, tests, Pixel_6 install, docs, and version consistency. (file: .github/skills/release-readiness-check/SKILL.md)

### How to use skills
- Discovery: The list above is the skills available in this session (name + description + file path). Skill bodies live on disk at the listed paths.
- Trigger rules: If the user names a skill (with `$SkillName` or plain text) OR the task clearly matches a skill's description shown above, you must use that skill for that turn. Multiple mentions mean use them all. Do not carry skills across turns unless re-mentioned.
- Missing/blocked: If a named skill isn't in the list or the path can't be read, say so briefly and continue with the best fallback.
- How to use a skill (progressive disclosure):
  1) After deciding to use a skill, open its `SKILL.md`. Read only enough to follow the workflow.
  2) When `SKILL.md` references relative paths (e.g., `scripts/foo.py`), resolve them relative to the skill directory listed above first, and only consider other paths if needed.
  3) If `SKILL.md` points to extra folders such as `references/`, load only the specific files needed for the request; don't bulk-load everything.
  4) If `scripts/` exist, prefer running or patching them instead of retyping large code blocks.
  5) If `assets/` or templates exist, reuse them instead of recreating from scratch.
- Coordination and sequencing:
  - If multiple skills apply, choose the minimal set that covers the request and state the order you'll use them.
  - Announce which skill(s) you're using and why (one short line). If you skip an obvious skill, say why.
- Context hygiene:
  - Keep context small: summarize long sections instead of pasting them; only load extra files when needed.
  - Avoid deep reference-chasing: prefer opening only files directly linked from `SKILL.md` unless you're blocked.
  - When variants exist (frameworks, providers, domains), pick only the relevant reference file(s) and note that choice.
- Safety and fallback: If a skill can't be applied cleanly (missing files, unclear instructions), state the issue, pick the next-best approach, and continue.
