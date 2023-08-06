FROM lukemathwalker/cargo-chef:latest-rust-1.70.0 AS chef
WORKDIR /app

FROM chef AS planner
# COPY . .
ARG NAMADA_TAG=main
RUN git clone -b ${NAMADA_TAG} --single-branch https://github.com/anoma/namada.git
WORKDIR /app/namada
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder 
WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    clang-tools-11 \
    git \
    libssl-dev \
    pkg-config \
    protobuf-compiler \
    && apt-get clean

COPY --from=planner /app/namada/recipe.json recipe.json

ARG BUILD_WASM=false
ENV WASM=${BUILD_WASM}
RUN if [ "$WASM" = "true" ]; then \
    wget -P /root https://github.com/WebAssembly/binaryen/releases/download/version_114/binaryen-version_114-x86_64-linux.tar.gz && \
    tar -xzf /root/binaryen-version_114-x86_64-linux.tar.gz -C /root && \
    cp /root/binaryen-version_114/bin/* /usr/local/bin \
    fi
# RUN wget -P /root https://github.com/WebAssembly/binaryen/releases/download/version_114/binaryen-version_114-x86_64-linux.tar.gz
# RUN tar -xzf /root/binaryen-version_114-x86_64-linux.tar.gz -C /root
# RUN cp /root/binaryen-version_114/bin/* /usr/local/bin

RUN cargo chef cook --release --recipe-path recipe.json
#COPY . .
ARG NAMADA_TAG=main
RUN git clone -b ${NAMADA_TAG} --single-branch https://github.com/anoma/namada.git

# build test wasms
ARG BUILD_TEST_WASM=false
ENV TEST_WASM=${BUILD_TEST_WASM}
RUN ls /app
RUN if [ "$TEST_WASM" = "true" ]; then \
    # build test wasms
    cd /app/wasm_for_tests/wasm_source && \
    make deps && \
    make all && \
    cp /app/wasm_for_tests/*.wasm /app/wasm/ && \
    # modify makefile to not delete existing wasm files when running build-wasm-scripts
    sed -i 's/^[[:space:]]*rm wasm\/\*\.wasm || true/# &/' /app/Makefile; \
    fi

WORKDIR /app/namada
RUN if [ "$WASM" = "true" ]; then \
    make build-wasm-scripts \
    fi
# RUN make build-wasm-scripts
RUN make build-release

FROM golang:1.18.0 as tendermint-builder
WORKDIR /app

RUN git clone -b v0.37.2 --single-branch https://github.com/cometbft/cometbft.git && cd cometbft && make build

FROM debian:bullseye-slim AS runtime
#ENV NAMADA_BASE_DIR=/.namada 
#ENV NAMADA_LOG_COLOR=false

RUN apt-get update && apt-get install libcurl4-openssl-dev -y && apt-get clean

COPY --from=builder /app/namada/target/release/namada /usr/local/bin
COPY --from=builder /app/namada/target/release/namadan /usr/local/bin
COPY --from=builder /app/namada/target/release/namadaw /usr/local/bin
COPY --from=builder /app/namada/target/release/namadac /usr/local/bin
COPY --from=tendermint-builder /app/cometbft/build/cometbft /usr/local/bin

EXPOSE 26656
EXPOSE 26660
EXPOSE 26659
EXPOSE 26657

ENTRYPOINT ["/usr/local/bin/namada"]
CMD ["--version"]
