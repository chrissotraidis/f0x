#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if git -C "$root_dir" ls-files | grep -Eiq '\.(z64|v64|n64|ndd|o2r|otr|sra|eep|fla|ipa|mobileprovision|p12|cer|key)$'; then
  echo "tracked prohibited game-data or signing artifact" >&2
  exit 1
fi

if git -C "$root_dir" ls-files | grep -Eq '(^|/)(build|artifacts|DerivedData)/'; then
  echo "tracked build artifact directory" >&2
  exit 1
fi

jq empty \
  "$root_dir/assets/AppIcon.xcassets/Contents.json" \
  "$root_dir/assets/AppIcon.xcassets/AppIcon.appiconset/Contents.json"

icon="$root_dir/assets/AppIcon.xcassets/AppIcon.appiconset/AppIcon-1024.png"
icon_info="$(sips -g pixelWidth -g pixelHeight -g hasAlpha "$icon")"
grep -q 'pixelWidth: 1024' <<<"$icon_info"
grep -q 'pixelHeight: 1024' <<<"$icon_info"
grep -q 'hasAlpha: no' <<<"$icon_info"

bash -n \
  "$root_dir/scripts/setup-sources.sh" \
  "$root_dir/scripts/apply-apple-baseline-patches.sh" \
  "$root_dir/scripts/check-repo-safety.sh" \
  "$root_dir/scripts/package-ios.sh"

python3 - "$root_dir" <<'PY'
import pathlib
import re
import sys
import urllib.parse

root = pathlib.Path(sys.argv[1])
missing = []
patterns = [
    re.compile(r'!?(?:\[[^\]]*\])\(([^)]+)\)'),
    re.compile(r'<(?:img|a)\b[^>]+(?:src|href)="([^"]+)"', re.IGNORECASE),
]

for document in [root / "README.md"]:
    text = document.read_text(encoding="utf-8")
    for pattern in patterns:
        for raw_target in pattern.findall(text):
            target = raw_target.strip().strip("<>")
            if target.startswith(("#", "/", "http://", "https://", "mailto:")):
                continue
            target = urllib.parse.unquote(target.split("#", 1)[0].split("?", 1)[0])
            if target and not (document.parent / target).exists():
                missing.append(f"{document.name}: {raw_target}")

if missing:
    print("Missing local README targets:", file=sys.stderr)
    print("\n".join(missing), file=sys.stderr)
    raise SystemExit(1)
PY

git -C "$root_dir" fsck --full --strict --no-dangling
echo "Repository safety checks passed."
