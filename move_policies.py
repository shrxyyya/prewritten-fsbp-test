#!/usr/bin/env python3
"""
Move all *.policy.hcl and *.policytest.hcl files from resource subdirectories
into a flat top-level policies/ folder.

Usage:
    python move_policies.py [--dry-run] [--base-dir PATH]

Options:
    --dry-run    Print what would happen without moving any files.
    --base-dir   Root directory to operate on (default: directory of this script).
"""

import argparse
import shutil
import sys
from pathlib import Path


def collect_files(base: Path) -> list[tuple[Path, Path]]:
    """Return (src, dst) pairs for every policy/policytest file found."""
    extensions = (".policy.hcl", ".policytest.hcl")
    policies_dir = base / "policies"
    pairs: list[tuple[Path, Path]] = []

    for src in sorted(base.rglob("*")):
        # Skip anything already inside policies/ or inside .git/
        if policies_dir in src.parents or ".git" in src.parts:
            continue
        if src.is_file() and any(src.name.endswith(ext) for ext in extensions):
            dst = policies_dir / src.name
            pairs.append((src, dst))

    return pairs


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Print moves without executing them.")
    parser.add_argument("--base-dir", default=None, help="Root directory (default: script location).")
    args = parser.parse_args()

    base = Path(args.base_dir).resolve() if args.base_dir else Path(__file__).resolve().parent
    policies_dir = base / "policies"
    pairs = collect_files(base)

    if not pairs:
        print("No .policy.hcl or .policytest.hcl files found — nothing to do.")
        sys.exit(0)

    if not args.dry_run:
        policies_dir.mkdir(exist_ok=True)

    conflicts = [dst for _, dst in pairs if dst.exists()]
    if conflicts:
        print("ERROR: the following destination files already exist:")
        for c in conflicts:
            print(f"  {c.relative_to(base)}")
        print("Resolve conflicts (duplicate filenames across resource folders) before proceeding.")
        sys.exit(1)

    for src, dst in pairs:
        rel_src = src.relative_to(base)
        rel_dst = dst.relative_to(base)
        if args.dry_run:
            print(f"[dry-run] {rel_src}  →  {rel_dst}")
        else:
            shutil.move(str(src), str(dst))
            print(f"Moved:    {rel_src}  →  {rel_dst}")

    print(f"\n{'[dry-run] Would move' if args.dry_run else 'Moved'} {len(pairs)} file(s) into policies/")


if __name__ == "__main__":
    main()
