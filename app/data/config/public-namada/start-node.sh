#!/bin/bash

namada --version

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

# Download chain configs and init directories
if [ -z "$CONFIGS_SERVER" ]; then
  echo "Fetching configs from Heliax repo..."
  # Attempt to download configs and wasm from Heliax repo (default behaviour)
  namada client utils join-network --chain-id $CHAIN_ID
else
  echo "Fetching configs from ${CONFIGS_SERVER}..."
  # Use alternate configs server if provided (eg: internal testnet)
  export NAMADA_NETWORK_CONFIGS_SERVER="${CONFIGS_SERVER}"
  namada client utils join-network --chain-id $CHAIN_ID --dont-prefetch-wasm
  # copy wasm to namada dir
  cp -a /app/namada/wasm/*.wasm /root/.local/share/namada/$CHAIN_ID/wasm
  cp -a /app/namada/wasm/checksums.json /root/.local/share/namada/$CHAIN_ID/wasm
fi

# set config options
# External IP to advertise to peers; you may wish to set this explicitly if you're eg: behind a NAT
EXTIP=${EXTIP:-''}
sed -i "s#external_address = \".*\"#external_address = \"$EXTIP\"#g" /root/.local/share/namada/$CHAIN_ID/config.toml

# Whether RPC should listen for outside requests, or just localhost
if [ "$RPC_LISTEN" == "true" ]; then
  sed -i "s#laddr = \"tcp://.*:26657\"#laddr = \"tcp://0.0.0.0:26657\"#g" /root/.local/share/namada/$CHAIN_ID/config.toml
else
  sed -i "s#laddr = \"tcp://.*:26657\"#laddr = \"tcp://127.0.0.1:26657\"#g" /root/.local/share/namada/$CHAIN_ID/config.toml
fi

RPC_CORS_ALLOWED=${RPC_CORS_ALLOWED:-'[]'}
sed -i "s#cors_allowed_origins = .*#cors_allowed_origins = $RPC_CORS_ALLOWED#g" /root/.local/share/namada/$CHAIN_ID/config.toml

INDEXER=${INDEXER:-null}
sed -i "s#indexer = \".*\"#indexer = \"$INDEXER\"#g" /root/.local/share/namada/$CHAIN_ID/config.toml


########################################
# start the node
NAMADA_LOG=info \
CMT_LOG_LEVEL=p2p:none,pex:error \
NAMADA_CMT_STDOUT=true \
# NAMADA_LEDGER__COMETBFT__P2P_EXTERNAL_ADDRESS=$EXTIP \
# NAMADA_LEDGER__COMETBFT__RPC__LADDR="${RPC_LISTEN_ADDR:-tcp://127.0.0.1:26657}" \
# NAMADA_LEDGER__COMETBFT__RPC__CORS_ALLOWED_ORIGINS="${RPC_CORS_ALLOWED:-localhost}" \
# NAMADA_LEDGER__COMETBFT__RPC__CORS_ALLOWED_ORIGINS="${RPC_CORS_ALLOWED:+$RPC_CORS_ALLOWED,}localhost" \
# NAMADA_LEDGER__COMETBFT__TX_INDEX="${INDEXER:-null}" \
NAMADA_LEDGER__COMETBFT__INSTRUMENTATION__PROMETHEUS="${PROM_ENABLE:-true}" \
namada node ledger run
