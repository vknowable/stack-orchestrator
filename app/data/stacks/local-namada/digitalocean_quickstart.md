# Quick guide - Digital Ocean local testnet
This guide will give an example of how to deploy a local Namada testnet on Digital Ocean using Stack Orchestrator.

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
