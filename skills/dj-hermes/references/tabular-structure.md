# Tabular-Style Repo Structure Reference

Adapted from `hermes-tabular` for `dj-hermes` (plugin at repo root, the
layout hermes-tabular actually ships and the catalog installs):
- `plugin.yaml` — manifest at repo root
- `__init__.py` — registers the skills with Hermes (`ctx.register_skill`)
- `skills/<skill>/SKILL.md` — skill definition
- `skills/<skill>/defaults.yaml` — policy defaults (not hardcoded in prose)
- `skills/<skill>/references/` — session-specific detail
- `skills/<skill>/templates/` — starter files
- `dashboard/plugin_api.py` — backend
- `desktop/plugin.js` — UI
- `scripts/` — guardrails and helpers
- `charter.md` — scope/principles at repo root
