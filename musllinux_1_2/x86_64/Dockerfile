FROM quay.io/pypa/musllinux_1_1_x86_64 as musllinux

FROM messense/rust-musl-cross:x86_64-musl

ENV TARGET_READELF=-readelf

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

RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    add-apt-repository -y ppa:pypy/ppa && \
    apt-get update && \
    apt-get install -y \
    python3.6 python3.6-venv python3.6-dev \
    python3.7 python3.7-venv python3.7-dev \
    python3.9 python3.9-venv python3.9-dev \
    python3.10 python3.10-venv python3.10-dev \
    python3.11 python3.11-venv python3.11-dev \
    python3 python3-venv python3-dev python-is-python3 \
    pypy3

COPY --from=musllinux /opt/_internal /opt/_internal
COPY --from=musllinux /opt/python /opt/python

RUN for VER in 3.7 3.8 3.9 3.10 3.11; do curl -sS https://bootstrap.pypa.io/get-pip.py | "python$VER"; done && \
    curl -sS https://bootstrap.pypa.io/pip/3.6/get-pip.py | python3.6 && \
    python3 -m pip --version && \
    python3 -m pip install --no-cache-dir auditwheel build && \
    python3 -m pip install --no-cache-dir maturin auditwheel-symbols patchelf