# Quick guide - Digital Ocean fullnode
This guide will give an example of how to deploy a Namada fullnode either on either the Heliax founding team testnet or Luminara's community-run testnet. In total it takes about an hour, depending on your server specs.

## 1. Create a new droplet (aka instance) on [DigitalOcean](https://cloud.digitalocean.com).
After you have a DigitalOcean account, create a droplet. We recommend a droplet with 16GB of RAM and 320GB SSD storage (install takes ~40 minutes), but you can use a less expensive droplet with 8GB RAM / 160GB SSD storage (install takes ~2 hours).

**Tip:** If you're just testing briefly, select a more powerful machine and the process will be much quicker. If you intend to keep the droplet for a month or more, use the minimum spec machine to save costs.

a) Use a password instead of SSH key (warning: for testing only; not a secure way to operate in production).

b) Get the IP address for your droplet.

c) Remotely connect to your droplet with Terminal (MacOS) or Command Prompt (Windows).

Use this command: `ssh root@[ip address]`

Then enter 'yes' and input your password when asked.

## 2. Install Stack Orchestrator and requirements.
On Digital Ocean, you might see some purple pop-up dialogs whenever you update your packages (including in this script); you can just press enter to select the default options.

Click the copy button (it's the icon with two overlapping squares on the right): 
```
git clone https://github.com/vknowable/stack-orchestrator.git
cd stack-orchestrator
scripts/namada-quick-install.sh
```
You can paste and then execute this entire thing.

## 3. Logout of your droplet, and then back in again to finish the setup
Type `exit` and press enter to log out. Use command `ssh root@[ip address]` to log back in.

## 4. Build Namada containers
If you've chosen the droplet recommended above, this should take around 30-40 minutes. If you went with a slower droplet, it could take up to 2 hours. You'll know it's finished when you're returned to the command prompt.

**Wait!** You'll need to decide which Namada testnet you want to connect to.

### Heliax (founding team's) public testnet

Edit this command to be the current Namada testnet version [which can be found here](https://namada.net/testnets):
```
laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=v0.21.1"
```

### Luminara (community-run) "Campfire" testnet
to-do: [link to Luminara latest testnet version]
```
laconic-so --stack public-namada build-containers --extra-build-args "--build-arg NAMADA_TAG=v0.21.1 --build-arg BUILD_WASM=true"
```

FYI, all of the release versions can be [found here](https://github.com/anoma/namada/releases).

## 5. Create a data directory for your node
```
mkdir -p ~/.local/share/namada
```
## 6. Start your node

## Heliax
```
laconic-so --stack public-namada deploy up
```

## Luminara
Create a text file with the information your node needs to find our testnet:
```
nano ~/luminara.env
```

Paste this inside, then ctrl+s, ctrl+x
```
CHAIN_ID=luminara.bbc5fe23fbe06bd6bec13
EXTIP=146.190.54.84
CONFIGS_SERVER=http://72.12.130.222:8081
PERSISTENT_PEERS="tcp://a329e1eeb21d09a5a7c1575d96fa2240e1f70b70@72.12.130.222:26656"
```

Start your node
```
laconic-so --stack public-namada deploy --env-file luminara.env up
```
---
## 7. Access your node
Get your node's container id
```
docker ps -q
```
and then
```
docker exec -it <container id> /bin/bash
```

## 8. See node status, make queries (read the chain) and make transactions (write to the chain)
Wait a minute and then check the status of your node:
```
curl localhost:26657/status | jq .
```
You should see catching `"catching_up": true` while your node syncs, and when it has synced, catching up will be `false`. Then you can perform queries and make transactions.

You can always leave the container with the `exit` command.

to-do: [link to cheat sheet and/or quests]

---
## Shut down and delete your node
```
laconic-so --stack public-namada deploy down --delete-volumes
```
and optionally delete all chain data
```
rm -rf ~/.local/namada
```
