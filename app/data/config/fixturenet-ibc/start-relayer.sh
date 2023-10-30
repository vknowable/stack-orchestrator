#!/bin/bash

# initialize config file
if [ ! -f "$HOME/.agoric-shared/genesis.json" ]; then
  rly config init

  # add chain/rpc info to configs
  rly chains add --file $HOME/chains/agoric-localnet.json agoric-localnet
  rly chains add --file $HOME/chains/gaia-localnet.json gaia-localnet
fi

# add the pre-funded relayer accounts created at genesis
# pause for mnemonics to be created
while [ ! -f "$HOME/.agoric-shared/agoric_relayer_key" -o ! -f "$HOME/.gaia-shared/gaia_relayer_key" ]; do
  echo "Waiting for relayer account keys. Sleeping for 5s..."
  sleep 5
done

echo "Adding accounts:"
AGORIC_MNEMONIC=$(cat $HOME/.agoric-shared/agoric_relayer_key)
rly keys restore agoric-localnet relayer-key "$AGORIC_MNEMONIC" --coin-type 564
GAIA_MNEMONIC=$(cat $HOME/.gaia-shared/gaia_relayer_key)
rly keys restore gaia-localnet relayer-key "$GAIA_MNEMONIC"

# wait for both chains to start making blocks
AGORIC_HEIGHT=0
GAIA_HEIGHT=0
while [ -z "$AGORIC_HEIGHT" ] || [ -z "$GAIA_HEIGHT" ] || [ "$AGORIC_HEIGHT" -le 2 ] || [ "$GAIA_HEIGHT" -le 2 ]; do
  AGORIC_HEIGHT=$(curl -s ibc-agd-fullnode-1:26657/status | jq -r .result.sync_info.latest_block_height)
  GAIA_HEIGHT=$(curl -s ibc-gaiad-fullnode-1:26657/status | jq -r .result.sync_info.latest_block_height)
  echo "Waiting for chains. Sleeping for 5s..."
  sleep 5
done

# create an entry in the configs for the path between the two chains, which we will open in the next step
rly paths new gaia-localnet agoric-localnet localnet_path

echo "Creating ibc connection:"
rly transact link localnet_path

echo "\n\n*********************************"
echo "Starting relayer:"
rly start
