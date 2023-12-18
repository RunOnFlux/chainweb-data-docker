## Kadena chainweb-data for kadena node
### Pull latest image
```shell script
$ docker pull runonflux/kadena-chainweb-data
```
### Deploy container
```shell script
$ docker run -d -p 8888:8888 --restart=always -v /local/path:/var/lib/postgresql/data --name "KadenaChainWebData" -e GATEWAYIP=kadena.dapp.runonflux.io -e GATEWAYPORT=31350 -e SERVICEPORT=31351 runonflux/kadena-chainweb-data
```
### Chainweb-data complex solution
- server 
- fill

```shell script
Node info: service-port=31351 --p2p-port=31350
```

### Health check
```shell script
docker inspect --format "{{json .State.Health }}" KadenaChainWebData | jq
```

### Endpoints
- /txs/recent gets a list of recent transactions
- /txs/search?search=foo&limit=20&offset=40 searches for transactions containing the string foo
- /stats returns a few stats such as transaction count and coins in circulation
- /coins returns just the coins in circulation

2.3.0 (2023-08-14)
