#!/bin/bash

TENDERMINT_ADDR=${TENDERMINT_ADDR:-172.17.0.1}
TENDERMINT_PORT=${TENDERMINT_PORT:-26657}
      
# If no chain id provided, try to find the latest one from https://api.github.com/repos/heliaxdev/anoma-network-config/releases/latest
if [ -z "$CHAIN_ID" ]; then
  echo "Chain Id not provided, attempting to fetch latest public chain id from https://github.com/heliaxdev/anoma-network-config..."
  API_ENDPOINT=https://api.github.com/repos/heliaxdev/anoma-network-config/releases/latest
  CHAIN_ID=$(curl -sL "$API_ENDPOINT" | grep -m 1 '"name":' | awk -F '"' '{print $4}')
  # If chain id could still not be obtained using github api
  if [ -z "$CHAIN_ID" ]; then
    echo "Chain Id could not be fetched from GitHub. Please set env variable CHAIN_ID in your .env file prior to starting container."
    exit 1
  fi
fi

echo "Using Chain Id: $CHAIN_ID"

# fetch wasm checksums if not already present
if [ ! -f "/app/checksums.json" ]; then
  echo "checksums.json does not exist in wasm dir. Downloading and extracting..."
  # Set chain configs server
  if [ -z "$CONFIGS_SERVER" ]; then
    HELIAX_CONFIGS="https://github.com/heliaxdev/anoma-network-config/releases/download/"
    echo "Fetching configs from url ${HELIAX_CONFIGS}..."
  else
    echo "Fetching configs from url ${CONFIGS_SERVER}..."
  fi
  wget "${CONFIGS_SERVER}/${CHAIN_ID}.tar.gz" -P /app
  tar -xvf ${CHAIN_ID}.tar.gz -C /app
  cp /app/.namada/${CHAIN_ID}/wasm/checksums.json /app/checksums.json
else
  echo "checksums.json found."
fi

# replace placeholder text in the TOML file with environment variables
sed "s/TENDERMINT_ADDR/$TENDERMINT_ADDR/g; s/TENDERMINT_PORT/$TENDERMINT_PORT/g" /app/config/Settings_template.toml > /app/config/Settings.toml

# start indexer
echo "starting indexer..."
/usr/local/bin/indexer