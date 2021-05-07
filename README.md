# manylinux2014-cross

[![Docker Image](https://img.shields.io/docker/pulls/messense/manylinux2014-cross.svg?maxAge=2592000)](https://hub.docker.com/r/messense/manylinux2014-cross/)
[![Build](https://github.com/messense/manylinux2014-cross-arm/workflows/Build/badge.svg)](https://github.com/messense/manylinux2014-cross-arm/actions?query=workflow%3ABuild)

manylinux2014 aarch64/armv7l/s390x cross compilation docker images, supports both x86_64(amd64) and aarch64(arm64) architectures.

| Architecture |      OS      |       Tag       |        GCC          |          Target Python                     |       Host Python     |
| ------------ | ------------ | --------------- | ------------------- | ------------------------------------------ |-----------------------|
| aarch64      | Ubuntu 20.04 | aarch64         | 4.8.5               |  Copied from manylinux2014_aarch64         | Python 3.6 - 3.9      |
| armv7l       | Ubuntu 20.04 | armv7l / armv7  | 4.8.5               |  `/opt/python/cp3[6-9]`, built from source | Python 3.6 - 3.9      |
| s390x        | Ubuntu 20.04 | s390x           | 4.8.5               |  Copied from manylinux2014_s390x           | Python 3.6 - 3.9      |

Target cross compilers and [maturin](https://github.com/PyO3/maturin) are installed in the image.

## Environment variables

Following list of environment variables are set:

* `TARGET_CC`
* `TARGET_CXX`
* `TARGET_AR`
* `TARGET_SYSROOT`
* `TARGET_C_INCLUDE_PATH`
* `CARGO_BUILD_TARGET`
* `CARGO_TARGET_${target}_LINKER`
