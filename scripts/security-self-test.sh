#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  MrHunter scanner self-test
#
#  Proves the CI's SAST + secret rules actually detect the plugin's own
#  intentionally-vulnerable fixtures (MrHunter/test-cases/). If a rule drifts or
#  breaks, this fails — so we never ship a scanner that misses its own checks.
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

echo "== MrHunter scanner self-test vs MrHunter/test-cases/ =="

# ── SAST: custom rules must detect the fixtures ─────────────────────────────
python3 -m pip install --quiet semgrep
SAST=$(semgrep scan --config .semgrep/mrhunter.yml MrHunter/test-cases --json --quiet 2>/dev/null \
  | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('results', [])))")
echo "SAST findings on test-cases : $SAST"
if [ "$SAST" -lt 15 ]; then
  echo "FAIL: SAST rules found only $SAST findings (expected >= 15)."
  exit 1
fi

# ── Secrets: Gitleaks (with the fixture allowlist stripped) must detect them ─
sed '/^\[allowlist\]/,$d' .gitleaks.toml > /tmp/gl-selftest.toml
GL_VER=8.21.2
curl -sSL "https://github.com/gitleaks/gitleaks/releases/download/v${GL_VER}/gitleaks_${GL_VER}_linux_x64.tar.gz" \
  | tar -xz -C /tmp gitleaks
/tmp/gitleaks detect --source MrHunter/test-cases --config /tmp/gl-selftest.toml \
  --no-git --report-format json --report-path /tmp/gl.json >/dev/null 2>&1 || true
SECRETS=$(python3 -c "import json; print(len(json.load(open('/tmp/gl.json'))))" 2>/dev/null || echo 0)
echo "Secret findings on test-cases: $SECRETS"
if [ "$SECRETS" -lt 3 ]; then
  echo "FAIL: secret rules found only $SECRETS findings (expected >= 3)."
  exit 1
fi

echo "Self-test PASSED — scanners are aligned with the test-cases."
