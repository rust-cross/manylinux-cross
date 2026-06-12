# /// script
# dependencies = ["lastversion>=3.5.0", "packaging", "requests"]
# ///

import argparse
import hashlib
import jinja2
import re
import subprocess
from collections import defaultdict
from pathlib import Path

import requests
from lastversion import latest
from lastversion.version import Version

PROJECT_ROOT = Path(__file__).parent.parent.resolve(strict=True)
DOCKERFILE = PROJECT_ROOT / "Dockerfile.j2"


def _sha256(url):
    response = requests.get(
        url, allow_redirects=True, headers={"Accept": "application/octet-stream"}, stream=True
    )
    response.raise_for_status()
    m = hashlib.sha256()
    for chunk in response.iter_content(chunk_size=65536):
        m.update(chunk)
    return m.hexdigest()


def _update_cpython(dry_run):
    lines = DOCKERFILE.read_text().splitlines()
    re_ = re.compile(r"^\s*VERS=([0-9.]+)")
    updates = defaultdict(list)
    for i in range(len(lines)):
        match = re_.match(lines[i])
        if match is None:
            continue
        version = match.group(1)
        current_version = Version(version)
        latest_version = latest(
            "python/cpython",
            major=f"{current_version.major}.{current_version.minor}",
            pre_ok=current_version.is_prerelease,
        )
        if latest_version > current_version:
            key = (version, str(latest_version))
            if len(updates[key]) == 0:
                root = f"Python-{latest_version}"
                url = f"https://www.python.org/ftp/python/{latest_version.major}.{latest_version.minor}.{latest_version.micro}"
                _sha256(f"{url}/{root}.tar.xz")
            updates[key].append(i)
    for key in updates:
        for i in updates[key]:
            lines[i] = lines[i].replace(key[0], key[1])
        message = f"Bump CPython {key[0]} → {key[1]}"
        print(message)
        if not dry_run:
            DOCKERFILE.write_text("\n".join(lines) + "\n")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", dest="dry_run", action="store_true", help="dry run")
    args = parser.parse_args()
    _update_cpython(args.dry_run)

if __name__ == "__main__":
    main()