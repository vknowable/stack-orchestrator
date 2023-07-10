FROM lukemathwalker/cargo-chef:latest-rust-1.70.0 AS chef
WORKDIR /app

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder 
WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    clang-tools-11 \
    git \
    libssl-dev \
    pkg-config \
    libclang-dev \
    protobuf-compiler \
    wget \
    && apt-get clean

COPY --from=planner /app/recipe.json recipe.json

RUN wget -P /root https://github.com/WebAssembly/binaryen/releases/download/version_114/binaryen-version_114-x86_64-linux.tar.gz
RUN tar -xzf /root/binaryen-version_114-x86_64-linux.tar.gz -C /root
# RUN PATH="/root/binaryen-version_114/bin:$PATH"
RUN cp /root/binaryen-version_114/bin/* /usr/local/bin

RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo --version
RUN make build-wasm-scripts
RUN make build-release

FROM golang:1.18.0 as tendermint-builder
WORKDIR /app

RUN git clone -b v0.37.2 --single-branch https://github.com/cometbft/cometbft.git && cd cometbft && make build

FROM debian:bullseye-slim AS runtime
#ENV NAMADA_BASE_DIR=/.namada 
#ENV NAMADA_LOG_COLOR=false

RUN apt-get update && apt-get install libcurl4-openssl-dev iproute2 curl procps python3 python3-pip -y && apt-get clean
RUN pip install toml

# COPY . .
COPY --from=builder /app/wasm/*.wasm /wasm/
COPY --from=builder /app/wasm/checksums.json /wasm/

COPY --from=builder /app/target/release/namada /usr/local/bin
COPY --from=builder /app/target/release/namadan /usr/local/bin
COPY --from=builder /app/target/release/namadaw /usr/local/bin
COPY --from=builder /app/target/release/namadac /usr/local/bin
COPY --from=tendermint-builder /app/cometbft/build/cometbft /usr/local/bin

EXPOSE 26656
EXPOSE 26660
EXPOSE 26659
EXPOSE 26657

ENTRYPOINT ["/usr/local/bin/namada"]
CMD ["--help"]
