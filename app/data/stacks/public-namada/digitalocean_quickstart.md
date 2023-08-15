# Quick guide - Digital Ocean fullnode
This guide will give an example of how to deploy a Namada fullnode on the latest public testnet.

#### 1. Create a new droplet on Digital Ocean.
(Recommended specs: 16GB of RAM and 320GB storage)

#### 2. Install Stack Orchestrator and requirements.
On Digital Ocean, you might see some purple popup dialogs whenever you update your packages (including in this script); you can just press enter to select the default options.
```
git clone https://github.com/vknowable/stack-orchestrator.git
cd stack-orchestrator
scripts/namada-quick-install.sh
```

#### 3. Logout of your droplet, and then back in again to finish the setup

#### 4. Build Namada containers
If you've chosen the droplet recommended above, this should take around 30-40 minutes. If you went with a slower droplet, it could take up to 2 hours. You'll know it's finished when you're returned to the command prompt.
```
laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=v0.20.1"
```
#### 5. Create a data directory for your node
```
mkdir -p ~/.local/share/namada
```
#### 6. Start your node
```
laconic-so --stack public-namada deploy up
```
---
#### 7. Access your node
Get your node's container id
```
docker ps -q
```
and then
```
docker exec -it <container id> /bin/bash
```
---
#### 8. Shut down your node
```
laconic-so --stack public-namada deploy down --delete-volumes
```
and optionally delete all chain data
```
rm -rf ~/.local/namada
```
