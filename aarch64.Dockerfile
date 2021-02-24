FROM quay.io/pypa/manylinux2014_aarch64 AS manylinux

FROM ubuntu:14.04

RUN apt-get update \
	&& apt-get install --no-install-recommends -y curl ca-certificates build-essential gcc-aarch64-linux-gnu libc6-arm64-cross libc6-dev-arm64-cross

RUN curl -L https://github.com/PyO3/maturin/releases/download/v0.10.0-beta.1/maturin-x86_64-unknown-linux-musl.tar.gz | tar -C /usr/local/bin -xz
RUN curl -L https://github.com/messense/auditwheel-symbols/releases/download/v0.1.4/auditwheel-symbols-x86_64-unknown-linux-musl.tar.gz | tar -C /usr/local/bin -xz

ENV TARGET_CC=aarch64-linux-gnu-gcc
ENV TARGET_CXX=aarch64-linux-gnu-cpp
ENV TARGET_AR=aarch64-linux-gnu-ar
ENV TARGET_RANLIB=aarch64-linux-gnu-ranlib
ENV CARGO_BUILD_TARGET=aarch64-unknown-linux-gnu
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-linux-gnu-gcc

RUN apt-get install -y libz-dev libbz2-dev libexpat1-dev libncurses5-dev libreadline-dev liblzma-dev file

RUN cd /tmp && \
    VERS=3.9.2 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=no && make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS

COPY --from=manylinux /opt/_internal /opt/_internal
COPY --from=manylinux /opt/python /opt/python
