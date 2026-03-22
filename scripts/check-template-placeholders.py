#!/usr/bin/env python3

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
SKIP_DIRS = {".git", ".terraform", ".worktrees", "site"}

EXPECTED = {
    Path("gitops/infrastructure/gateway/gateway.yaml"): [
        "REPLACE_ME_GATEWAY_STATIC_IP_NAME",
        "REPLACE_ME_GATEWAY_HOSTNAME",
        "REPLACE_ME_GATEWAY_CERTIFICATE_MAP_NAME",
    ],
    Path("gitops/infrastructure/gateway/httproute.yaml"): [
        "REPLACE_ME_GATEWAY_HOSTNAME",
    ],
    Path("gitops/clusters/cluster-a/flux-system/gotk-sync.yaml"): [
        "ssh://git@github.com/REPLACE_ME/REPLACE_ME",
        "REPLACE_ME_GIT_BRANCH",
    ],
    Path("gitops/clusters/cluster-b/flux-system/gotk-sync.yaml"): [
        "ssh://git@github.com/REPLACE_ME/REPLACE_ME",
        "REPLACE_ME_GIT_BRANCH",
    ],
}

found = []
unexpected = []

for path in ROOT.rglob("*.yaml"):
    if any(part in SKIP_DIRS for part in path.parts):
        continue
    rel = path.relative_to(ROOT)
    text = path.read_text(encoding="utf-8")
    for token in [
        "REPLACE_ME_GATEWAY_STATIC_IP_NAME",
        "REPLACE_ME_GATEWAY_HOSTNAME",
        "REPLACE_ME_GATEWAY_CERTIFICATE_MAP_NAME",
        "REPLACE_ME_GIT_BRANCH",
        "ssh://git@github.com/REPLACE_ME/REPLACE_ME",
    ]:
        if token in text:
            found.append((rel, token))
            if rel not in EXPECTED or token not in EXPECTED[rel]:
                unexpected.append((rel, token))

for rel, token in found:
    print(f"placeholder: {token} -> {rel}")

if unexpected:
    print("\nunexpected placeholder usage detected:", file=sys.stderr)
    for rel, token in unexpected:
        print(f"  {token} -> {rel}", file=sys.stderr)
    sys.exit(1)

print("\nplaceholder audit passed")
