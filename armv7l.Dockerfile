FROM ubuntu:12.04

RUN apt-get update \
	&& apt-get install --no-install-recommends -y curl ca-certificates build-essential gcc-arm-linux-gnueabihf libc6-armhf-cross libc6-dev-armhf-cross

RUN curl -L https://github.com/PyO3/maturin/releases/download/v0.9.4/maturin-x86_64-unknown-linux-musl.tar.gz | tar -C /usr/local/bin -xz
RUN curl -L https://github.com/messense/auditwheel-symbols/releases/download/v0.1.4/auditwheel-symbols-x86_64-unknown-linux-musl.tar.gz | tar -C /usr/local/bin -xz

ENV TARGET_CC=arm-linux-gnueabihf-gcc
ENV TARGET_CXX=arm-linux-gnueabihf-cpp
ENV TARGET_AR=arm-linux-gnueabihf-ar
ENV TARGET_RANLIB=arm-linux-gnueabihf-ranlib
ENV CARGO_BUILD_TARGET=armv7-unknown-linux-gnueabihf
ENV CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc
