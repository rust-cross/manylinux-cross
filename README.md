# manylinux2014-cross-arm

[![Docker Image](https://img.shields.io/docker/pulls/messense/manylinux2014-cross.svg?maxAge=2592000)](https://hub.docker.com/r/messense/manylinux2014-cross/)

manylinux2014 aarch64/armv7l cross compilation docker images

| Architecture |      OS      |       Tag       |
| ------------ | ------------ | --------------- |
| aarch64      | Ubuntu 16.04 | aarch64         |
| armv7l       | Ubuntu 12.04 | armv7l / armv7  |

Only cross compilers and [maturin](https://github.com/PyO3/maturin) are installed in the image, no Python installation yet
because I'm only using it to build Python abi3 binary wheels.
