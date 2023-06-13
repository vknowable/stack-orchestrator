#!/bin/bash

# download genesis file
wget https://download.fantom.network/mainnet-109331-no-history.g

#./opera --genesis=mainnet-109331-no-history.g --db.preset ldb-1 --syncmode snap --http --http.addr="0.0.0.0" --http.corsdomain="*" --http.api=eth,web3,net,txpool,ftm
./opera --genesis=mainnet-109331-no-history.g --db.preset ldb-1 --syncmode snap --http --http.addr="0.0.0.0" --http.corsdomain="*" --http.api=eth,web3,net,txpool,ftm --ws --ws.origins="*" --ws.addr="0.0.0.0" --ws.api=eth,web3,net,ftm --cache 8192
#tail -f /dev/null
