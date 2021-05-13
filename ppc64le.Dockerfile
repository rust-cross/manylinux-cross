FROM quay.io/pypa/manylinux2014_ppc64le AS manylinux

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    automake \
    bison \
    bzip2 \
    ca-certificates \
    cmake \
    curl \
    file \
    flex \
    g++ \
    gawk \
    gdb \
    git \
    gperf \
    help2man \
    libncurses-dev \
    libssl-dev \
    libtool-bin \
    make \
    ninja-build \
    patch \
    pkg-config \
    python3 \
    sudo \
    texinfo \
    unzip \
    wget \
    xz-utils \
    libssl-dev \
    libffi-dev

# Install crosstool-ng
RUN curl -Lf https://github.com/messense/crosstool-ng/archive/refs/heads/glibc-ppc64le-patches.tar.gz | tar xzf - && \
    cd crosstool-ng-glibc-ppc64le-patches && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j4 && \
    make install && \
    cd .. && rm -rf crosstool-ng-glibc-ppc64le-patches

COPY ppc64le.config /tmp/toolchain.config

# Build cross compiler
RUN mkdir build && \
    cd build && \
    cp /tmp/toolchain.config .config && \
    export CT_ALLOW_BUILD_AS_ROOT_SURE=1 && \
    ct-ng build && \
    cd .. && \
    rm -rf build

ENV PATH=$PATH:/usr/powerpc64le-unknown-linux-gnu/bin

ENV CC_powerpc64le_unknown_linux_gnu=powerpc64le-unknown-linux-gnu-gcc \
    AR_powerpc64le_unknown_linux_gnu=powerpc64le-unknown-linux-gnu-ar \
    CXX_powerpc64le_unknown_linux_gnu=powerpc64le-unknown-linux-gnu-g++

ENV TARGET_CC=powerpc64le-unknown-linux-gnu-gcc \
    TARGET_AR=powerpc64le-unknown-linux-gnu-ar \
    TARGET_CXX=powerpc64le-unknown-linux-gnu-g++ \
    TARGET_READELF=powerpc64le-unknown-linux-gnu-readelf \
    TARGET_SYSROOT=/usr/powerpc64le-unknown-linux-gnu/powerpc64le-unknown-linux-gnu/sysroot/ \
    TARGET_C_INCLUDE_PATH=/usr/powerpc64le-unknown-linux-gnu/powerpc64le-unknown-linux-gnu/sysroot/usr/include/

ENV CARGO_BUILD_TARGET=powerpc64le-unknown-linux-gnu
ENV CARGO_TARGET_POWERPC64LE_UNKNOWN_LINUX_GNU_LINKER=powerpc64le-unknown-linux-gnu-gcc

# Target openssl & libffi
RUN export CC=$TARGET_CC && \
    echo "Building zlib" && \
    VERS=1.2.11 && \
    cd /tmp && \
    curl -sqLO https://zlib.net/zlib-$VERS.tar.gz && \
    tar xzf zlib-$VERS.tar.gz && cd zlib-$VERS && \
    ./configure --archs="-fPIC" --prefix=/usr/powerpc64le-unknown-linux-gnu/ || tail -n 500 configure.log && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf zlib-$VERS.tar.gz zlib-$VERS && \
    echo "Building OpenSSL" && \
    VERS=1.1.1j && \
    curl -sqO https://www.openssl.org/source/openssl-$VERS.tar.gz && \
    tar xzf openssl-$VERS.tar.gz && cd openssl-$VERS && \
    ./Configure linux-generic32 -fPIC --prefix=/usr/powerpc64le-unknown-linux-gnu/ && \
    make -j4 && make -j4 install_sw install_ssldirs && \
    cd .. && rm -rf openssl-$VERS.tar.gz openssl-$VERS && \
    echo "Building libffi" && \
    VERS=3.3 && \
    curl -sqLO https://github.com/libffi/libffi/releases/download/v$VERS/libffi-$VERS.tar.gz && \
    tar xzf libffi-$VERS.tar.gz && cd libffi-$VERS && \
    ./configure --prefix=/usr/powerpc64le-unknown-linux-gnu/ --disable-docs --host=powerpc64le-unknown-linux-gnu --build=$(uname -m)-linux-gnu && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf libffi-$VERS.tar.gz libffi-$VERS

RUN apt-get update && \
    apt-get install -y libz-dev libbz2-dev libexpat1-dev libncurses5-dev libreadline-dev liblzma-dev file software-properties-common

RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.6 python3.6-venv \
    python3.7 python3.7-venv \
    python3.9 python3.9-venv \
    python3 python3-pip python3-venv python-is-python3

COPY --from=manylinux /opt/_internal /opt/_internal
COPY --from=manylinux /opt/python /opt/python

RUN python3 -m pip install --no-cache-dir auditwheel build && \
    python3 -m pip install --no-cache-dir "maturin==0.10.2" auditwheel-symbols && \
    for VER in 3.6 3.7 3.8 3.9; do "python$VER" -m pip install wheel; done
