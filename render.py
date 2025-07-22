#!/usr/bin/env python3
import os

from jinja2 import Environment, DictLoader, select_autoescape


MANYLINUX2014_CT_NG_VERSION = "02d1503f6769be4ad8058b393d4245febced459f"
MANYLINUX2014_TOOLCHAIN_OS = "ubuntu:20.04"
MANYLINUX_2_28_CT_NG_VERSION = "crosstool-ng-1.25.0"

TOOLCHAIN_OS = "ubuntu:22.04"

IMAGES = {
    "manylinux2014": [
        {
            "arch": "aarch64",
            "manylinux": "quay.io/pypa/manylinux2014_aarch64",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "toolchain_os": MANYLINUX2014_TOOLCHAIN_OS,
            "target": "aarch64-unknown-linux-gnu",
        },
        {
            "arch": "armv7l",
            "cmake_arch": "armv7",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "toolchain_os": MANYLINUX2014_TOOLCHAIN_OS,
            "target": "armv7-unknown-linux-gnueabihf",
        },
        {
            "arch": "i686",
            "manylinux": "quay.io/pypa/manylinux2014_i686",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "toolchain_os": MANYLINUX2014_TOOLCHAIN_OS,
            "target": "i686-unknown-linux-gnu",
        },
        {
            "arch": "ppc64",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "toolchain_os": MANYLINUX2014_TOOLCHAIN_OS,
            "target": "powerpc64-unknown-linux-gnu",
        },
        {
            "arch": "ppc64le",
            "manylinux": "quay.io/pypa/manylinux2014_ppc64le",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "toolchain_os": MANYLINUX2014_TOOLCHAIN_OS,
            "target": "powerpc64le-unknown-linux-gnu",
        },
        {
            "arch": "s390x",
            "manylinux": "quay.io/pypa/manylinux2014_s390x",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "toolchain_os": MANYLINUX2014_TOOLCHAIN_OS,
            "target": "s390x-ibm-linux-gnu",
        },
        {
            "arch": "x86_64",
            "manylinux": "quay.io/pypa/manylinux2014_x86_64",
            "ct_ng_version": MANYLINUX2014_CT_NG_VERSION,
            "toolchain_os": MANYLINUX2014_TOOLCHAIN_OS,
            "target": "x86_64-unknown-linux-gnu",
        },
    ],
    "manylinux_2_28": [
        {
            "arch": "aarch64",
            "manylinux": "quay.io/pypa/manylinux_2_28_aarch64",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "toolchain_os": TOOLCHAIN_OS,
            "target": "aarch64-unknown-linux-gnu",
        },
        {
            "arch": "ppc64le",
            "manylinux": "quay.io/pypa/manylinux_2_28_ppc64le",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "toolchain_os": TOOLCHAIN_OS,
            "target": "powerpc64le-unknown-linux-gnu",
        },
        {
            "arch": "x86_64",
            "manylinux": "quay.io/pypa/manylinux_2_28_x86_64",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "toolchain_os": TOOLCHAIN_OS,
            "target": "x86_64-unknown-linux-gnu",
        },
        {
            "arch": "armv7l",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "toolchain_os": TOOLCHAIN_OS,
            "target": "armv7-unknown-linux-gnueabihf",
        },
        {
            "arch": "s390x",
            "ct_ng_version": MANYLINUX_2_28_CT_NG_VERSION,
            "toolchain_os": TOOLCHAIN_OS,
            "target": "s390x-ibm-linux-gnu",
        },
    ],
    "manylinux_2_31": [
        {
            "arch": "riscv64",
            "ct_ng_version": "crosstool-ng-1.27.0",
            "toolchain_os": TOOLCHAIN_OS,
            "target": "riscv64-unknown-linux-gnu",
        },
    ],
    "manylinux_2_36": [
        {
            "arch": "loongarch64",
            "ct_ng_version": "crosstool-ng-1.27.0",
            "toolchain_os": TOOLCHAIN_OS,
            "target": "loongarch64-unknown-linux-gnu",
        },
    ],
    "manylinux_2_39": [
        {
            "arch": "riscv64",
            "manylinux": "quay.io/pypa/manylinux_2_39_riscv64",
            "ct_ng_version": "crosstool-ng-1.27.0",
            "toolchain_os": TOOLCHAIN_OS,
            "target": "riscv64-unknown-linux-gnu",
        },
    ],
    "musllinux_1_2": [
        {
            "arch": "aarch64",
            "musllinux": "quay.io/pypa/musllinux_1_1_aarch64",
            "base": "messense/rust-musl-cross:aarch64-musl",
            "target": "aarch64-unknown-linux-musl",
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
        {
            "arch": "loongarch64",
            "ct_ng_version": "crosstool-ng-1.27.0",
            "toolchain_os": TOOLCHAIN_OS,
            "target": "loongarch64-unknown-linux-musl",
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
            arch = image["arch"]
            output = template.render(platform=platform, **image)
            folder = os.path.join(platform, arch)
            os.makedirs(folder, exist_ok=True)
            with open(os.path.join(folder, "Dockerfile"), "w", newline='\n') as f:
                f.write(output)


if __name__ == "__main__":
    main()
