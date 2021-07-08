## Kadena chainweb-data for kadena node
### Pull latest image
```shell script
$ docker pull runonflux/kadena-chainweb-data
```
### Deploy container
```shell script
$ docker run -d -p 8888:8888 -v --restart=always /local/path:/var/lib/postgresql/data --name "KadenaChainWebData" runonflux/kadena-chainweb-data
```
### Chainweb-data complex solution
- server 
- backfill/bootstrap
- gaps ( one per day after backfill ) 

```shell script
Node info: service-port=30005 --p2p-port=30004
```

### Chainweb-data status
```shell script
docker inspect --format "{{json .State.Health }}" KadenaChainWebData | jq
```

### Endpoints
- /txs/recent gets a list of recent transactions
- /txs/search?search=foo&limit=20&offset=40 searches for transactions containing the string foo
- /stats returns a few stats such as transaction count and coins in circulation
- /coins returns just the coins in circulation
