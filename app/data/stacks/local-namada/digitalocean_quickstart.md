# Quick guide - Digital Ocean local testnet
This guide will give an example of how to deploy a local Namada testnet on Digital Ocean using Stack Orchestrator.

#### 1. Create a new droplet on Digital Ocean.
(Recommended specs: 16GB of RAM and 320GB storage)

#### 2. Install stack-orchestrator and requirements. You can choose 'ok' for any popups you see during installation
```
git clone https://github.com/vknowable/stack-orchestrator.git
cd stack-orchestrator
apt install python3-pip python3.10-venv -y
scripts/quick-install-ubuntu.sh
scripts/developer-mode-setup.sh
source ~/.profile
```
#### 3. Checkout local-namada branch
Make sure you're on the `local-namada` branch if not already
```
git checkout local-namada
```

#### 4. Build Namada containers, including wasm (this can take up to 30 minutes depending on your machine specs)
Set `NAMADA_TAG` to the version of Namada you wish to deploy on your testnet.
```
laconic-so --stack local-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=v0.20.1 --build-arg BUILD_WASM=true"
```
#### 5. Start the testnet
```
laconic-so --stack local-namada deploy up
```
---
#### 6. Access a node
Get a node's container id
```
docker ps
```
and then
```
docker exec -it <container id> /bin/bash
```
---
#### 7. Shut down testnet
```
laconic-so --stack local-namada deploy down --delete-volumes
```
