# Namada (local tesnet)

Deploy a Namada local testnet with three validators.

### Quickstart
```
$ laconic-so --stack local-namada setup-repositories
$ laconic-so --stack local-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=<namada git tag> --build-arg BUILD_WASM=true"
$ laconic-so --stack local-namada deploy up
```
---
### Detailed Instructions
### 1. Clone required repositories
```
$ laconic-so --stack local-namada setup-repositories
```
Cloned repos can be found in $HOME/cerc

### 2. Build containers
Build the Namada binaries, wasm files, and CometBFT:
```
$ laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=<namada git tag> --build-arg BUILD_WASM=true"
```

### 3. Start the testnet
```
$ laconic-so --stack local-namada deploy up
```
You can configure some settings by passing a .env file (see [sample.env](https://github.com/vknowable/stack-orchestrator/blob/local-namada/app/data/config/local-namada/sample.env)):
```
$ laconic-so --stack local-namada deploy --env-file <file> up
```
List of (optional) env variables:
- `EXTIP`: external IP address that the namada-1 node will advertise to peers. If you wish to allow outside nodes to connect, set this to your host machine's public IP.
- `P2P_PORT`: set a P2P port on the host corresponding the namada-1 node, if you wish to allow outside nodes to connect.
- `SERVE_PORT`: the namada-1 node will serve the generated chain configs over http to the other nodes; you can set a corresponding port on the host machine if you wish to allow outside nodes access
- `GENESIS_TEMPLATE`: a path to a template genesis toml to use as a base when generating the chain configs. You can find an appropriate file for your Namada version from [this repo](https://github.com/heliaxdev/anoma-network-config/tree/master/templates).

#### Check logs
```
$ laconic-so --stack local-namada deploy logs
```
You should see logs indicating that blocks are being created:
```
laconic-d4b13d373d0a85a0a4d865588760241a-namada-1-1  | I[2023-07-11|05:39:50.614] received proposal                            module=consensus proposal="Proposal{13/0 (3D69F58E96B3E5A7CFCFF32BB2141ED295BB1EB6655C08F2D2E5F14DEDF19DC7:1:5BE4A75DCA81, -1) 178144951342 @ 2023-07-11T05:39:50.503187702Z}"
laconic-d4b13d373d0a85a0a4d865588760241a-namada-3-1  | I[2023-07-11|05:28:30.216] committed state                              module=state height=12 num_txs=0 app_hash=E09AB3A4A47DF1D8024796ACEE7AE492A609BF421D55DA6E05EBC88F9598DC62
laconic-d4b13d373d0a85a0a4d865588760241a-namada-1-1  | I[2023-07-11|05:39:50.614] received complete proposal block             module=consensus height=13 hash=3D69F58E96B3E5A7CFCFF32BB2141ED295BB1EB6655C08F2D2E5F14DEDF19DC7
laconic-d4b13d373d0a85a0a4d865588760241a-namada-3-1  | I[2023-07-11|05:28:30.225] indexed block exents                         module=txindex height=12
laconic-d4b13d373d0a85a0a4d865588760241a-namada-1-1  | I[2023-07-11|05:39:50.978] finalizing commit of block                   module=consensus height=13 hash=3D69F58E96B3E5A7CFCFF32BB2141ED295BB1EB6655C08F2D2E5F14DEDF19DC7 root=0CE7227BFAF574E736BF0FEC2133DABA9ACAC629C00AFF67688F34A6C64435B3 num_txs=0
```

#### Use the testnet
Since the nodes are Docker containers, all the usual Docker commands still apply. For example, to get a shell in one of the nodes:
```
$ docker ps
# get the node's container id

$ docker exec -it {container id} /bin/bash

root@namada-1:/# namada client bonded-stake
2023-07-12T13:04:40.131123Z  INFO namada_apps::cli::context: Chain ID: knowable.21da85822742c00e702bf
Last committed epoch: 491
Consensus validators:
  atest1v4ehgw36xycnws6pgveyvde5g4z5g33hx3ryyvjrgdprwse5xazrssfh89ryys3k8qcnzde55vznxy: 100000.000000
  atest1v4ehgw368pzy2v3kxcurqvfcxv6rxd3nxaprvvengc6yxd2xxyc52d2yg56nydfnxvcygvzxp4p6a6: 100000.000000
  atest1v4ehgw36xdq5xsesgdzyzvpn8qu5xv29gdpyxw2xgcc523jzxapnwdphg3ryvdpjx9prx3zryaezrt: 100000.000000
Total bonded stake: 300000.000000
```

### 4. Shut down
```
$ laconic-so --stack local-namada deploy down --delete-volumes
```
