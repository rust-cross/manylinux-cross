
FROM messense/rust-musl-cross:armv7-musleabihf

ENV TARGET_READELF=armv7-unknown-linux-musleabihf-readelf

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
    CFLAGS="-O3 -fPIC" ./configure --prefix=/usr/armv7-unknown-linux-musleabihf/ && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf zlib-$VERS.tar.gz zlib-$VERS && \
    echo "Building OpenSSL" && \
    VERS=1.1.1o && \
    curl -sqO https://www.openssl.org/source/openssl-$VERS.tar.gz && \
    tar xzf openssl-$VERS.tar.gz && cd openssl-$VERS && \
    ./Configure linux-generic32 -fPIC --prefix=/usr/armv7-unknown-linux-musleabihf/ && \
    make -j4 && make -j4 install_sw install_ssldirs && \
    cd .. && rm -rf openssl-$VERS.tar.gz openssl-$VERS && \
    echo "Building libffi" && \
    VERS=3.4.2 && \
    curl -sqLO https://github.com/libffi/libffi/releases/download/v$VERS/libffi-$VERS.tar.gz && \
    tar xzf libffi-$VERS.tar.gz && cd libffi-$VERS && \
    ./configure --prefix=/usr/armv7-unknown-linux-musleabihf/ --disable-docs --host=armv7-unknown-linux-musleabihf --build=$(uname -m)-linux-gnu && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf libffi-$VERS.tar.gz libffi-$VERS
ENV ARMV7_UNKNOWN_LINUX_MUSLEABIHF_OPENSSL_DIR=/usr/armv7-unknown-linux-musleabihf/
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


RUN mkdir -p /opt/python

RUN cd /tmp && \
    VERS=3.6.15 && PREFIX=/opt/python/cp36-cp36m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$ARMV7_UNKNOWN_LINUX_MUSLEABIHF_OPENSSL_DIR --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.7.13 && PREFIX=/opt/python/cp37-cp37m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$ARMV7_UNKNOWN_LINUX_MUSLEABIHF_OPENSSL_DIR --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.8.13 && PREFIX=/opt/python/cp38-cp38 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$ARMV7_UNKNOWN_LINUX_MUSLEABIHF_OPENSSL_DIR --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.9.13 && PREFIX=/opt/python/cp39-cp39 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$ARMV7_UNKNOWN_LINUX_MUSLEABIHF_OPENSSL_DIR --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.10.6 && PREFIX=/opt/python/cp310-cp310 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$ARMV7_UNKNOWN_LINUX_MUSLEABIHF_OPENSSL_DIR --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.11.0rc1 && PREFIX=/opt/python/cp311-cp311 && \
    curl -LO https://www.python.org/ftp/python/3.11.0/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR READELF=$TARGET_READELF --host=armv7l-unknown-linux-gnueabihf --target=armv7l-unknown-linux-gnueabihf --prefix=$PREFIX  --disable-shared --with-build-python=python3.11 --with-ensurepip=no --with-openssl=$ARMV7_UNKNOWN_LINUX_MUSLEABIHF_OPENSSL_DIR --build=$(uname -m)-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    sed -i 's/_PYTHON_HOST_PLATFORM=linux-arm/_PYTHON_HOST_PLATFORM=linux-armv7l/' Makefile && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS $PREFIX/share && \
    # we don't need libpython*.a, and they're many megabytes
    find $PREFIX -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find $PREFIX -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find $PREFIX -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete
RUN curl -sS https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3.6 && \
    for VER in 3.11 3.7 3.8 3.9 3.10; do curl -sS https://bootstrap.pypa.io/get-pip.py | "python$VER"; done && \
    for VER in 3.7 3.8 3.9; do curl -sS https://bootstrap.pypa.io/get-pip.py | "pypy$VER"; done && \
    python3 -m pip --version && \
    python3 -m pip install --no-cache-dir auditwheel build && \
    python3 -m pip install --no-cache-dir maturin auditwheel-symbols patchelf