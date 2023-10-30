#!/bin/bash

agd version

NODE_KEY="$(hostname)-key"
RELAYER_KEY="relayer-key"
CHAIN_ID=${CHAIN_ID:-agoric-localnet}
MONIKER="$(hostname)" 
KEYRING_BACKEND="test"
LOGLEVEL=info

# validate dependencies are installed
command -v jq > /dev/null 2>&1 || { echo >&2 "jq not installed. More info: https://stedolan.github.io/jq/download/"; exit 1; }

agd config keyring-backend $KEYRING_BACKEND
agd config chain-id $CHAIN_ID

# add node key
agd keys add $NODE_KEY

agd init $MONIKER --chain-id $CHAIN_ID

# on validator node only, generate genesis file
if [ $(hostname) = "agd-validator" ]; then
  # Change parameter token denominations to ubld
  cat $HOME/.agoric/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="ubld"' > $HOME/.agoric/config/tmp_genesis.json && mv $HOME/.agoric/config/tmp_genesis.json $HOME/.agoric/config/genesis.json
  cat $HOME/.agoric/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="ubld"' > $HOME/.agoric/config/tmp_genesis.json && mv $HOME/.agoric/config/tmp_genesis.json $HOME/.agoric/config/genesis.json
  cat $HOME/.agoric/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="ubld"' > $HOME/.agoric/config/tmp_genesis.json && mv $HOME/.agoric/config/tmp_genesis.json $HOME/.agoric/config/genesis.json
  cat $HOME/.agoric/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="ubld"' > $HOME/.agoric/config/tmp_genesis.json && mv $HOME/.agoric/config/tmp_genesis.json $HOME/.agoric/config/genesis.json

  # we also need to fund an account for the relayer
  # create a key and store the mnemonic so the relayer can import it later
  agd keys add $RELAYER_KEY 2>relayer_key_outfile
  RELAYER_MNEMONIC=$(tail -n 1 relayer_key_outfile)

  # allocate genesis accounts (cosmos formatted addresses)
  agd add-genesis-account $NODE_KEY 100000000000000000000000000ubld,100000000000000000000000000uist --keyring-backend $KEYRING_BACKEND
  agd add-genesis-account $RELAYER_KEY 100000000000000000000000000ubld,100000000000000000000000000uist --keyring-backend $KEYRING_BACKEND

  # sign genesis transaction
  agd gentx $NODE_KEY 1000000000000000000000ubld --chain-id $CHAIN_ID

  # collect genesis tx
  agd collect-gentxs

  # run this to ensure everything worked and that the genesis file is setup correctly
  agd validate-genesis

  # validator config changes
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's#indexer = "kv"#indexer = "null"#g' $HOME/.agoric/config/config.toml
  else
    # turn off indexing
    sed -i 's#indexer = "kv"#indexer = "null"#g' $HOME/.agoric/config/config.toml
  fi

  # write peer info (nodeid@ip-addr) to shared volume
  cat $HOME/.agoric/config/gentx/gentx-* | jq -r .body.memo | tee $HOME/.agoric-shared/peers.txt

  # copy genesis file to shared volume
  cp $HOME/.agoric/config/genesis.json $HOME/.agoric-shared/genesis.json

  # write relayer mnemonic to shared volume
  echo "$RELAYER_MNEMONIC" > $HOME/.agoric-shared/agoric_relayer_key

# full-node will wait until genesis file is prepared
else
  while [ ! -f "$HOME/.agoric-shared/genesis.json" ]; do
    echo "genesis.json not found. Sleeping for 5s..."
    sleep 5
  done

  echo "genesis.json found, proceeding with setup"
  cp $HOME/.agoric-shared/genesis.json $HOME/.agoric/config/genesis.json
  PERSISTENT_PEERS=$(cat $HOME/.agoric-shared/peers.txt)

  # full-node config changes
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # open rpc
    sed -i '' 's#laddr = "tcp://127.0.0.1:26657"#laddr = "tcp://0.0.0.0:26657"#g' $HOME/.agoric/config/config.toml
    sed -i '' 's#cors_allowed_origins = \[\]#cors_allowed_origins = \["*"\]#g' $HOME/.agoric/config/config.toml
    # disable pruning
    sed -i '' 's#pruning = "default"#pruning = "nothing"#g' $HOME/.agoric/config/app.toml
    # enable prometheus
    sed -i '' 's#prometheus = false#prometheus = true#g' $HOME/.agoric/config/config.toml
    sed -i '' 's#namespace = "cometbft"#namespace = "tendermint"#g' $HOME/.agoric/config/config.toml
    # set persistent peers
    sed -i '' "s#persistent_peers = \"\"#persistent_peers = \"$PERSISTENT_PEERS\"#g" $HOME/.agoric/config/config.toml
  else
    # open rpc
    sed -i 's#laddr = "tcp://127.0.0.1:26657"#laddr = "tcp://0.0.0.0:26657"#g' $HOME/.agoric/config/config.toml
    sed -i 's#cors_allowed_origins = \[\]#cors_allowed_origins = \["*"\]#g' $HOME/.agoric/config/config.toml
    # disable pruning
    sed -i 's#pruning = "default"#pruning = "nothing"#g' $HOME/.agoric/config/app.toml
    # enable prometheus
    sed -i 's#prometheus = false#prometheus = true#g' $HOME/.agoric/config/config.toml
    sed -i 's#namespace = "cometbft"#namespace = "tendermint"#g' $HOME/.agoric/config/config.toml
    # set persistent peers
    sed -i "s#persistent_peers = \"\"#persistent_peers = \"$PERSISTENT_PEERS\"#g" $HOME/.agoric/config/config.toml
  fi
fi

agd start --log_level $LOGLEVEL #--minimum-gas-prices=0.0001ubld
