FROM quay.io/pypa/manylinux_2_24_ppc64le AS manylinux

FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    g++-powerpc64le-linux-gnu \
    libc6-dev-ppc64el-cross \
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

ENV CC_powerpc64le_unknown_linux_gnu=powerpc64le-linux-gnu-gcc \
    AR_powerpc64le_unknown_linux_gnu=powerpc64le-linux-gnu-ar \
    CXX_powerpc64le_unknown_linux_gnu=powerpc64le-linux-gnu-g++

ENV TARGET_CC=powerpc64le-linux-gnu-gcc \
    TARGET_AR=powerpc64le-linux-gnu-ar \
    TARGET_CXX=powerpc64le-linux-gnu-g++ \
    TARGET_READELF=powerpc64le-linux-gnu-readelf \
    TARGET_SYSROOT=/usr/powerpc64le-linux-gnu/powerpc64le-linux-gnu/sysroot/ \
    TARGET_C_INCLUDE_PATH=/usr/powerpc64le-linux-gnu/powerpc64le-linux-gnu/sysroot/usr/include/

ENV CARGO_BUILD_TARGET=powerpc64le-linux-gnu
ENV CARGO_TARGET_POWERPC64LE_UNKNOWN_LINUX_GNU_LINKER=powerpc64le-linux-gnu-gcc

# Target openssl & libffi
RUN export CC=$TARGET_CC && \
    echo "Building zlib" && \
    VERS=1.2.11 && \
    cd /tmp && \
    curl -sqLO https://zlib.net/zlib-$VERS.tar.gz && \
    tar xzf zlib-$VERS.tar.gz && cd zlib-$VERS && \
    ./configure --archs="-fPIC" --prefix=/usr/powerpc64le-linux-gnu/ || tail -n 500 configure.log && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf zlib-$VERS.tar.gz zlib-$VERS && \
    echo "Building OpenSSL" && \
    VERS=1.1.1j && \
    curl -sqO https://www.openssl.org/source/openssl-$VERS.tar.gz && \
    tar xzf openssl-$VERS.tar.gz && cd openssl-$VERS && \
    ./Configure linux-ppc64le -fPIC --prefix=/usr/powerpc64le-linux-gnu/ && \
    make -j4 && make -j4 install_sw install_ssldirs && \
    cd .. && rm -rf openssl-$VERS.tar.gz openssl-$VERS && \
    echo "Building libffi" && \
    VERS=3.3 && \
    curl -sqLO https://github.com/libffi/libffi/releases/download/v$VERS/libffi-$VERS.tar.gz && \
    tar xzf libffi-$VERS.tar.gz && cd libffi-$VERS && \
    ./configure --prefix=/usr/powerpc64le-linux-gnu/ --disable-docs --host=powerpc64le-linux-gnu --build=$(uname -m)-linux-gnu && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf libffi-$VERS.tar.gz libffi-$VERS

RUN apt-get install -y libz-dev libbz2-dev libexpat1-dev libncurses5-dev libreadline-dev liblzma-dev file software-properties-common

RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.6 python3.6-venv \
    python3.7 python3.7-venv \
    python3.8 python3.8-venv \
    python3.9 python3.9-venv \
    python3 python3-pip python3-venv

COPY --from=manylinux /opt/_internal /opt/_internal
COPY --from=manylinux /opt/python /opt/python

RUN python3 -m pip install --no-cache-dir auditwheel build && \
    python3.9 -m pip install --no-cache-dir "maturin==0.10.2" auditwheel-symbols && \
    for VER in 3.6 3.7 3.8 3.9; do "python$VER" -m pip install wheel; done
