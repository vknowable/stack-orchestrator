#!/bin/bash

# generate jwt token for reth/lighthouse authentication
echo "Installing OpenSSL..."
apt update
apt install openssl
echo "Generating jwt token for lighthouse auth..."
openssl rand -hex 32 | tr -d "\n" | tee /root/.shared_data/jwt.hex

# # start nethermind
# echo "Starting Nethermind..."
# export RUST_LOG=info
# reth node \
#   --authrpc.jwtsecret /root/.shared_data/jwt.hex \
#   --authrpc.addr 0.0.0.0 \
#   --authrpc.port 8551 \
#   --http \
#   --http.addr 0.0.0.0 \
#   --http.corsdomain * \
#   --http.api eth,web3,net,rpc \
#   --ws \
#   --ws.addr 0.0.0.0 \
#   --ws.origins * \
#   --ws.api eth,web3,net,rpc


./Nethermind.Runner \
    --config gnosis \
    --JsonRpc.Enabled true \
    --HealthChecks.Enabled true \
    --JsonRpc.EngineHost 0.0.0.0 \
    --JsonRpc.EnginePort=8551 \
    --JsonRpc.JwtSecretFile=/root/.shared_data/jwt.hex

# tail -f /dev/null
