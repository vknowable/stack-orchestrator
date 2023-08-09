# Namada (public tesnet)

Deploy a Namada full node to connect to an existing testnet.

### Quickstart
Join the latest public testnet:
```
$ laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=<namada version>"
$ mkdir -p ~/.local/share/namada
$ laconic-so --stack public-namada deploy up
```
Join a private testnet:
```
$ laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=<namada version> --build-arg BUILD_WASM=true"
$ mkdir -p ~/.local/share/namada
$ tee <<EOF >/dev/null ~/namada.env
  > CHAIN_ID=<chain id>
  > PERSISTENT_PEERS="tcp://<node id>@<peer ip>:<port>"
  > CONFIGS_SERVER=http://<ip>:<port>
  > EXTIP=<your public IP>
  > EOF
$ laconic-so --stack public-namada deploy --env-file ~/namada.env up
```
---
### Detailed Instructions
### 1. Build containers
Build the Namada binaries, wasm files, and CometBFT:
```
$ laconic-so --stack public-namada build-containers
```
This will default to the `main` branch of Namada; to join a testnet you will normally need to checkout a specific version. Specify the version to build like so:
```
$ laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=v0.20.1"
```
If you're joining a private testnet, you'll also need to build the wasm files with `BUILD_WASM=true`:
```
$ laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=v0.20.1 --build-arg BUILD_WASM=true"
```

### 2. Create data directory
Create a directory to hold the Namada chain and config data:
```
$ mkdir -p ~/.local/share/namada
```
You can also choose a different location using the `NAMADA_DATA_DIR` variable.

### 3. Start the node
Start the node with:
```
$ laconic-so --stack public-namada deploy up
```
By default, this will attempt to find and connect to the chain-id of the latest public testnet listed on the repo `https://github.com/heliaxdev/anoma-network-config`. To connect to a different network, see **Section 6**.

### 4. Stop the node
Stop/remove containers and clean-up resources:
```
$ laconic-so --stack public-namada deploy down --delete-volumes
```
The chain data and configs will remain in `NAMADA_DATA_DIR`; you can delete them manually if no longer needed.

### Configuration options
**Container build args:**
- `NAMADA_TAG`: git release to checkout
- `BUILD_WASM=true|false`: whether to compile the wasm (default true)

**Runtime env variables:**
To change any settings from their default values, place the corresponding environment variables in a file (see [sample.env](https://github.com/vknowable/stack-orchestrator/blob/namada/app/data/config/public-namada/sample.env)) and include it in the start command:
```
$ laconic-so --stack public-namada deploy ---env-file <filename> up
```
- `NAMADA_DATA_DIR`: host directory to use for data storage (default `~/.local/share/namada`)
- `P2P_PORT`: host port to use for P2P. (default `26656`)
- `RPC_PORT`: host port to use for CometBFT RPC. (default `26657`)
- `PROM_PORT`: host port to use for Prometheus metrics. (default `26660`)
- `CHAIN_ID`: chain id to connect to. (default fetch latest from github)
- `EXTIP=x.x.x.x:<p2p port>`: external IP:port to broadcast to peers, ie: typically your host machine's public IP. (default `""`)
- `RPC_LISTEN=true|false`: if true, RPC will listen on `0.0.0.0`; otherwise it will listen on container's `localhost` only. (default `false`)
- `RPC_CORS_ALLOWED`: list of allowed CORS origins. Format like this (don't forget the outer single quotes): `'["host 1", "host 2", ..., "host n"]'`. Use `'["*"]'` to allow all hosts. (default `'[]'`)
- `INDEXER=null|kv|psql`: configure CometBFT transaction indexing; or `null` to disable. (default `null`)
- `PROM_ENABLE=true|false`: whether to enable Prometheus metrics
- `PERSISTENT_PEERS`: a comma-separated list of persistent peers to connect to. (default use peers listed in genesis file)
- `CONFIGS_SERVER=http://x.x.x.x:<port>`: if joining a private testnet, the download location of the chain config *.tar.gz*

### Interacting with the node
You can use Docker commands as you normally would to interact with the container.  
First, get the container id:
```
$ docker ps
```
Check logs, which should show blocks syncing:
```
$ docker logs -f <container id>
```
Check node status:
```
$ docker exec <container id> "curl localhost:26657/status"
```
Get a bash shell inside the container:
```
$ docker exec -it <container id> /bin/bash
```
