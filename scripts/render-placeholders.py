#!/usr/bin/env python3
import os
import pathlib

root = pathlib.Path(__file__).resolve().parents[1]
replacements = {
    "REPLACE_ME_GATEWAY_STATIC_IP_NAME": os.environ.get("GATEWAY_STATIC_IP_NAME", ""),
    "REPLACE_ME_GATEWAY_HOSTNAME": os.environ.get("GATEWAY_HOSTNAME", ""),
    "REPLACE_ME_GATEWAY_CERTIFICATE_MAP_NAME": os.environ.get("GATEWAY_CERTIFICATE_MAP_NAME", ""),
    "REPLACE_ME_GIT_BRANCH": os.environ.get("GIT_BRANCH", ""),
    "ssh://git@github.com/REPLACE_ME/REPLACE_ME": os.environ.get("GIT_REPOSITORY_SSH_URL", ""),
}

for file in root.rglob("*.yaml"):
    text = file.read_text(encoding="utf-8")
    original = text
    for src, dst in replacements.items():
        if dst:
            text = text.replace(src, dst)
    if text != original:
        file.write_text(text, encoding="utf-8")
        print(f"updated {file.relative_to(root)}")
