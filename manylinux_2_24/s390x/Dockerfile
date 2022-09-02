FROM quay.io/pypa/manylinux_2_24_s390x AS manylinux

FROM ubuntu:20.04 AS toolchain

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
RUN curl -Lf https://github.com/crosstool-ng/crosstool-ng/archive/crosstool-ng-1.25.0.tar.gz | tar xzf - && \
    cd crosstool-ng-crosstool-ng-1.25.0 && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j4 && \
    make install && \
    cd .. && rm -rf crosstool-ng-*

COPY .config /tmp/toolchain.config

# Build cross compiler
RUN mkdir build && \
    cd build && \
    cp /tmp/toolchain.config .config && \
    export CT_ALLOW_BUILD_AS_ROOT_SURE=1 && \
    ct-ng build.2 || tail -n 500 build.log && \
    cd .. && \
    rm -rf build

FROM ubuntu:20.04

# Copy cross toolchain
COPY --from=toolchain /usr/s390x-ibm-linux-gnu /usr/s390x-ibm-linux-gnu

ENV DEBIAN_FRONTEND noninteractive
ENV PATH=$PATH:/usr/s390x-ibm-linux-gnu/bin

ENV CC_s390x_unknown_linux_gnu=s390x-ibm-linux-gnu-gcc \
    AR_s390x_unknown_linux_gnu=s390x-ibm-linux-gnu-ar \
    CXX_s390x_unknown_linux_gnu=s390x-ibm-linux-gnu-g++

ENV TARGET_CC=s390x-ibm-linux-gnu-gcc \
    TARGET_AR=s390x-ibm-linux-gnu-ar \
    TARGET_RANLIB=s390x-ibm-linux-gnu-ranlib \
    TARGET_CXX=s390x-ibm-linux-gnu-g++ \
    TARGET_READELF=s390x-ibm-linux-gnu-readelf \
    TARGET_SYSROOT=/usr/s390x-ibm-linux-gnu/s390x-ibm-linux-gnu/sysroot/ \
    TARGET_C_INCLUDE_PATH=/usr/s390x-ibm-linux-gnu/s390x-ibm-linux-gnu/sysroot/usr/include/

ENV CARGO_BUILD_TARGET=s390x-unknown-linux-gnu
ENV CARGO_TARGET_S390X_UNKNOWN_LINUX_GNU_LINKER=s390x-ibm-linux-gnu-gcc


RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    curl \
    git \
    g++ \
    make \
    sudo \
    wget \
    software-properties-common \
    cmake \
    llvm-dev \
    libclang-dev \
    clang

# Target openssl & libffi
RUN export CC=$TARGET_CC && \
    export AR=$TARGET_AR && \
    export RANLIB=$TARGET_RANLIB && \
    echo "Building zlib" && \
    VERS=1.2.12 && \
    cd /tmp && \
    curl -sqLO https://zlib.net/zlib-$VERS.tar.gz && \
    tar xzf zlib-$VERS.tar.gz && cd zlib-$VERS && \
    CFLAGS="-O3 -fPIC" ./configure --prefix=/usr/s390x-ibm-linux-gnu/ && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf zlib-$VERS.tar.gz zlib-$VERS && \
    echo "Building OpenSSL" && \
    VERS=1.1.1o && \
    curl -sqO https://www.openssl.org/source/openssl-$VERS.tar.gz && \
    tar xzf openssl-$VERS.tar.gz && cd openssl-$VERS && \
    ./Configure linux-generic32 -fPIC --prefix=/usr/s390x-ibm-linux-gnu/ && \
    make -j4 && make -j4 install_sw install_ssldirs && \
    cd .. && rm -rf openssl-$VERS.tar.gz openssl-$VERS && \
    echo "Building libffi" && \
    VERS=3.4.2 && \
    curl -sqLO https://github.com/libffi/libffi/releases/download/v$VERS/libffi-$VERS.tar.gz && \
    tar xzf libffi-$VERS.tar.gz && cd libffi-$VERS && \
    ./configure --prefix=/usr/s390x-ibm-linux-gnu/ --disable-docs --host=s390x-ibm-linux-gnu --build=$(uname -m)-linux-gnu && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf libffi-$VERS.tar.gz libffi-$VERS
ENV S390X_UNKNOWN_LINUX_GNU_OPENSSL_DIR=/usr/s390x-ibm-linux-gnu/
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.6 python3.6-venv python3.6-dev \
    python3.7 python3.7-venv python3.7-dev \
    python3.9 python3.9-venv python3.9-dev \
    python3.10 python3.10-venv python3.10-dev \
    python3.11 python3.11-venv python3.11-dev \
    python3 python3-venv python3-dev python-is-python3

RUN if [ "$(uname -m)" = "x86_64" ]; then export PYPY_ARCH="linux64"; else export PYPY_ARCH="aarch64"; fi && \
    mkdir -p /usr/local/pypy/pypy3.7 && \
    curl -sqL https://downloads.python.org/pypy/pypy3.7-v7.3.9-$PYPY_ARCH.tar.bz2 | tar xjf - -C /usr/local/pypy/pypy3.7 --strip-components=1 && \
    ln -s /usr/local/pypy/pypy3.7/bin/pypy /usr/local/bin/pypy3.7 && \
    mkdir -p /usr/local/pypy/pypy3.8 && \
    curl -sqL https://downloads.python.org/pypy/pypy3.8-v7.3.9-$PYPY_ARCH.tar.bz2 | tar xjf - -C /usr/local/pypy/pypy3.8 --strip-components=1 && \
    ln -s /usr/local/pypy/pypy3.8/bin/pypy /usr/local/bin/pypy3.8 && \
    mkdir -p /usr/local/pypy/pypy3.9 && \
    curl -sqL https://downloads.python.org/pypy/pypy3.9-v7.3.9-$PYPY_ARCH.tar.bz2 | tar xjf - -C /usr/local/pypy/pypy3.9 --strip-components=1 && \ 
    ln -s /usr/local/pypy/pypy3.9/bin/pypy /usr/local/bin/pypy3.9

COPY --from=manylinux /opt/_internal /opt/_internal
COPY --from=manylinux /opt/python /opt/python

RUN curl -sS https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3.6 && \
    for VER in 3.11 3.7 3.8 3.9 3.10; do curl -sS https://bootstrap.pypa.io/get-pip.py | "python$VER"; done && \
    for VER in 3.7 3.8 3.9; do curl -sS https://bootstrap.pypa.io/get-pip.py | "pypy$VER"; done && \
    python3 -m pip --version && \
    python3 -m pip install --no-cache-dir auditwheel build && \
    python3 -m pip install --no-cache-dir maturin auditwheel-symbols patchelf