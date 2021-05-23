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
RUN curl -Lf https://github.com/crosstool-ng/crosstool-ng/archive/master.tar.gz | tar xzf - && \
    cd crosstool-ng-master && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j4 && \
    make install && \
    cd .. && rm -rf crosstool-ng-master

COPY .config /tmp/toolchain.config

# Build cross compiler
RUN mkdir build && \
    cd build && \
    cp /tmp/toolchain.config .config && \
    export CT_ALLOW_BUILD_AS_ROOT_SURE=1 && \
    ct-ng build && \
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
    software-properties-common

# Target openssl & libffi
RUN export CC=$TARGET_CC && \
    echo "Building zlib" && \
    VERS=1.2.11 && \
    cd /tmp && \
    curl -sqLO https://zlib.net/zlib-$VERS.tar.gz && \
    tar xzf zlib-$VERS.tar.gz && cd zlib-$VERS && \
    ./configure --archs="-fPIC" --prefix=/usr/s390x-ibm-linux-gnu/ || tail -n 500 configure.log && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf zlib-$VERS.tar.gz zlib-$VERS && \
    echo "Building OpenSSL" && \
    VERS=1.1.1k && \
    curl -sqO https://www.openssl.org/source/openssl-$VERS.tar.gz && \
    tar xzf openssl-$VERS.tar.gz && cd openssl-$VERS && \
    ./Configure linux64-s390x -fPIC --prefix=/usr/s390x-ibm-linux-gnu/ && \
    make -j4 && make -j4 install_sw install_ssldirs && \
    cd .. && rm -rf openssl-$VERS.tar.gz openssl-$VERS && \
    echo "Building libffi" && \
    VERS=3.3 && \
    curl -sqLO https://github.com/libffi/libffi/releases/download/v$VERS/libffi-$VERS.tar.gz && \
    tar xzf libffi-$VERS.tar.gz && cd libffi-$VERS && \
    ./configure --prefix=/usr/s390x-ibm-linux-gnu/ --disable-docs --host=s390x-ibm-linux-gnu --build=$(uname -m)-linux-gnu && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf libffi-$VERS.tar.gz libffi-$VERS

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
