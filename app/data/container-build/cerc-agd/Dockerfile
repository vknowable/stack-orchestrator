ARG AGD_TAG=agoric-upgrade-11

# FROM node:18-alpine3.17 as builder
FROM node:18-bullseye

# add go
# COPY --from=golang:1.20-alpine /usr/local/go/ /usr/local/go/
COPY --from=golang:1.20-bullseye /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"
ENV PATH="/root/go/bin:${PATH}"

RUN apt-get update && apt-get install git build-essential curl jq -y && apt-get clean

# RUN apk --update --no-cache add git curl libc-dev bash linux-headers eudev-dev python3 alpine-sdk gcc make jq

WORKDIR /src/agoric-sdk/
COPY . .
RUN yarn install
RUN yarn build

RUN (cd packages/cosmic-swingset && make)

###################################################################

# FROM debian:bullseye-slim AS runtime

# RUN apt-get update && apt-get install curl jq -y && apt-get clean

# COPY --from=builder /src/app/ /src/app/
# COPY --from=builder /root/go/bin/agd /root/go/bin/agd

# ENV PATH="/root/go/bin:${PATH}"

ENTRYPOINT ["agd"]
CMD ["version"]
