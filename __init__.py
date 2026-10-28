"""dj-hermes — Hermes plugin wrapper around the dj-hermes skill pack.

The skills themselves are plain Markdown under skills/<name>/SKILL.md and
are meant to be adapted, not imported. This plugin simply registers each
skill file with Hermes so the catalog install path works.
"""

from pathlib import Path

# Umbrella first, then sub-skills in invocation order.
SKILLS = [
    "dj-hermes",
    "dj-generate",
    "dj-render",
    "dj-validate",
    "dj-export",
    "dj-listen",
]


def _description(skill_md: Path) -> str:
    """Pull the description from the SKILL.md frontmatter, best effort."""
    try:
        text = skill_md.read_text(encoding="utf-8")
    except OSError:
        return ""
    if not text.startswith("---"):
        return ""
    end = text.find("---", 3)
    if end == -1:
        return ""
    for line in text[3:end].splitlines():
        if line.startswith("description:"):
            return line.split(":", 1)[1].strip().strip('"').strip("'")
    return ""


def register(ctx):
    here = Path(__file__).parent
    for name in SKILLS:
        skill_md = here / "skills" / name / "SKILL.md"
        if skill_md.is_file():
            ctx.register_skill(name, str(skill_md), _description(skill_md))
