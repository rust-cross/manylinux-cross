
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
COPY --from=toolchain /usr/armv7-unknown-linux-gnueabihf /usr/armv7-unknown-linux-gnueabihf

ENV DEBIAN_FRONTEND noninteractive
ENV PATH=$PATH:/usr/armv7-unknown-linux-gnueabihf/bin

ENV CC_armv7_unknown_linux_gnueabihf=armv7-unknown-linux-gnueabihf-gcc \
    AR_armv7_unknown_linux_gnueabihf=armv7-unknown-linux-gnueabihf-ar \
    CXX_armv7_unknown_linux_gnueabihf=armv7-unknown-linux-gnueabihf-g++

ENV TARGET_CC=armv7-unknown-linux-gnueabihf-gcc \
    TARGET_AR=armv7-unknown-linux-gnueabihf-ar \
    TARGET_RANLIB=armv7-unknown-linux-gnueabihf-ranlib \
    TARGET_CXX=armv7-unknown-linux-gnueabihf-g++ \
    TARGET_READELF=armv7-unknown-linux-gnueabihf-readelf \
    TARGET_SYSROOT=/usr/armv7-unknown-linux-gnueabihf/armv7-unknown-linux-gnueabihf/sysroot/ \
    TARGET_C_INCLUDE_PATH=/usr/armv7-unknown-linux-gnueabihf/armv7-unknown-linux-gnueabihf/sysroot/usr/include/

ENV CARGO_BUILD_TARGET=armv7-unknown-linux-gnueabihf
ENV CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=armv7-unknown-linux-gnueabihf-gcc
RUN echo "set(CMAKE_SYSTEM_NAME Linux)\nset(CMAKE_SYSTEM_PROCESSOR armv7l)\nset(CMAKE_SYSROOT /usr/armv7-unknown-linux-gnueabihf/armv7-unknown-linux-gnueabihf/sysroot/)\nset(CMAKE_C_COMPILER armv7-unknown-linux-gnueabihf-gcc)\nset(CMAKE_CXX_COMPILER armv7-unknown-linux-gnueabihf-g++)" > /usr/armv7-unknown-linux-gnueabihf/cmake-toolchain.cmake
ENV TARGET_CMAKE_TOOLCHAIN_FILE_PATH=/usr/armv7-unknown-linux-gnueabihf/cmake-toolchain.cmake


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

ENV ARMV7_UNKNOWN_LINUX_GNUEABIHF_OPENSSL_DIR=/usr/armv7-unknown-linux-gnueabihf/
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


RUN mkdir -p /opt/python

RUN cd /tmp && \
    VERS=3.7.17 && PREFIX=/opt/python/cp37-cp37m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    cd /tmp && rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.8.20 && PREFIX=/opt/python/cp38-cp38 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    cd /tmp && rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.9.23 && PREFIX=/opt/python/cp39-cp39 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    cd /tmp && rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.10.18 && PREFIX=/opt/python/cp310-cp310 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    cd /tmp && rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.11.13 && PREFIX=/opt/python/cp311-cp311 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX  --disable-shared --with-build-python=python3.11 --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    cd /tmp && rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.12.11 && PREFIX=/opt/python/cp312-cp312 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX  --disable-shared --with-build-python=python3.12 --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    cd /tmp && rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.13.5 && PREFIX=/opt/python/cp313-cp313 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX  --disable-shared --with-build-python=python3.13 --with-ensurepip=no --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no  && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    cd /tmp && rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete
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
