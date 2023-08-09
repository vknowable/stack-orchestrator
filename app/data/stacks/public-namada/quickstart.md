# Quick node setup guide

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
#### 3. Build Namada containers (this can take up to 30 minutes depending on your machine specs)
```
laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=v0.20.1"
```
#### 4. Create a data directory for your node
```
mkdir ~/.local/share/namada
```
#### 5. Start your node
```
laconic-so --stack public-namada deploy up
```
---
#### 6. Access your node
Get your node's container id
```
docker ps -q
```
and then
```
docker exec -it <container id> /bin/bash
```
---
#### 7. Shut down your node
```
laconic-so --stack public-namada deploy down --delete-volumes
```
and optionally delete all chain data
```
rm -rf ~/.local/namada
```