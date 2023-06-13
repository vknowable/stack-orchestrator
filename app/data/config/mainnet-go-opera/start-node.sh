#!/bin/bash

echo "genesis file: $GENESIS_FILE"
# If genesis file was provided from host filesystem, use as node's genesis file
if [ "$GENESIS_FILE" != "/dev/null" ]; then
  #mv /host_genesis.g /genesis.g
  RUN_GENESIS="/host_genesis.g"
else
  RUN_GENESIS="/genesis.g"
fi

# Configure for API or validator node
echo "is validator: $IS_VALIDATOR"
if [ "$IS_VALIDATOR" == true ]; then
  GENESIS_URL=https://files.fantom.network/mainnet-171200-pruned-mpt.g
  OPERA_ARGS="--genesis=$RUN_GENESIS --genesis.allowExperimental --syncmode snap --db.preset ldb-1 --cache 8192"
else
  GENESIS_URL=https://download.fantom.network/mainnet-109331-pruned-mpt.g
  OPERA_ARGS="--genesis=$RUN_GENESIS --genesis.allowExperimental --db.preset ldb-1 --syncmode snap --http --http.addr=\"0.0.0.0\" --http.corsdomain=\"*\" --http.api=eth,web3,net,txpool,ftm --ws --ws.addr=\"0.0.0.0\" --ws.origins=\"*\" --ws.api=eth,web3,net,ftm --cache 8192"
fi

# Download genesis file if not already present
if [ "$RUN_GENESIS" = "/genesis.g" -a ! -f "/genesis.g" ]; then
  echo "Downloading genesis file..."
  wget -O genesis.g $GENESIS_URL
else
  echo "Genesis file found. Skipping download."
fi

./opera $OPERA_ARGS


#./opera --genesis=/genesis.g --genesis.allowExperimental --db.preset ldb-1 --syncmode snap --http --http.addr="0.0.0.0" --http.corsdomain="*" --http.api=eth,web3,net,txpool,ftm --ws --ws.origins="*" --ws.api=eth,web3,net,ftm --cache 8192
#tail -f /dev/null
