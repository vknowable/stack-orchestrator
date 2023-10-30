# Fixturenet-IBC test stack

Create a local IBC fixturenet, which will start two Cosmos chains, create an IBC connection, and start the relayer in packet-relay mode. The stack consists of:
- a Gaiad chain, with one validator and one full-node
- an Agoric chain, with one validator and one full-node
- a [Go-Relayer](https://github.com/cosmos/relayer)

## Using the stack

### 1. Clone repositories
Run
```
laconic-so --stack fixturenet-ibc setup-repositories
```
to clone the required repositories into `~/cerc`.

### 2. Build containers
Run
```
laconic-so --stack fixturenet-ibc build-containers
```
to build the containers for `gaiad`, `agd` (Agoric) and `rly` (Go-Relayer).

### 3. Start stack
Run
```
laconic-so --stack fixturenet-ibc deploy --cluster ibc up
```
to start all containers and run their startup jobs. (Make sure to include the `--cluster ibc` option to ensure that all containers have the expected names, as their internal scripts rely on this naming convention when making http requests to each other).

### 4. Wait for startup jobs to complete
It will take about 3-5 minutes to start the chains and open the IBC channel. You can view the progress by watching the container logs; specifically, you can run:
```
docker logs -f ibc-relayer-1
```
to watch the relayer create the IBC channel and start in packet-relay mode. When it's ready to relay packets, you'll see the following logs:
```
*********************************
Starting relayer:
2023-10-27T17:35:24.878659Z     info    Debug server listening  {"sys": "debughttp", "addr": ":5183"}
2023-10-27T17:35:24.883337Z     info    Chain is not yet in sync        {"chain_name": "agoric-localnet", "chain_id": "agoric-localnet", "latest_queried_block": 0, "latest_height": 18}
2023-10-27T17:35:24.883523Z     info    Chain is not yet in sync        {"chain_name": "gaia-localnet", "chain_id": "gaia-localnet", "latest_queried_block": 3, "latest_height": 23}
2023-10-27T17:35:24.908617Z     info    Successfully created new channel        {"chain_name": "gaia-localnet", "chain_id": "gaia-localnet", "channel_id": "channel-0", "connection_id": "connection-0", "port_id": "transfer"}
2023-10-27T17:35:24.909176Z     info    Successfully created new channel        {"chain_name": "agoric-localnet", "chain_id": "agoric-localnet", "channel_id": "channel-0", "connection_id": "connection-0", "port_id": "transfer"}
2023-10-27T17:35:25.881432Z     info    Chain is in sync        {"chain_name": "gaia-localnet", "chain_id": "gaia-localnet"}
2023-10-27T17:35:25.881483Z     info    Chain is in sync        {"chain_name": "agoric-localnet", "chain_id": "agoric-localnet"}
```

### 5. Send an IBC transfer
Cosmos IBC transfers take the following form:
```
<daemon> tx ibc-transfer transfer <port> <channel> <receiver address> <token> --from <sender key>
```
We'll send a transfer of 100uatom from our Gaia validator's wallet to our Agoric validator's wallet. We can use the parameters:
- `<daemon>` will be `gaiad`
- `<port>` will always be `transfer` for token transfers.
- `<channel>` will be `channel-0` because it was the first channel created. (Any additional channels created will increment by one: `channel-1`, etc.)
- `<receiver address>` will be the address on the receiving chain, ie: the `agoric...` address. Run `docker exec ibc-agd-validator-1 agd keys list` and copy the address listed under `agd-validator-key`
- `<token>` will be `100uatom`
- `<sender-key>` is the name of the wallet sending the funds; in this example use `gaiad-validator-key`

Now send the transfer from our Gaia validator (your receiving address will be different than below):
```
docker exec ibc-gaiad-validator-1 /bin/bash -c "gaiad tx ibc-transfer transfer transfer channel-0 agoric10prqag5k62xc03599n6kjsf80y38xwpf0pd0ct 100uatom --from gaiad-validator-key -y"
```
Output:
```
code: 0
codespace: ""
data: ""
events: []
gas_used: "0"
gas_wanted: "0"
height: "0"
info: ""
logs: []
raw_log: '[]'
timestamp: ""
tx: null
txhash: B1779CF6465D76335AEF96F6AF68C7D8F59432D112235941D5F9B2C8C81EE883
```
You can optionally check the relayer's logs to see confirmation of the packet relay:
```
2023-10-27T18:14:38.285941Z     info    Successful transaction  {"provider_type": "cosmos", "chain_id": "agoric-localnet", "packet_src_channel": "channel-0", "packet_dst_channel": "channel-0", "gas_used": 181520, "fees": "42563ubld", "fee_payer": "agoric1q6nq0av0ux4xk2vfz6u0w403u0ws3qnmdaejvf", "height": 483, "msg_types": ["/ibc.core.client.v1.MsgUpdateClient", "/ibc.core.channel.v1.MsgRecvPacket"], "tx_hash": "0CC08F26D91493DC651682F03E5B1B241F9467A26F4FA055C3B49F3D60421E75"}
2023-10-27T18:14:45.148927Z     info    Successful transaction  {"provider_type": "cosmos", "chain_id": "gaia-localnet", "packet_src_channel": "channel-0", "packet_dst_channel": "channel-0", "gas_used": 139548, "fees": "29807uatom", "fee_payer": "cosmos1whgwt5al0z5tka76jtvev67g9cglvd3p93cmyc", "height": 490, "msg_types": ["/ibc.core.client.v1.MsgUpdateClient", "/ibc.core.channel.v1.MsgAcknowledgement"], "tx_hash": "8707C4274B2FC71B816E631AB7D379855B97BE458EAAE37FD629994F35C239BD"}
```
Finally, check the balance of the receiving account (your address will be different):
```
docker exec ibc-agd-validator-1 agd query bank balances agoric10prqag5k62xc03599n6kjsf80y38xwpf0pd0ct
```
Output:
```
balances:
- amount: "100"
  denom: ibc/27394FB092D2ECCD56123C74F36E4C1F926001CEADA9CA97EA622B25F41E5EB2
- amount: "99999000000000000000000000"
  denom: ubld
- amount: "100000000000000000000000000"
  denom: uist
pagination:
  next_key: null
  total: "0"
```
We can see 100 of the ibc-prefixed token have been received.

### 6. Shutdown/cleanup
Stop all processes and cleanup any data with:
```
laconic-so --stack fixturenet-ibc deploy --cluster ibc down --delete-volumes
```