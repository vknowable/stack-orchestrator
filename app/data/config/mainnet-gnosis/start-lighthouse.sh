#!/bin/bash

# Wait for reth container to create jwt auth token
while [ ! -f /root/.shared_data/jwt.hex ]; do
  echo "Jwt auth token not found, sleeping for 5s..."
  sleep 5
done

echo "Jwt token found. Starting Lighthouse..."
export RUST_LOG=info
lighthouse \
  --network gnosis beacon_node \
  --execution-endpoint http://nethermind:8551 \
  --execution-jwt /root/.shared_data/jwt.hex \
  --checkpoint-sync-url "https://checkpoint.gnosischain.com" \
  --disable-deposit-contract-sync
