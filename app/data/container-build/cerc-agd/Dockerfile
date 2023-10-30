ARG AGD_TAG=agoric-upgrade-11

FROM node:18-bullseye

# add go
COPY --from=golang:1.20-bullseye /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"
ENV PATH="/root/go/bin:${PATH}"

RUN apt-get update && apt-get install git build-essential curl jq -y && apt-get clean

WORKDIR /src/agoric-sdk/
COPY . .
RUN yarn install
RUN yarn build

RUN (cd packages/cosmic-swingset && make)

ENTRYPOINT ["agd"]
CMD ["version"]
