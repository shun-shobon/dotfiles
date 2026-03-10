#!/usr/bin/env python3


from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Any, Dict, List, Tuple

try:
    import yaml  # type: ignore
except Exception:  # pragma: no cover
    yaml = None


VALID_NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
LINK_RE = re.compile(r"\[[^\]]+\]\(([^)]+)\)")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate a Codex skill folder for common structural and authoring issues."
    )
    parser.add_argument("path", help="Path to a skill folder or SKILL.md file")
    return parser.parse_args()


def error(msg: str, errors: List[str]) -> None:
    errors.append(msg)


def warn(msg: str, warnings: List[str]) -> None:
    warnings.append(msg)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def parse_frontmatter(text: str) -> Tuple[Dict[str, Any], str, str]:
    if not text.startswith("---\n") and not text.startswith("---\r\n"):
        raise ValueError("SKILL.md must start with YAML frontmatter delimited by ---")
    lines = text.splitlines(keepends=True)
    if not lines or not lines[0].strip() == "---":
        raise ValueError("Frontmatter opening delimiter must be --- on the first line")

    end_idx = None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            end_idx = idx
            break
    if end_idx is None:
        raise ValueError("Frontmatter closing delimiter --- not found")

    frontmatter_text = "".join(lines[1:end_idx])
    body = "".join(lines[end_idx + 1 :]).lstrip()

    if yaml is not None:
        data = yaml.safe_load(frontmatter_text) or {}
        if not isinstance(data, dict):
            raise ValueError("Frontmatter must be a YAML mapping")
        return data, body, frontmatter_text

    data: Dict[str, str] = {}
    for raw_line in frontmatter_text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" not in line:
            raise ValueError(
                "Frontmatter could not be parsed without PyYAML; use simple key: value lines"
            )
        key, value = line.split(":", 1)
        data[key.strip()] = value.strip().strip("'\"")
    return data, body, frontmatter_text


def collect_markdown_links(markdown_text: str) -> List[str]:
    return [m.group(1).strip() for m in LINK_RE.finditer(markdown_text)]


def is_external_link(link: str) -> bool:
    lowered = link.lower()
    return lowered.startswith(("http://", "https://", "mailto:", "#"))


def validate_openai_yaml(path: Path, warnings: List[str], errors: List[str]) -> None:
    if yaml is None:
        warn("PyYAML is not available; skipped structured validation of agents/openai.yaml", warnings)
        return
    try:
        data = yaml.safe_load(read_text(path)) or {}
    except Exception as exc:
        error(f"agents/openai.yaml is not valid YAML: {exc}", errors)
        return
    if not isinstance(data, dict):
        error("agents/openai.yaml must be a YAML mapping", errors)
        return

    interface = data.get("interface")
    if interface is not None and not isinstance(interface, dict):
        error("agents/openai.yaml: interface must be a mapping", errors)
    elif isinstance(interface, dict):
        for field in ("display_name", "short_description", "default_prompt"):
            if field not in interface:
                warn(
                    f"agents/openai.yaml: interface.{field} is recommended for better Codex UI integration",
                    warnings,
                )

    policy = data.get("policy")
    if policy is not None and not isinstance(policy, dict):
        error("agents/openai.yaml: policy must be a mapping", errors)
    elif isinstance(policy, dict) and "allow_implicit_invocation" in policy:
        value = policy["allow_implicit_invocation"]
        if not isinstance(value, bool):
            error("agents/openai.yaml: policy.allow_implicit_invocation must be a boolean", errors)

    dependencies = data.get("dependencies")
    if dependencies is not None and not isinstance(dependencies, dict):
        error("agents/openai.yaml: dependencies must be a mapping", errors)


def main() -> int:
    args = parse_args()
    input_path = Path(args.path).expanduser().resolve()

    errors: List[str] = []
    warnings: List[str] = []

    skill_dir: Path
    skill_md: Path

    if input_path.is_file():
        if input_path.name != "SKILL.md":
            error("When validating a file directly, it must be named exactly SKILL.md", errors)
            skill_md = input_path
            skill_dir = input_path.parent
        else:
            skill_md = input_path
            skill_dir = input_path.parent
    else:
        skill_dir = input_path
        skill_md = skill_dir / "SKILL.md"

    if not skill_dir.exists():
        error(f"Path does not exist: {skill_dir}", errors)
        report(errors, warnings)
        return 2

    if not skill_md.exists():
        error(f"Missing required file: {skill_md}", errors)
        similar = [p.name for p in skill_dir.iterdir() if p.name.lower() == "skill.md"]
        if similar:
            warn(f"Found similar file names instead: {', '.join(similar)}", warnings)
        report(errors, warnings)
        return 2

    folder_name = skill_dir.name
    if not VALID_NAME_RE.match(folder_name):
        error(
            f"Skill folder name must be kebab-case using lowercase letters, digits, and hyphens: {folder_name}",
            errors,
        )

    readme_path = skill_dir / "README.md"
    if readme_path.exists():
        warn("README.md found inside the skill folder. Best practice is to keep human-only docs outside the skill.", warnings)

    extra_docs = [
        p.name
        for p in skill_dir.iterdir()
        if p.is_file() and p.name in {"INSTALLATION_GUIDE.md", "QUICK_REFERENCE.md", "CHANGELOG.md"}
    ]
    if extra_docs:
        warn(f"Found extra documentation files that usually do not belong inside a skill: {', '.join(extra_docs)}", warnings)

    text = read_text(skill_md)
    try:
        data, body, frontmatter_text = parse_frontmatter(text)
    except Exception as exc:
        error(f"Failed to parse frontmatter: {exc}", errors)
        report(errors, warnings)
        return 2

    allowed_keys = {"name", "description"}
    missing_keys = allowed_keys - set(data.keys())
    if missing_keys:
        error(f"Frontmatter missing required keys: {', '.join(sorted(missing_keys))}", errors)

    extra_keys = set(data.keys()) - allowed_keys
    if extra_keys:
        warn(
            f"Frontmatter contains extra keys ({', '.join(sorted(extra_keys))}). Current Codex best practice is to keep only name and description in SKILL.md.",
            warnings,
        )

    name = data.get("name")
    description = data.get("description")

    if not isinstance(name, str) or not name.strip():
        error("Frontmatter name must be a non-empty string", errors)
    else:
        if not VALID_NAME_RE.match(name):
            error(f"Skill name must be kebab-case: {name}", errors)
        if name != folder_name:
            error(f"Skill name must match folder name ({folder_name}): found {name}", errors)

    if not isinstance(description, str) or not description.strip():
        error("Frontmatter description must be a non-empty string", errors)
    else:
        desc = description.strip()
        if len(desc) > 1024:
            warn(
                f"Description is {len(desc)} characters. Keeping it under ~1024 improves trigger hygiene and portability.",
                warnings,
            )
        lowered = desc.lower()
        if not any(phrase in lowered for phrase in ("use when", "when the user", "when user", "use for", "do not use")):
            warn(
                "Description does not obviously include explicit trigger or boundary language such as 'Use when ...' or 'Do not use ...'.",
                warnings,
            )

    if "<" in frontmatter_text or ">" in frontmatter_text:
        warn("Frontmatter contains angle brackets. Avoid them unless you specifically need them.", warnings)

    body_lines = body.splitlines()
    if not body.strip():
        error("SKILL.md body is empty. Add workflow instructions after the frontmatter.", errors)
    elif len(body_lines) > 500:
        warn(f"SKILL.md body is {len(body_lines)} lines. Consider moving detail into references/ to keep it lean.", warnings)

    for file_path in [skill_md] + sorted((skill_dir / "references").glob("*.md")) if (skill_dir / "references").exists() else [skill_md]:
        md_text = read_text(file_path)
        for link in collect_markdown_links(md_text):
            if is_external_link(link):
                continue
            target = (file_path.parent / link).resolve()
            if not target.exists():
                error(f"{file_path.relative_to(skill_dir)} links to missing path: {link}", errors)

    references_dir = skill_dir / "references"
    if references_dir.exists():
        for ref in sorted(references_dir.glob("*.md")):
            line_count = len(read_text(ref).splitlines())
            if line_count > 100:
                head = "\n".join(read_text(ref).splitlines()[:25]).lower()
                if "table of contents" not in head and "## contents" not in head and "## toc" not in head:
                    warn(
                        f"{ref.relative_to(skill_dir)} is {line_count} lines with no obvious table of contents near the top.",
                        warnings,
                    )

    openai_yaml = skill_dir / "agents" / "openai.yaml"
    if openai_yaml.exists():
        validate_openai_yaml(openai_yaml, warnings, errors)

    report(errors, warnings)
    return 2 if errors else 0


def report(errors: List[str], warnings: List[str]) -> None:
    print("Skill validation report")
    print("=======================")
    if errors:
        print("\nErrors:")
        for item in errors:
            print(f"- {item}")
    if warnings:
        print("\nWarnings:")
        for item in warnings:
            print(f"- {item}")
    if not errors and not warnings:
        print("\nNo issues found.")
    elif not errors:
        print("\nValidation passed with warnings.")
    else:
        print("\nValidation failed.")


if __name__ == "__main__":
    raise SystemExit(main())
