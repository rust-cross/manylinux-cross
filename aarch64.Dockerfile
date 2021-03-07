FROM quay.io/pypa/manylinux2014_aarch64 AS manylinux

FROM ubuntu:16.04

RUN apt-get update \
	&& apt-get install --no-install-recommends -y \
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
	xz-utils

# Install crosstool-ng
RUN curl -Lf https://github.com/crosstool-ng/crosstool-ng/archive/master.tar.gz | tar xzf - && \
    cd crosstool-ng-master && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j4 && \
    make install && \
    cd .. && rm -rf crosstool-ng-master

COPY aarch64.config /tmp/toolchain.config

# Build cross compiler
RUN mkdir build && \
    cd build && \
    cp /tmp/toolchain.config .config && \
    export CT_ALLOW_BUILD_AS_ROOT_SURE=1 && \
    ct-ng build || tail -n 500 build.log && \
    cd .. && \
    rm -rf build

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

ENV PATH=$PATH:/usr/aarch64-unknown-linux-gnu/bin

ENV CC_aarch64_unknown_linux_gnu=aarch64-unknown-linux-gnu-gcc \
    AR_aarch64_unknown_linux_gnu=aarch64-unknown-linux-gnu-ar \
    CXX_aarch64_unknown_linux_gnu=aarch64-unknown-linux-gnu-g++

ENV TARGET_CC=aarch64-unknown-linux-gnu-gcc \
    TARGET_CXX=aarch64-unknown-linux-gnu-g++

ENV CARGO_BUILD_TARGET=aarch64-unknown-linux-gnu
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER=aarch64-unknown-linux-gnu-gcc

RUN apt-get install -y libz-dev libbz2-dev libexpat1-dev libncurses5-dev libreadline-dev liblzma-dev file

RUN cd /tmp && \
    VERS=3.5.9 && PREFIX=/opt/python/cp35-cp35m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=install && make -j4 && make -j4 install && make clean && \
    rm -rf Python-$VERS.tgz Python-$VERS

RUN cd /tmp && \
    VERS=3.6.12 && PREFIX=/opt/python/cp36-cp36m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=install && make -j4 && make -j4 install && make clean && \
    rm -rf Python-$VERS.tgz Python-$VERS

RUN cd /tmp && \
    VERS=3.7.10 && PREFIX=/opt/python/cp37-cp37m && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=install && make -j4 && make -j4 install && make clean && \
    rm -rf Python-$VERS.tgz Python-$VERS

RUN cd /tmp && \
    VERS=3.8.8 && PREFIX=/opt/python/cp38-cp38 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=install && make -j4 && make -j4 install && make clean && \
    rm -rf Python-$VERS.tgz Python-$VERS

RUN cd /tmp && \
    VERS=3.9.2 && \
    curl -LO https://www.python.org/ftp/python/$VERS/Python-$VERS.tgz && \
    tar xzf Python-$VERS.tgz && cd Python-$VERS && \
    ./configure --with-ensurepip=install && make -j4 && make -j4 install && \
    rm -rf Python-$VERS.tgz Python-$VERS

COPY --from=manylinux /opt/_internal /opt/_internal
COPY --from=manylinux /opt/python /opt/python

RUN curl -L https://github.com/PyO3/maturin/releases/download/v0.10.0-beta.5/maturin-x86_64-unknown-linux-musl.tar.gz | tar -C /usr/local/bin -xz
RUN curl -L https://github.com/messense/auditwheel-symbols/releases/download/v0.1.5/auditwheel-symbols-x86_64-unknown-linux-musl.tar.gz | tar -C /usr/local/bin -xz
