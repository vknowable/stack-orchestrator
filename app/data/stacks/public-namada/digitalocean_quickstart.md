# Quick guide - Digital Ocean fullnode
This guide will give an example of how to deploy a Namada fullnode on the latest public testnet.

#### 1. Create a new droplet (aka instance) on [DigitalOcean](https://cloud.digitalocean.com).
After you have a DigitalOcean account, create a droplet. We recommend at least 16GB of RAM and 320GB storage.

**Tip:** If you're just testing briefly, select a more powerful machine and the process will be much quicker. If you intend to keep the droplet for a month or more, use the minimum spec machine to save costs.

a) Use a password instead of SSH key (warning: for testing only; not a secure way to operate in production).

b) Get the IP address for your droplet.

c) Remotely connect to your droplet with Terminal (MacOS) or Command Prompt (Windows).

Use this command: `ssh root@[ip address]`

Then enter 'yes' and input your password when asked.

#### 2. Install Stack Orchestrator and requirements.
On Digital Ocean, you might see some purple pop-up dialogs whenever you update your packages (including in this script); you can just press enter to select the default options.

Click the copy button (it's the icon with two overlapping squares on the right): 
```
git clone https://github.com/vknowable/stack-orchestrator.git
cd stack-orchestrator
scripts/namada-quick-install.sh
```
You can paste and then execute this entire thing.

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
