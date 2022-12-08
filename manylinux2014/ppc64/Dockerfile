
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
RUN curl -Lf https://github.com/crosstool-ng/crosstool-ng/archive/02d1503f6769be4ad8058b393d4245febced459f.tar.gz | tar xzf - && \
    cd crosstool-ng-02d1503f6769be4ad8058b393d4245febced459f && \
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
    ct-ng build.2 || { tail -n 500 build.log; exit $ERRCODE; } && \
    cd .. && \
    rm -rf build

FROM ubuntu:22.04

# Copy cross toolchain
COPY --from=toolchain /usr/powerpc64-unknown-linux-gnu /usr/powerpc64-unknown-linux-gnu

ENV DEBIAN_FRONTEND noninteractive
ENV PATH=$PATH:/usr/powerpc64-unknown-linux-gnu/bin

ENV CC_powerpc64_unknown_linux_gnu=powerpc64-unknown-linux-gnu-gcc \
    AR_powerpc64_unknown_linux_gnu=powerpc64-unknown-linux-gnu-ar \
    CXX_powerpc64_unknown_linux_gnu=powerpc64-unknown-linux-gnu-g++

ENV TARGET_CC=powerpc64-unknown-linux-gnu-gcc \
    TARGET_AR=powerpc64-unknown-linux-gnu-ar \
    TARGET_RANLIB=powerpc64-unknown-linux-gnu-ranlib \
    TARGET_CXX=powerpc64-unknown-linux-gnu-g++ \
    TARGET_READELF=powerpc64-unknown-linux-gnu-readelf \
    TARGET_SYSROOT=/usr/powerpc64-unknown-linux-gnu/powerpc64-unknown-linux-gnu/sysroot/ \
    TARGET_C_INCLUDE_PATH=/usr/powerpc64-unknown-linux-gnu/powerpc64-unknown-linux-gnu/sysroot/usr/include/

ENV CARGO_BUILD_TARGET=powerpc64-unknown-linux-gnu
ENV CARGO_TARGET_POWERPC64_UNKNOWN_LINUX_GNU_LINKER=powerpc64-unknown-linux-gnu-gcc
RUN echo "set(CMAKE_SYSTEM_NAME Linux)\nset(CMAKE_SYSTEM_PROCESSOR ppc64)\nset(CMAKE_SYSROOT /usr/powerpc64-unknown-linux-gnu/powerpc64-unknown-linux-gnu/sysroot/)\nset(CMAKE_C_COMPILER powerpc64-unknown-linux-gnu-gcc)\nset(CMAKE_CXX_COMPILER powerpc64-unknown-linux-gnu-g++)" > /usr/powerpc64-unknown-linux-gnu/cmake-toolchain.cmake
ENV TARGET_CMAKE_TOOLCHAIN_FILE_PATH=/usr/powerpc64-unknown-linux-gnu/cmake-toolchain.cmake


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
    clang

ENV POWERPC64_UNKNOWN_LINUX_GNU_OPENSSL_DIR=/usr/powerpc64-unknown-linux-gnu/
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.7 python3.7-venv python3.7-dev \
    python3.8 python3.8-venv python3.8-dev \
    python3.9 python3.9-venv python3.9-dev \
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


RUN mkdir -p /opt/python

RUN cd /tmp && \
    VERS=3.7.16 && PREFIX=/opt/python/cp37-cp37m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=powerpc64-unknown-linux-gnu --target=powerpc64-unknown-linux-gnu --prefix=$PREFIX --disable-shared --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.8.16 && PREFIX=/opt/python/cp38-cp38 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=powerpc64-unknown-linux-gnu --target=powerpc64-unknown-linux-gnu --prefix=$PREFIX --disable-shared --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.9.16 && PREFIX=/opt/python/cp39-cp39 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=powerpc64-unknown-linux-gnu --target=powerpc64-unknown-linux-gnu --prefix=$PREFIX --disable-shared --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.10.9 && PREFIX=/opt/python/cp310-cp310 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=powerpc64-unknown-linux-gnu --target=powerpc64-unknown-linux-gnu --prefix=$PREFIX --disable-shared --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.11.1 && PREFIX=/opt/python/cp311-cp311 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=powerpc64-unknown-linux-gnu --target=powerpc64-unknown-linux-gnu --prefix=$PREFIX  --disable-shared --with-build-python=python3.11 --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete
RUN for VER in 3.11 3.7 3.8 3.9 3.10; do curl -sS https://bootstrap.pypa.io/get-pip.py | "python$VER"; done && \
    for VER in 3.7 3.8 3.9; do curl -sS https://bootstrap.pypa.io/get-pip.py | "pypy$VER"; done && \
    python3 -m pip --version && \
    python3 -m pip install --no-cache-dir auditwheel patchelf build && \
    python3 -m pip install --no-cache-dir auditwheel-symbols