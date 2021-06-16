## Docker deployment
### Pull latest image
```shell script
$ docker pull runonflux/kadena-chainweb-data
```
### Deploy container in background and bind web port to host
```shell script
$ docker run -d -p 8888:8888 -v /local/path:/var/lib/postgresql/data runonflux/kadena-chainweb-data
```
### Chainweb-data complex solution
- server 
- backfill 
- gaps ( one per day after backfill ) 

```shell script
Info: service-port=30005 --p2p-port=30004
```

**** endpoints

- ~/txs/recent~ gets a list of recent transactions
- ~/txs/search?search=foo&limit=20&offset=40~ searches for transactions containing the string ~foo~
- ~/stats~ returns a few stats such as transaction count and coins in circulation
- ~/coins~ returns just the coins in circulation
