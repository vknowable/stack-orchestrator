#!/bin/bash

gaiad version

KEY="$(hostname)-key"
CHAIN_ID=${CHAIN_ID:-gaia-local}
MONIKER="$(hostname)" 
KEYRING_BACKEND="test"
LOGLEVEL=info

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

gaiad config keyring-backend $KEYRING_BACKEND
gaiad config chain-id $CHAIN_ID

gaiad keys add $KEY

gaiad init $MONIKER --chain-id $CHAIN_ID

# on validator node only, generate genesis file
if [ $(hostname) = "gaiad-validator" ]; then
  # Change parameter token denominations to uatom
  cat $HOME/.gaia/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json
  cat $HOME/.gaia/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json
  cat $HOME/.gaia/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json
  cat $HOME/.gaia/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="uatom"' > $HOME/.gaia/config/tmp_genesis.json && mv $HOME/.gaia/config/tmp_genesis.json $HOME/.gaia/config/genesis.json

  # allocate genesis accounts (cosmos formatted addresses)
  gaiad add-genesis-account $KEY 100000000000000000000000000uatom

  # sign genesis transaction
  gaiad gentx $KEY 1000000000000000000000uatom --chain-id $CHAIN_ID

  # collect genesis tx
  gaiad collect-gentxs

  # run this to ensure everything worked and that the genesis file is setup correctly
  gaiad validate-genesis

  # validator config changes
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's#indexer = "kv"#indexer = "null"#g' $HOME/.gaia/config/config.toml
  else
    # turn off indexing
    sed -i 's#indexer = "kv"#indexer = "null"#g' $HOME/.gaia/config/config.toml
  fi

  # write peer info (nodeid@ip-addr) to shared volume
  cat $HOME/.gaia/config/gentx/gentx-* | jq -r .body.memo | tee $HOME/.gaia-shared/peers.txt

  # copy genesis file to shared volume
  cp $HOME/.gaia/config/genesis.json $HOME/.gaia-shared/genesis.json

# full-node will wait until genesis file is prepared
else
  while [ ! -f "$HOME/.gaia-shared/genesis.json" ]; do
    echo "genesis.json not found. Sleeping for 5s..."
    sleep 5
  done

  echo "genesis.json found, proceeding with setup"
  cp $HOME/.gaia-shared/genesis.json $HOME/.gaia/config/genesis.json
  PERSISTENT_PEERS=$(cat $HOME/.gaia-shared/peers.txt)

  # full-node config changes
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # open rpc
    sed -i '' 's#laddr = "tcp://127.0.0.1:26657"#laddr = "tcp://0.0.0.0:26657"#g' $HOME/.gaia/config/config.toml
    sed -i '' 's#cors_allowed_origins = \[\]#cors_allowed_origins = \["*"\]#g' $HOME/.gaia/config/config.toml
    # disable pruning
    sed -i '' 's#pruning = "default"#pruning = "nothing"#g' $HOME/.gaia/config/app.toml
    # enable prometheus
    sed -i '' 's#prometheus = false#prometheus = true#g' $HOME/.gaia/config/config.toml
    sed -i '' 's#namespace = "cometbft"#namespace = "tendermint"#g' $HOME/.gaia/config/config.toml
    # set persistent peers
    sed -i '' "s#persistent_peers = \"\"#persistent_peers = \"$PERSISTENT_PEERS\"#g" $HOME/.gaia/config/config.toml
  else
    # open rpc
    sed -i 's#laddr = "tcp://127.0.0.1:26657"#laddr = "tcp://0.0.0.0:26657"#g' $HOME/.gaia/config/config.toml
    sed -i 's#cors_allowed_origins = \[\]#cors_allowed_origins = \["*"\]#g' $HOME/.gaia/config/config.toml
    # disable pruning
    sed -i 's#pruning = "default"#pruning = "nothing"#g' $HOME/.gaia/config/app.toml
    # enable prometheus
    sed -i 's#prometheus = false#prometheus = true#g' $HOME/.gaia/config/config.toml
    sed -i 's#namespace = "cometbft"#namespace = "tendermint"#g' $HOME/.gaia/config/config.toml
    # set persistent peers
    sed -i "s#persistent_peers = \"\"#persistent_peers = \"$PERSISTENT_PEERS\"#g" $HOME/.gaia/config/config.toml
  fi
fi

gaiad start --log_level $LOGLEVEL --minimum-gas-prices=0.0001uatom
