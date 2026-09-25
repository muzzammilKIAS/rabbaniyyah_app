#!/usr/bin/env python3
"""Content-preservation guard for rabbaniyyah_app.

  python3 tool/content_check/content_check.py snapshot   # record baseline
  python3 tool/content_check/content_check.py verify     # compare against it

The snapshot records:
  * every Dart string literal under lib/ that contains Arabic script
    (the syllabus text, titles, instructions, dalil) plus every literal in
    lib/data/curriculum.dart (Malay meanings included);
  * SHA-256 of lib/data/curriculum.dart;
  * SHA-256 of every file under assets/ (images, video, audio, fonts).

`verify` fails if any recorded literal no longer appears anywhere under
lib/, if curriculum.dart changed, or if an asset vanished/changed.
Literals that moved between files still pass: the check is "text still
exists in the app", not "text is still on the same line".
"""
import hashlib
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
LIB = ROOT / "lib"
ASSETS = ROOT / "assets"
CURRICULUM = LIB / "data" / "curriculum.dart"
SNAPSHOT = pathlib.Path(__file__).with_name("baseline_content_snapshot.json")
# UI-only strings removed on purpose, each with its reason (never syllabus text).
APPROVED = pathlib.Path(__file__).with_name("approved_removals.json")
ARABIC = re.compile(r"[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]")

# Single- or double-quoted Dart literal (no raw/triple support needed here).
LITERAL = re.compile(r"""'((?:[^'\\\n]|\\.)*)'|"((?:[^"\\\n]|\\.)*)\"""")


def literals(path: pathlib.Path):
    text = path.read_text(encoding="utf-8")
    out = []
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("//") or stripped.startswith("import ") or stripped.startswith("export "):
            continue
        for m in LITERAL.finditer(line):
            s = m.group(1) if m.group(1) is not None else m.group(2)
            if s:
                out.append(s)
    return out


def collect():
    content = {}
    for f in sorted(LIB.rglob("*.dart")):
        rel = str(f.relative_to(ROOT))
        keep_all = f == CURRICULUM
        for s in literals(f):
            if keep_all or ARABIC.search(s):
                content.setdefault(s, rel)
    return content


def sha(p: pathlib.Path):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def assets():
    return {str(p.relative_to(ROOT)): sha(p) for p in sorted(ASSETS.rglob("*")) if p.is_file()}


def all_lib_text():
    return "\n".join(f.read_text(encoding="utf-8") for f in LIB.rglob("*.dart"))


def snapshot():
    content = collect()
    data = {
        "curriculum_sha256": sha(CURRICULUM),
        "strings": [{"text": k, "file": v} for k, v in content.items()],
        "assets": assets(),
    }
    SNAPSHOT.write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"snapshot: {len(content)} strings, {len(data['assets'])} assets -> {SNAPSHOT.relative_to(ROOT)}")


def verify():
    data = json.loads(SNAPSHOT.read_text(encoding="utf-8"))
    corpus = all_lib_text()
    approved = json.loads(APPROVED.read_text(encoding="utf-8")) if APPROVED.exists() else {}
    gone = [e for e in data["strings"] if e["text"] not in corpus]
    missing = [e for e in gone if e["text"] not in approved]
    accepted = [e for e in gone if e["text"] in approved]
    cur_ok = sha(CURRICULUM) == data["curriculum_sha256"]
    now_assets = assets()
    lost_assets = [k for k in data["assets"] if k not in now_assets]
    changed_assets = [k for k, v in data["assets"].items() if k in now_assets and now_assets[k] != v]

    print(f"strings checked : {len(data['strings'])}")
    print(f"strings missing : {len(missing)}")
    for e in missing:
        print(f"   - [{e['file']}] {e['text']}")
    print(f"approved removals: {len(accepted)} (see approved_removals.json)")
    for e in accepted:
        print(f"   ~ [{e['file']}] {e['text']} — {approved[e['text']]}")
    print(f"curriculum.dart : {'UNCHANGED' if cur_ok else 'CHANGED'}")
    print(f"assets checked  : {len(data['assets'])} (lost {len(lost_assets)}, changed {len(changed_assets)})")
    for k in lost_assets + changed_assets:
        print(f"   - {k}")
    ok = not missing and cur_ok and not lost_assets and not changed_assets
    print("RESULT: PASS" if ok else "RESULT: FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "verify"
    if cmd == "snapshot":
        snapshot()
    else:
        sys.exit(verify())
