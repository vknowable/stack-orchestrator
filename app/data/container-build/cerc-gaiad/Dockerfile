ARG GAIAD_TAG=v13.0.0

# Compile the gaiad binary
FROM golang:1.20-alpine AS builder
WORKDIR /src/app/
COPY go.mod go.sum* ./
RUN go mod download
COPY . .
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3
RUN apk add --no-cache $PACKAGES
RUN CGO_ENABLED=0 make install

###################################################################

FROM debian:bullseye-slim AS runtime

RUN apt-get update && apt-get install curl jq -y && apt-get clean

COPY --from=builder /go/bin/gaiad /usr/local/bin/

ENTRYPOINT ["gaiad"]
CMD ["version"]
