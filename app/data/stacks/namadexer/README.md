# Namadexer

Deploy [Namadexer](https://github.com/Zondax/namadexer/tree/main) indexer/server/db

### Prerequisite
You will need a full node with the Tendermint RPC (e.g.: `http://localhost:26657`) accessible.  

### 1. Clone repositories
Clone the Namadexer repo:
```
$ laconic-so --stack namadexer setup-repositories
```

### 2. Build containers
Build the Namadexer containers:
```
$ laconic-so --stack namadexer build-containers
```

### 3. Set env variables
Create a text file with the following info to let the indexer know how to connect with your chain node. `TENDERMINT_ADDR` and `TENDERMINT_PORT` are required; `CONFIGS_SERVER` and `CHAIN_ID` are needed to connect to an arbitrary testnet, but will default to fetching the configs for the latest Heliax public testnet `public-testnet-xxxx` from GitHub if not provided. (Namadexer needs to fetch the chain configs to get the chain's checksums.json file.)  

Remember to set Tendermint's IP address relative to the Docker container. For example, if your node is running on the same machine, the IP address relative to the container will be something like `172.16.0.1` instead of `localhost`. You can find the IP address of your host machine relative to Docker using the command `ip a` and looking for the entry for the `docker0` interface.
```
# sample namadexer.env
CONFIGS_SERVER=https://testnet.luminara.icu/configs
CHAIN_ID=luminara.e41ce04cc1788ebdcc527
TENDERMINT_ADDR=172.16.0.1
TENDERMINT_PORT=36657
```

### 4. Start the stack
Start the Namadexer stack with:
```
$ laconic-so --stack namadexer deploy --env-file <.env file created in step 3> up
```
By default, this will attempt to find and connect to the chain-id of the latest public testnet listed on the repo `https://github.com/heliaxdev/anoma-network-config`. To connect to a different network, see **Section 6**.

### 5. Stop the stack
Stop/remove containers and clean-up resources:
```
$ laconic-so --stack namadexer deploy down --delete-volumes
```

### Interacting with the stack
You can check the logs for the indexer container directly to see how indexing is progressing:
```
$ docker ps
# get the container id corresponding to the indexer container

$ docker logs -f <indexer container id>
```
You should see log entries indicating blocks are being indexed.  

The Namadexer server also exposes a json RPC on port `3030`. For example:
```
$ curl -H 'Content-Type: application/json' localhost:3030/block/last
```

Check the project docs at https://github.com/Zondax/namadexer/blob/main/docs/04-server.md for a list of endpoints and example queries.
