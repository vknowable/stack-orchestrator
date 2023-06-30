#!/bin/bash

namada --version

if [ -z "$CHAIN_ID" ]; then
  echo "Chain Id required but not provided. Please set env variable CHAIN_ID"
  exit 1
fi

EXTIP=${EXTIP:-""}
namada client utils join-network --chain-id $CHAIN_ID
#CMT_LOG_LEVEL=p2p:none,pex:error namada node ledger run
NAMADA_LOG=info CMT_LOG_LEVEL=p2p:none,pex:error NAMADA_CMT_STDOUT=true NAMADA_LEDGER__COMETBFT__P2P_EXTERNAL_ADDRESS=true namada node ledger run
