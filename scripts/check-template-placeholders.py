#!/usr/bin/env python3

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]

EXPECTED = {
    Path("gitops/infrastructure/gateway/gateway.yaml"): [
        "REPLACE_ME_GATEWAY_STATIC_IP_NAME",
        "REPLACE_ME_GATEWAY_HOSTNAME",
    ],
    Path("gitops/infrastructure/gateway/httproute.yaml"): [
        "REPLACE_ME_GATEWAY_HOSTNAME",
    ],
    Path("gitops/clusters/cluster-a/apps-sample.yaml"): [
        "https://github.com/REPLACE_ME/REPLACE_ME",
    ],
    Path("gitops/clusters/cluster-b/apps-sample.yaml"): [
        "https://github.com/REPLACE_ME/REPLACE_ME",
    ],
}

found = []
unexpected = []

for path in ROOT.rglob("*.yaml"):
    rel = path.relative_to(ROOT)
    text = path.read_text(encoding="utf-8")
    for token in [
        "REPLACE_ME_GATEWAY_STATIC_IP_NAME",
        "REPLACE_ME_GATEWAY_HOSTNAME",
        "https://github.com/REPLACE_ME/REPLACE_ME",
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
