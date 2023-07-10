#!/bin/bash

# TODO: move apt installs to container build
# TODO: set chain-prefix by env var

namada --version

apt install -y procps # move to build

# clean up the http server when the script exits
cleanup() {
    pkill -f "/serve"
}

# generate validator keys
export PUBLIC_IP=$(ip a | grep -oE 'inet ([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2} brd ([0-9]{1,3}\.){3}[0-9]{1,3}' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d '/' -f1)
export ALIAS=$(hostname)
namada client utils init-genesis-validator --alias $ALIAS \
--max-commission-rate-change 0.01 --commission-rate 0.05 \
--net-address $PUBLIC_IP:26656 --unsafe-dont-encrypt

# Pre-genesis toml is written to /root/.local/share/namada/pre-genesis/namada-x/validator.toml
mkdir -p /root/.namada-shared/$ALIAS
cp -a /root/.local/share/namada/pre-genesis/$ALIAS/validator.toml /root/.namada-shared/$ALIAS

### generating chain configs, done on host namada-1 only ###
if [ $(hostname) = "namada-1" ]; then

  # wait until all validator configs have been written
  while [ ! -d "/root/.namada-shared/namada-1" ] || [ ! -d "/root/.namada-shared/namada-2" ] || [ ! -d "/root/.namada-shared/namada-3" ]; do 
    echo "Validator configs not ready. Sleeping for 5s..."
    sleep 5
  done

  echo "Validator configs found. Generating chain configs..."

  # modify genesis template and add validator tomls to create genesis toml
  apt install -y python3 # move to build
  apt install -y python3-pip
  pip install toml
  python3 make_genesis.py /root/.namada-shared/ genesis_template.toml >genesis.toml

  # create chain config tar
  namadac utils init-network --genesis-path /genesis.toml --wasm-checksums-path /wasm/checksums.json --chain-prefix knowable --unsafe-dont-encrypt

  export CHAIN_ID=$(basename *.tar.gz .tar.gz)

  # serve config tar over http
  mkdir -p /serve
  cp *.tar.gz /serve
  trap cleanup EXIT
  nohup bash -c "python3 -m http.server --directory /serve 8123 &"

  # write config server info to shared volume
  #echo -e "$PUBLIC_IP\n$CHAIN_ID" | tee /root/.namada-shared/chain.config
  sleep 2
  printf "%b\n%b" "$PUBLIC_IP" "$CHAIN_ID" | tee /root/.namada-shared/chain.config

### end namada-1 specific prep ###

### other nodes should pause here until chain configs are ready ###
else
  while [ ! -f "/root/.namada-shared/chain.config" ]; do
    echo "Configs server info not ready. Sleeping for 5s..."
    sleep 5
  done

  echo "Configs server info found, proceeding with network setup"
fi

### all nodes resume here ###

# get chain config server info
CONFIG_IP=$(awk 'NR==1' /root/.namada-shared/chain.config)
export CHAIN_ID=$(awk 'NR==2' /root/.namada-shared/chain.config)
export NAMADA_NETWORK_CONFIGS_SERVER="http://${CONFIG_IP}:8123"
curl $NAMADA_NETWORK_CONFIGS_SERVER
rm -rf /root/.local/share/namada/$CHAIN_ID
namada client utils join-network \
--chain-id $CHAIN_ID --genesis-validator $ALIAS --dont-prefetch-wasm

# copy wasm to namada dir
cp -a /wasm/*.wasm /root/.local/share/namada/$CHAIN_ID/wasm
cp -a /wasm/checksums.json /root/.local/share/namada/$CHAIN_ID/wasm

# start node
NAMADA_LOG=info CMT_LOG_LEVEL=p2p:none,pex:error NAMADA_CMT_STDOUT=true namada node ledger run

# tail -f /dev/null
