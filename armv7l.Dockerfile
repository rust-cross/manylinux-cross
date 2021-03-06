FROM ubuntu:12.04

RUN apt-get update \
	&& apt-get install --no-install-recommends -y curl ca-certificates build-essential gcc-arm-linux-gnueabihf libc6-armhf-cross libc6-dev-armhf-cross

# Host openssl & libffi
RUN echo "Building OpenSSL" && \
    VERS=1.1.1j && \
    curl -sqO https://www.openssl.org/source/openssl-$VERS.tar.gz && \
    tar xzf openssl-$VERS.tar.gz && cd openssl-$VERS && \
    ./Configure linux-x86_64 -fPIC --prefix=/usr && \
    make -j4 && make -j4 install_sw install_ssldirs && \
    cd .. && rm -rf openssl-$VERS.tar.gz openssl-$VERS && \
    echo "Building libffi" && \
    VERS=3.3 && \
    curl -sqLO https://github.com/libffi/libffi/releases/download/v$VERS/libffi-$VERS.tar.gz && \
    tar xzf libffi-$VERS.tar.gz && cd libffi-$VERS && \
    ./configure --prefix=/usr && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf libffi-$VERS.tar.gz libffi-$VERS

ENV TARGET_CC=arm-linux-gnueabihf-gcc
ENV TARGET_CXX=arm-linux-gnueabihf-cpp
ENV TARGET_AR=arm-linux-gnueabihf-ar
ENV TARGET_RANLIB=arm-linux-gnueabihf-ranlib
ENV TARGET_C_INCLUDE_PATH=/usr/arm-linux-gnueabihf/include
ENV CARGO_BUILD_TARGET=armv7-unknown-linux-gnueabihf
ENV CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=arm-linux-gnueabihf-gcc

# Target openssl & libffi
RUN export CC=$TARGET_CC && \
    export C_INCLUDE_PATH=$TARGET_C_INCLUDE_PATH && \
    echo "Building zlib" && \
    VERS=1.2.11 && \
    cd /tmp && \
    curl -sqLO https://zlib.net/zlib-$VERS.tar.gz && \
    tar xzf zlib-$VERS.tar.gz && cd zlib-$VERS && \
    ./configure --archs="-fPIC" --prefix=/usr/arm-linux-gnueabihf/ && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf zlib-$VERS.tar.gz zlib-$VERS && \
    echo "Building OpenSSL" && \
    VERS=1.1.1j && \
    curl -sqO https://www.openssl.org/source/openssl-$VERS.tar.gz && \
    tar xzf openssl-$VERS.tar.gz && cd openssl-$VERS && \
    ./Configure linux-generic32 -fPIC --prefix=/usr/arm-linux-gnueabihf/ && \
    make -j4 && make -j4 install_sw install_ssldirs && \
    cd .. && rm -rf openssl-$VERS.tar.gz openssl-$VERS && \
    echo "Building libffi" && \
    VERS=3.3 && \
    curl -sqLO https://github.com/libffi/libffi/releases/download/v$VERS/libffi-$VERS.tar.gz && \
    tar xzf libffi-$VERS.tar.gz && cd libffi-$VERS && \
    ./configure --prefix=/usr/arm-linux-gnueabihf/ --disable-docs --host=arm-linux-gnueabihf --build=x86_64-linux-gnu && \
    make -j4 && make -j4 install && \
    cd .. && rm -rf libffi-$VERS.tar.gz libffi-$VERS


ENV OPENSSL_DIR=/usr/arm-linux-gnueabihf \
    OPENSSL_INCLUDE_DIR=/usr/arm-linux-gnueabihf/include \
    DEP_OPENSSL_INCLUDE=/usr/arm-linux-gnueabihf/include \
    OPENSSL_LIB_DIR=/usr/arm-linux-gnueabihf/lib

RUN apt-get install -y libz-dev libbz2-dev libexpat1-dev libncurses5-dev libreadline-dev liblzma-dev file

RUN mkdir -p /opt/python

RUN cd /tmp && \
    VERS=3.5.9 && PREFIX=/opt/python/cp35-cp35m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=no && make -j4 && make -j4 install && make clean && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$OPENSSL_DIR --build=x86_64-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS ${PREFIX}/share && \
    # we don't need libpython*.a, and they're many megabytes
    find ${PREFIX} -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find ${PREFIX} -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find ${PREFIX} -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.6.12 && PREFIX=/opt/python/cp36-cp36m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=no && make -j4 && make -j4 install && make clean && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$OPENSSL_DIR --build=x86_64-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS ${PREFIX}/share && \
    # we don't need libpython*.a, and they're many megabytes
    find ${PREFIX} -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find ${PREFIX} -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find ${PREFIX} -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.7.10 && PREFIX=/opt/python/cp37-cp37m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=no && make -j4 && make -j4 install && make clean && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$OPENSSL_DIR --build=x86_64-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS ${PREFIX}/share && \
    # we don't need libpython*.a, and they're many megabytes
    find ${PREFIX} -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find ${PREFIX} -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find ${PREFIX} -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.8.8 && PREFIX=/opt/python/cp38-cp38 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=no && make -j4 && make -j4 install && make clean && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$OPENSSL_DIR --build=x86_64-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS ${PREFIX}/share && \
    # we don't need libpython*.a, and they're many megabytes
    find ${PREFIX} -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find ${PREFIX} -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find ${PREFIX} -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN cd /tmp && \
    VERS=3.9.2 && PREFIX=/opt/python/cp39-cp39 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=install && make -j4 && make -j4 install && make clean && \
    ./configure CC=$TARGET_CC AR=$TARGET_AR --host=arm-linux-gnueabihf --target=arm-linux-gnueabihf --prefix=$PREFIX --disable-shared --with-ensurepip=no --with-openssl=$OPENSSL_DIR --build=x86_64-linux-gnu --disable-ipv6 ac_cv_have_long_long_format=yes ac_cv_file__dev_ptmx=no ac_cv_file__dev_ptc=no && \
    make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS ${PREFIX}/share && \
    # we don't need libpython*.a, and they're many megabytes
    find ${PREFIX} -name '*.a' -print0 | xargs -0 rm -f && \
    # We do not need the Python test suites
    find ${PREFIX} -depth \( -type d -a -name test -o -name tests \) | xargs rm -rf && \
    # We do not need precompiled .pyc and .pyo files.
    find ${PREFIX} -type f -a \( -name '*.pyc' -o -name '*.pyo' \) -delete

RUN curl -L https://github.com/PyO3/maturin/releases/download/v0.10.0-beta.5/maturin-x86_64-unknown-linux-musl.tar.gz | tar -C /usr/local/bin -xz
RUN curl -L https://github.com/messense/auditwheel-symbols/releases/download/v0.1.5/auditwheel-symbols-x86_64-unknown-linux-musl.tar.gz | tar -C /usr/local/bin -xz
