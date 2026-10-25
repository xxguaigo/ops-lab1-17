#!/usr/bin/env bash
# Run in Linux/WSL after each real Release is published. Downloads and reads only.
# Usage: bash scripts/collect-release-evidence.sh v1.0.0 [port]
set -euo pipefail

tag=${1:?Usage: bash scripts/collect-release-evidence.sh v1.0.0 [port]}
case "$tag" in v1.0.0|v1.0.1) ;; *) echo "Expected v1.0.0 or v1.0.1" >&2; exit 2 ;; esac
port=${2:-18080}
if ! [[ "$port" =~ ^[0-9]+$ ]] || (( port < 1024 || port > 65535 )); then
  echo "Port must be between 1024 and 65535" >&2
  exit 2
fi
if [ "$(uname -s)" != Linux ] || [ "$(uname -m)" != x86_64 ]; then
  echo "Run this on an x86_64 Linux/WSL host." >&2
  exit 2
fi
root=$(git rev-parse --show-toplevel)
cd "$root"
git fetch origin main --tags
repo=https://github.com/xxguaigo/ops-lab1-17
version=${tag#v}
pkg=enroll-conflict_${version}_linux_amd64
dir=dist/release
mkdir -p "$dir/evidence"
tmp=$(mktemp -d "$dir/.download.XXXXXX")
pid=
cleanup() {
  if [ -n "$pid" ]; then kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true; fi
  rm -f -- "$tmp/$pkg.tar.gz" "$tmp/$pkg.tar.gz.sha256"
  rmdir -- "$tmp" 2>/dev/null || true
}
trap cleanup EXIT
curl -fL --retry 2 -o "$tmp/$pkg.tar.gz" "$repo/releases/download/$tag/$pkg.tar.gz"
curl -fL --retry 2 -o "$tmp/$pkg.tar.gz.sha256" "$repo/releases/download/$tag/$pkg.tar.gz.sha256"
(cd "$tmp" && sha256sum -c "$pkg.tar.gz.sha256")
current=$(sha256sum "$tmp/$pkg.tar.gz" | cut -d ' ' -f 1)
first="$dir/evidence/$tag.first.sha256"
if [ -f "$first" ]; then
  [ "$(cut -d ' ' -f 1 "$first")" = "$current" ] || {
    echo "Hash changed since the first download; original record kept." >&2; exit 1;
  }
else
  printf '%s  %s.tar.gz\n' "$current" "$pkg" > "$first"
  date -u '+%Y-%m-%dT%H:%M:%SZ' > "$dir/evidence/$tag.first-downloaded-at.txt"
fi
mv -- "$tmp/$pkg.tar.gz" "$tmp/$pkg.tar.gz.sha256" "$dir/"
bash scripts/trace.sh "$dir/$pkg.tar.gz" . origin/main | tee "$dir/evidence/$tag.trace.txt"
tar -xzf "$dir/$pkg.tar.gz" -C "$dir"
# Check the chosen port before starting, and verify that our own process stays up.
python3 - "$port" <<'PY'
import socket, sys
with socket.socket() as s:
    s.bind(('127.0.0.1', int(sys.argv[1])))
PY
"./$dir/$pkg/enroll-conflict" -addr "127.0.0.1:$port" > "$dir/evidence/$tag.service.txt" 2>&1 &
pid=$!
ready=false
for _ in {1..30}; do
  kill -0 "$pid" 2>/dev/null || { echo "Service exited; inspect service log." >&2; exit 1; }
  if curl -fsS "http://127.0.0.1:$port/version" > "$dir/evidence/$tag.version.json"; then
    ready=true; break
  fi
  sleep 0.1
done
[ "$ready" = true ] || { echo "Service did not become ready" >&2; exit 1; }
python3 - "$dir/evidence/$tag.version.json" "$version" <<'PY'
import json, sys
from pathlib import Path
data = json.loads(Path(sys.argv[1]).read_text())
assert data['version'] == sys.argv[2], data
print(json.dumps(data, ensure_ascii=False))
PY
echo "Saved actual Release evidence to $dir/evidence; copy it to LAB1.md."
