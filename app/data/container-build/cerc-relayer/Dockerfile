ARG RELAYER_TAG=v2.4.2

# Build the relayer binary
FROM golang:1.21-alpine3.17 AS builder

ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev
RUN apk add --update --no-cache $PACKAGES

WORKDIR /src/app/

RUN if [ "${TARGETARCH}" = "arm64" ] && [ "${BUILDARCH}" != "arm64" ]; then \
    wget -c https://musl.cc/aarch64-linux-musl-cross.tgz -O - | tar -xzvv --strip-components 1 -C /usr; \
    elif [ "${TARGETARCH}" = "amd64" ] && [ "${BUILDARCH}" != "amd64" ]; then \
    wget -c https://musl.cc/x86_64-linux-musl-cross.tgz -O - | tar -xzvv --strip-components 1 -C /usr; \
    fi

COPY . .

RUN GOOS=linux GOARCH=$TARGETARCH CGO_ENABLED=1 LDFLAGS='-linkmode external -extldflags "-static"' make install

###################################################################

FROM debian:bullseye-slim AS runtime

RUN apt-get update && apt-get install curl jq -y && apt-get clean

COPY --from=builder /go/bin/rly /usr/local/bin/

ENTRYPOINT ["rly"]
CMD ["version"]
