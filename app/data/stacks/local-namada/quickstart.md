# Quick local testnet setup guide

#### 1. Create a new droplet on Digital Ocean.
(Recommended specs: 16GB of RAM and 320GB storage)
#### 2. Install stack-orchestrator and requirements. You can choose 'ok' for any popups you see during installation
```
git clone https://github.com/vknowable/stack-orchestrator.git
cd stack-orchestrator/ && git checkout namada
apt install python3-pip python3.10-venv -y
scripts/quick-install-ubuntu.sh
scripts/developer-mode-setup.sh
```
#### 3. Build Namada containers, including wasm (this can take up to 30 minutes depending on your machine specs)
```
laconic-so --stack local-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=v0.20.1 --build-arg BUILD_WASM=true"
```
#### 4. Start the testnet
```
laconic-so --stack local-namada deploy up
```
---
#### 5. Access a node
Get a node's container id
```
docker ps
```
and then
```
docker exec -it <container id> /bin/bash
```
---
#### 6. Shut down testnet
```
laconic-so --stack local-namada deploy down --delete-volumes
```