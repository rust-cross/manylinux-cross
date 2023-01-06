# manylinux-cross

[![manylinux2014 Docker Image](https://img.shields.io/docker/pulls/messense/manylinux2014-cross.svg?maxAge=2592000&label=manylinux2014)](https://hub.docker.com/r/messense/manylinux2014-cross/)
[![manylinux_2_28 Docker Image](https://img.shields.io/docker/pulls/messense/manylinux_2_28-cross.svg?maxAge=2592000&label=manylinux_2_28)](https://hub.docker.com/r/messense/manylinux_2_28-cross/)
[![Test](https://github.com/rust-cross/manylinux-cross/workflows/Test/badge.svg)](https://github.com/rust-cross/manylinux-cross/actions?query=workflow%3ATest)
[![Bors enabled](https://bors.tech/images/badge_small.svg)](https://app.bors.tech/repositories/58198)

manylinux2014 and manylinux_2_28 aarch64/armv7l/s390x/ppc64le cross compilation docker images,
supports both x86_64(amd64) and aarch64(arm64) architectures.

## manylinux2014

Docker image repository: [messense/manylinux2014-cross], based on Ubuntu 22.04 with **GCC 4.8.5**.

| Architecture |      Tag        |          Target Python                     |       Host Python      |
| ------------ | --------------- | ------------------------------------------ | ---------------------- |
| x86_64       | x86_64          | Copied from manylinux2014_x86_64           | Python 3.7 - 3.11      |
| i686         | i686            | Copied from manylinux2014_i686             | Python 3.7 - 3.11      |
| aarch64      | aarch64         | Copied from manylinux2014_aarch64          | Python 3.7 - 3.11      |
| armv7l       | armv7l / armv7  | `/opt/python/cp3[7-11]`, built from source | Python 3.7 - 3.11      |
| s390x        | s390x           | Copied from manylinux2014_s390x            | Python 3.7 - 3.11      |
| ppc64        | ppc64           | `/opt/python/cp3[7-11]`, built from source | Python 3.7 - 3.11      |
| ppc64le      | ppc64le         | Copied from manylinux2014_ppc64le          | Python 3.7 - 3.11      |

## manylinux_2_28

Docker image repository: [messense/manylinux_2_28-cross], based on Ubuntu 22.04 with **GCC 7.5.0**.

| Architecture |      Tag        |          Target Python                     |       Host Python      |
| ------------ | --------------- | ------------------------------------------ | ---------------------- |
| x86_64       | x86_64          | Copied from manylinux_2_28_x86_64          | Python 3.7 - 3.11      |
| aarch64      | aarch64         | Copied from manylinux_2_28_aarch64         | Python 3.7 - 3.11      |
| armv7l       | armv7l / armv7  | `/opt/python/cp3[7-11]`, built from source | Python 3.7 - 3.11      |
| s390x        | s390x           | `/opt/python/cp3[7-11]`, built from source | Python 3.7 - 3.11      |
| ppc64le      | ppc64le         | `/opt/python/cp3[7-11]`, built from source | Python 3.7 - 3.11      |

## Environment variables

Following list of environment variables are set:

* `TARGET_CC`
* `TARGET_CXX`
* `TARGET_AR`
* `TARGET_SYSROOT`
* `TARGET_C_INCLUDE_PATH`
* `CARGO_BUILD_TARGET`
* `CARGO_TARGET_${target}_LINKER`

[messense/manylinux2014-cross]: https://hub.docker.com/r/messense/manylinux2014-cross
[messense/manylinux_2_28-cross]: https://hub.docker.com/r/messense/manylinux_2_28-cross
