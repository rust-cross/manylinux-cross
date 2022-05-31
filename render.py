#!/usr/bin/env python3
import os

from jinja2 import Environment, DictLoader, select_autoescape


MANYLINUX2014_CT_NG_VERSION = "02d1503f6769be4ad8058b393d4245febced459f"
MANYLINUX_2_24_CT_NG_VERSION = "crosstool-ng-1.25.0"
MANYLINUX_2_28_CT_NG_VERSION = MANYLINUX_2_24_CT_NG_VERSION

IMAGES = {
    "manylinux2014": [
        {
            "arch": "aarch64",
            "manylinux": "quay.io/pypa/manylinux2014_aarch64",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "target": "aarch64-unknown-linux-gnu",
        },
        {
            "arch": "armv7l",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "target": "armv7-unknown-linux-gnueabihf",
        },
        {
            "arch": "i686",
            "manylinux": "quay.io/pypa/manylinux2014_i686",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "target": "i686-unknown-linux-gnu",
        },
        {
            "arch": "ppc64",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "target": "powerpc64-unknown-linux-gnu",
        },
        {
            "arch": "ppc64le",
            "manylinux": "quay.io/pypa/manylinux2014_ppc64le",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "target": "powerpc64le-unknown-linux-gnu",
        },
        {
            "arch": "s390x",
            "manylinux": "quay.io/pypa/manylinux2014_s390x",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "target": "s390x-ibm-linux-gnu",
        },
        {
            "arch": "x86_64",
            "manylinux": "quay.io/pypa/manylinux2014_x86_64",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "target": "x86_64-unknown-linux-gnu",
        },
    ],
    "manylinux_2_24": [
        {
            "arch": "aarch64",
            "manylinux": "quay.io/pypa/manylinux_2_24_aarch64",
            "ct_ng_version": MANYLINUX_2_24_CT_NG_VERSION,
            "target": "aarch64-unknown-linux-gnu",
        },
        {
            "arch": "armv7l",
            "ct_ng_version": MANYLINUX_2_24_CT_NG_VERSION,
            "target": "armv7-unknown-linux-gnueabihf",
        },
        {
            "arch": "i686",
            "manylinux": "quay.io/pypa/manylinux_2_24_i686",
            "ct_ng_version": MANYLINUX_2_24_CT_NG_VERSION,
            "target": "i686-unknown-linux-gnu",
        },
        {
            "arch": "ppc64le",
            "manylinux": "quay.io/pypa/manylinux_2_24_ppc64le",
            "ct_ng_version": MANYLINUX_2_24_CT_NG_VERSION,
            "target": "powerpc64le-unknown-linux-gnu",
        },
        {
            "arch": "s390x",
            "manylinux": "quay.io/pypa/manylinux_2_24_s390x",
            "ct_ng_version": MANYLINUX_2_24_CT_NG_VERSION,
            "target": "s390x-ibm-linux-gnu",
        },
        {
            "arch": "x86_64",
            "manylinux": "quay.io/pypa/manylinux_2_24_x86_64",
            "ct_ng_version": MANYLINUX_2_24_CT_NG_VERSION,
            "target": "x86_64-unknown-linux-gnu",
        },
    ],
    "manylinux_2_28": [
        {
            "arch": "aarch64",
            "manylinux": "quay.io/pypa/manylinux_2_28_aarch64",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "target": "aarch64-unknown-linux-gnu",
        },
        {
            "arch": "ppc64le",
            # Upstream Docker image isn't ready
            # "manylinux": "quay.io/pypa/manylinux_2_28_ppc64le",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "target": "powerpc64le-unknown-linux-gnu",
        },
        {
            "arch": "x86_64",
            "manylinux": "quay.io/pypa/manylinux_2_28_x86_64",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "target": "x86_64-unknown-linux-gnu",
        },
        {
            "arch": "armv7l",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "target": "armv7-unknown-linux-gnueabihf",
        },
        {
            "arch": "s390x",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "target": "s390x-ibm-linux-gnu",
        },
    ],
    "musllinux_1_2": [
        {
            "arch": "aarch64",
            "musllinux": "quay.io/pypa/musllinux_1_1_aarch64",
            "base": "messense/rust-musl-cross:aarch64-musl",
            "target": "aarch64-unknown-linux-gnu",
        },
        {
            "arch": "armv7l",
            "base": "messense/rust-musl-cross:armv7-musleabihf",
            "target": "armv7-unknown-linux-musleabihf",
        },
        {
            "arch": "i686",
            "musllinux": "quay.io/pypa/musllinux_1_1_i686",
            "base": "messense/rust-musl-cross:i686-musl",
        },
        {
            "arch": "x86_64",
            "musllinux": "quay.io/pypa/musllinux_1_1_x86_64",
            "base": "messense/rust-musl-cross:x86_64-musl",
        },
    ],
}

with open("Dockerfile.j2") as f:
    env = Environment(
        loader=DictLoader(
            {
                "dockerfile": f.read(),
            }
        ),
        autoescape=select_autoescape(),
    )


def main():
    template = env.get_template("dockerfile")
    for platform, images in IMAGES.items():
        for image in images:
            arch = image.pop("arch")
            output = template.render(**image)
            folder = os.path.join(platform, arch)
            os.makedirs(folder, exist_ok=True)
            with open(os.path.join(folder, "Dockerfile"), "w") as f:
                f.write(output)


if __name__ == "__main__":
    main()
