FROM quay.io/pypa/manylinux_2_28_x86_64 AS manylinux

FROM ubuntu:22.04 AS toolchain

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
    lzip \
    make \
    ninja-build \
    patch \
    pkg-config \
    python3 \
    rsync \
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
    ct-ng build || { tail -n 500 build.log; exit $ERRCODE; } && \
    cd .. && \
    rm -rf build

FROM ubuntu:22.04

# Copy cross toolchain
COPY --from=toolchain /usr/x86_64-unknown-linux-gnu /usr/x86_64-unknown-linux-gnu

ENV DEBIAN_FRONTEND noninteractive
ENV PATH=$PATH:/usr/x86_64-unknown-linux-gnu/bin

ENV CC_x86_64_unknown_linux_gnu=x86_64-unknown-linux-gnu-gcc \
    AR_x86_64_unknown_linux_gnu=x86_64-unknown-linux-gnu-ar \
    CXX_x86_64_unknown_linux_gnu=x86_64-unknown-linux-gnu-g++

ENV TARGET_CC=x86_64-unknown-linux-gnu-gcc \
    TARGET_AR=x86_64-unknown-linux-gnu-ar \
    TARGET_RANLIB=x86_64-unknown-linux-gnu-ranlib \
    TARGET_CXX=x86_64-unknown-linux-gnu-g++ \
    TARGET_READELF=x86_64-unknown-linux-gnu-readelf \
    TARGET_SYSROOT=/usr/x86_64-unknown-linux-gnu/x86_64-unknown-linux-gnu/sysroot/ \
    TARGET_C_INCLUDE_PATH=/usr/x86_64-unknown-linux-gnu/x86_64-unknown-linux-gnu/sysroot/usr/include/

ENV CARGO_BUILD_TARGET=x86_64-unknown-linux-gnu
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=x86_64-unknown-linux-gnu-gcc
RUN echo "set(CMAKE_SYSTEM_NAME Linux)\nset(CMAKE_SYSTEM_PROCESSOR x86_64)\nset(CMAKE_SYSROOT /usr/x86_64-unknown-linux-gnu/x86_64-unknown-linux-gnu/sysroot/)\nset(CMAKE_C_COMPILER x86_64-unknown-linux-gnu-gcc)\nset(CMAKE_CXX_COMPILER x86_64-unknown-linux-gnu-g++)" > /usr/x86_64-unknown-linux-gnu/cmake-toolchain.cmake
ENV TARGET_CMAKE_TOOLCHAIN_FILE_PATH=/usr/x86_64-unknown-linux-gnu/cmake-toolchain.cmake


RUN echo 'Acquire::Retries "3";' > /etc/apt/apt.conf.d/80-retries && \
    apt-get update && \
    apt-get install --no-install-recommends -y \
    curl \
    git \
    g++ \
    make \
    sudo \
    wget \
    software-properties-common \
    gpg-agent \
    cmake \
    llvm-dev \
    libclang-dev \
    clang \
    patch

ENV X86_64_UNKNOWN_LINUX_GNU_OPENSSL_DIR=/usr/x86_64-unknown-linux-gnu/
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.7 python3.7-venv python3.7-dev \
    python3.8 python3.8-venv python3.8-dev \
    python3.9 python3.9-venv python3.9-dev \
    python3.11 python3.11-venv python3.11-dev \
    python3.12 python3.12-venv python3.12-dev \
    python3.13 python3.13-venv python3.13-dev \
    python3 python3-venv python3-dev python-is-python3

RUN if [ "$(uname -m)" = "x86_64" ]; then export PYPY_ARCH="linux64"; else export PYPY_ARCH="aarch64"; fi && \
    mkdir -p /usr/local/pypy/pypy3.7 && \
    curl -sqL https://downloads.python.org/pypy/pypy3.7-v7.3.9-$PYPY_ARCH.tar.bz2 | tar xjf - -C /usr/local/pypy/pypy3.7 --strip-components=1 && \
    ln -s /usr/local/pypy/pypy3.7/bin/pypy /usr/local/bin/pypy3.7 && \
    mkdir -p /usr/local/pypy/pypy3.8 && \
    curl -sqL https://downloads.python.org/pypy/pypy3.8-v7.3.11-$PYPY_ARCH.tar.bz2 | tar xjf - -C /usr/local/pypy/pypy3.8 --strip-components=1 && \
    ln -s /usr/local/pypy/pypy3.8/bin/pypy /usr/local/bin/pypy3.8 && \
    mkdir -p /usr/local/pypy/pypy3.9 && \
    curl -sqL https://downloads.python.org/pypy/pypy3.9-v7.3.12-$PYPY_ARCH.tar.bz2 | tar xjf - -C /usr/local/pypy/pypy3.9 --strip-components=1 && \
    ln -s /usr/local/pypy/pypy3.9/bin/pypy /usr/local/bin/pypy3.9 && \
    mkdir -p /usr/local/pypy/pypy3.10 && \
    curl -sqL https://downloads.python.org/pypy/pypy3.10-v7.3.12-$PYPY_ARCH.tar.bz2 | tar xjf - -C /usr/local/pypy/pypy3.10 --strip-components=1 && \
    ln -s /usr/local/pypy/pypy3.10/bin/pypy /usr/local/bin/pypy3.10

COPY --from=manylinux /opt/_internal /opt/_internal
COPY --from=manylinux /opt/python /opt/python

RUN for VER in 3.7 3.8 3.9 3.10 3.11 3.12 3.13; do \
        case $VER in \
            3.7|3.8) \
                curl -sS https://bootstrap.pypa.io/pip/$VER/get-pip.py | "python$VER"; \
                curl -sS https://bootstrap.pypa.io/pip/$VER/get-pip.py | "pypy$VER"; \
                ;; \
            3.9|3.10) \
                curl -sS https://bootstrap.pypa.io/get-pip.py | "python$VER"; \
                curl -sS https://bootstrap.pypa.io/get-pip.py | "pypy$VER"; \
                ;; \
            3.11|3.12|3.13) \
                curl -sS https://bootstrap.pypa.io/get-pip.py | "python$VER"; \
                ;; \
        esac && \
        "python$VER" -m pip install --no-cache-dir cffi; \
    done && \
    python3 -m pip --version && \
    python3 -m pip install --no-cache-dir auditwheel patchelf build && \
    python3 -m pip install --no-cache-dir auditwheel-symbols
