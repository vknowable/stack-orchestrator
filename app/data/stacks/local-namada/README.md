# Namada (local tesnet)

Deploy a Namada local testnet.

## Clone repositories
```
$ laconic-so --stack local-namada setup-repositories
```

## Build containers
```
$ laconic-so --stack local-namada build-containers
```

## Deploy stack
```
$ laconic-so --stack local-namada deploy up
```

## Check logs
```
$ laconic-so --stack local-namada deploy logs
```

## Shut down
```
$ laconic-so --stack local-namada deploy down --delete-volumes
```
