#!/usr/bin/env python3
"""Validate preserved business files against an incoming generated project."""

from __future__ import annotations

import argparse
import json
import os
import re
from datetime import datetime
from pathlib import Path


def overwrite_paths(project: Path, incoming: Path) -> set[str]:
    result: set[str] = set()
    incoming_source = incoming / "scripts" / "merge-overwrite.txt"
    source = (
        incoming_source
        if incoming_source.is_file()
        else project / "scripts" / "merge-overwrite.txt"
    )
    if not source.is_file():
        return result
    for raw_line in source.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if line and not line.startswith("#"):
            result.add(line.removeprefix("./"))
    return result


def virtual_text(
    project: Path,
    incoming: Path,
    relative: str,
    overwritten: set[str],
) -> str:
    current = project / relative
    replacement = incoming / relative
    use_replacement = replacement.is_file() and (
        not current.is_file()
        or "generated" in replacement.name
        or relative in overwritten
    )
    source = replacement if use_replacement else current
    if not source.is_file():
        return ""
    return source.read_text(encoding="utf-8", errors="replace")


def virtual_files(project: Path, incoming: Path) -> set[str]:
    result: set[str] = set()
    excluded = {
        ".git", ".dependencies", ".artifacts", ".venv", "build", "dist",
        "__pycache__", "node_modules", "target", "tmp",
    }
    for root in (project, incoming):
        if not root.is_dir():
            continue
        for directory, directories, files in os.walk(root):
            directories[:] = sorted(name for name in directories if name not in excluded)
            for name in files:
                source = Path(directory) / name
                relative = source.relative_to(root).as_posix()
                if "/internal/functions/" in f"/{relative}" or name in {
                    "service.generated.go",
                    "service.generated.cpp",
                    "service_generated.py",
                    "service.generated.rs",
                }:
                    result.add(relative)
    return result


def maker_requirements(relative: str, content: str) -> set[str]:
    if relative.endswith(".generated.go"):
        return set(re.findall(r"\bfunctions\.(Make[A-Z][A-Za-z0-9_]*)\b", content))
    if relative.endswith("service.generated.cpp"):
        return set(re.findall(r"\bfunctions::(Make[A-Z][A-Za-z0-9_]*)\b", content))
    if relative.endswith("service_generated.py"):
        requirements: set[str] = set()
        for block in re.findall(
            r"from\s+\.{1,2}functions\s+import\s*\((.*?)\)",
            content,
            flags=re.DOTALL,
        ):
            requirements.update(re.findall(r"\b(make_[a-z][a-z0-9_]*)\b", block))
        return requirements
    if relative.endswith("service.generated.rs"):
        return set(re.findall(r"\bArc::new\((make_[a-z][a-z0-9_]*)\)", content))
    return set()


def definition_pattern(name: str) -> re.Pattern[str]:
    if name.startswith("Make"):
        return re.compile(rf"\b(?:func\s+|inline\s+[^\n]*\s+){re.escape(name)}\s*\(")
    return re.compile(rf"\b(?:pub\s+)?(?:async\s+)?def\s+{re.escape(name)}\s*\(|"
                      rf"\bpub\s+fn\s+{re.escape(name)}\s*\(")


def validate(project: Path, incoming: Path) -> list[dict[str, object]]:
    overwritten = overwrite_paths(project, incoming)
    paths = virtual_files(project, incoming)
    contents = {
        relative: virtual_text(project, incoming, relative, overwritten)
        for relative in paths
    }
    business_content = "\n".join(
        content
        for relative, content in contents.items()
        if "generated" not in Path(relative).name
        and "/internal/functions/" in f"/{relative}"
    )

    issues: list[dict[str, object]] = []
    requirements: set[str] = set()
    for relative, content in contents.items():
        requirements.update(maker_requirements(relative, content))
    for maker in sorted(requirements):
        if not definition_pattern(maker).search(business_content):
            issues.append({
                "code": "SG_MERGE_MIGRATION_REQUIRED",
                "severity": "error",
                "stage": "merge",
                "message": f"Preserved business code is missing required maker `{maker}`.",
                "object": {"kind": "businessFunction", "name": maker},
                "details": {"requiredMaker": maker},
            })

    return issues


def write_task(project: Path, issues: list[dict[str, object]]) -> Path:
    directory = project / ".servicegen" / "migrations"
    directory.mkdir(parents=True, exist_ok=True)
    destination = directory / (
        "merge-" + datetime.now().strftime("%Y%m%d-%H%M%S") + ".md"
    )
    lines = [
        "# Required post-generation migration",
        "",
        "The generated graph changed, but preserved project files do not satisfy its contract.",
        "Complete these items and run `make merge-validate` again:",
        "",
    ]
    lines.extend(f"- [ ] {issue['message']}" for issue in issues)
    lines.append("")
    destination.write_text("\n".join(lines), encoding="utf-8")
    return destination


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project", type=Path, required=True)
    parser.add_argument("--incoming", type=Path)
    parser.add_argument("--write-task", action="store_true")
    parser.add_argument("--format", choices=("human", "json"), default="human")
    args = parser.parse_args()
    project = args.project.resolve()
    incoming = args.incoming.resolve() if args.incoming else project
    issues = validate(project, incoming)
    if not issues:
        if args.format == "json":
            print(json.dumps({
                "schemaVersion": "1.0",
                "status": "succeeded",
                "operation": "merge",
                "diagnostics": [],
                "artifacts": [],
                "summary": {"errors": 0, "warnings": 0},
            }, sort_keys=True))
        else:
            print("Post-merge validation: PASS")
        return 0
    task = None
    if args.write_task:
        task = write_task(project, issues)
    if args.format == "json":
        print(json.dumps({
            "schemaVersion": "1.0",
            "status": "failed",
            "operation": "merge",
            "diagnostics": issues,
            "artifacts": ([] if task is None else [{
                "kind": "migrationTask",
                "uri": task.relative_to(project).as_posix(),
            }]),
            "summary": {"errors": len(issues), "warnings": 0},
        }, sort_keys=True))
    else:
        print("Post-merge validation: ACTION REQUIRED")
        for issue in issues:
            print(f"  MIG  [{issue['code']}] {issue['message']}")
        if task is not None:
            print(f"Migration task: {task.relative_to(project)}")
    return 2


if __name__ == "__main__":
    raise SystemExit(main())