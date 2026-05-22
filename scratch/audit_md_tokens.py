from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class MdStat:
    path: str
    bytes: int
    est_tokens: int
    category: str


def estimate_tokens(byte_count: int) -> int:
    # Heuristic for relative ranking only.
    return int(round(byte_count / 4.0))


def categorize(rel_path: str) -> str:
    p = rel_path.replace("\\", "/")
    if p in ("docs/brief.md", "docs/plans/master-plan.md", "CHANGELOG.md", "docs/BRD_SUMMARY.md"):
        return "Core"
    if p.startswith("docs/") or p.startswith("reconnect_backend/docs/") or p.startswith("reconnect_app/docs/"):
        return "Reference"
    if p.startswith(".claude/"):
        return "Tooling"
    return "Other"


def collect_md(repo_root: Path) -> list[MdStat]:
    stats: list[MdStat] = []
    for file_path in repo_root.rglob("*.md"):
        if not file_path.is_file():
            continue
        rel = file_path.relative_to(repo_root).as_posix()
        size = file_path.stat().st_size
        stats.append(
            MdStat(
                path=rel,
                bytes=size,
                est_tokens=estimate_tokens(size),
                category=categorize(rel),
            )
        )
    stats.sort(key=lambda s: (s.est_tokens, s.bytes), reverse=True)
    return stats


def render_table(items: list[MdStat], limit: int = 30) -> str:
    lines = []
    lines.append("| Path | Bytes | Est. tokens | Category |")
    lines.append("|---|---:|---:|---|")
    for s in items[:limit]:
        lines.append(f"| `{s.path}` | {s.bytes} | {s.est_tokens} | {s.category} |")
    return "\n".join(lines)


def main() -> None:
    repo_root = Path(os.getcwd()).resolve()
    stats = collect_md(repo_root)
    out = repo_root / "docs" / "TOKEN_AUDIT.generated.md"
    out.parent.mkdir(parents=True, exist_ok=True)

    content = "\n".join(
        [
            "# Markdown Token Audit (Generated)",
            "",
            "Heuristic estimate: `bytes/4` (for relative ranking only).",
            "",
            render_table(stats, limit=50),
            "",
        ]
    )
    out.write_text(content, encoding="utf-8")
    print(f"Wrote: {out}")


if __name__ == "__main__":
    main()

