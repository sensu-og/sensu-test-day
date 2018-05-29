# Docker Images for Migration Extraction Example
These images provide most of what you need to work through the `collect_metrics` test plan example. Once you have the docker containers running, you will need to use sensuctl to create the check and handler definitions as per the Test Plan.

## Docker Commands

###  Initialize influxdb
The provided 20180529-influxdb docker image relies on persistent storage bind mount in which to hold the initialized database.
Here is a docker run command which will initilize the persistent database using `/var/lib/influxdb`
```
docker run --rm \
      -e INFLUXDB_DB=testdaydb0 -e INFLUXDB_ADMIN_ENABLED=true \
      -e INFLUXDB_ADMIN_USER=admin -e INFLUXDB_ADMIN_PASSWORD=AdminTestDay \
      -e INFLUXDB_USER=telegraf -e INFLUXDB_USER_PASSWORD=TestDay \
      -v /var/lib/influxdb:/var/lib/influxdb \
      sensuapp/feature-test-day:20180529-influxdb  /init-influxdb.sh
```

### Start the influxdb

```
docker run -v /var/lib/influxdb:/var/lib/influxdb --name=influxdb -d -p 8086:8086 sensuapp/feature-test-day:20180529-influxdb
```

### Start grafana
The 2018-05-29-grafana image is pre-configured with an influxdb datastore definition matching the above docker commands. The influxdb docker container needs to be started first

```
docker run   -d   -p 3001:3000   --name=grafana  --link influxdb -e "GF_SECURITY_ADMIN_PASSWORD=TestDay!"   sensuapp/feature-test-day:20180529-grafana
```


### start sensu backend
20180529-sensu docker image pre-loaded with influxdb handler command as used in example metrics handler in test plan. The influxdb docker container needs to be started first
```
docker run -v /var/lib/sensu:/var/lib/sensu -d --link influxdb --name sensu-backend -p 2380:2380 \
-p 3000:3000 -p 8080:8080 -p 8081:8081  sensuapp/feature-test-day:20180529-sensu sensu-backend start
```

### Start sensu-agent
20180529-sensu docker image pre-loaded wih metrics-graphite.sh command for use in example metric check in test plan. The sensu-backend docker container needs to be started first

```
sudo docker run -v /var/lib/sensu:/var/lib/sensu -d --link sensu-backend --name sensu-agent \
sensuapp/feature-test-day:20180529-sensu sensu-agent start --backend-url ws://sensu-backend:8081 --subscriptions metrics,system --cache-dir /var/lib/sensu
```

