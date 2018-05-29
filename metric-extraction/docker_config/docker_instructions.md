
#  Initialize influxdb
```
sudo docker run --rm \
      -e INFLUXDB_DB=testdaydb0 -e INFLUXDB_ADMIN_ENABLED=true \
      -e INFLUXDB_ADMIN_USER=admin -e INFLUXDB_ADMIN_PASSWORD=AdminTestDay \
      -e INFLUXDB_USER=telegraf -e INFLUXDB_USER_PASSWORD=TestDay \
      -v /var/lib/influxdb:/var/lib/influxdb \
      sensuapp/feature-test-day:20180529-influxdb  /init-influxdb.sh
```

# Start the influxdb

```
sudo docker run -v /var/lib/influxdb:/var/lib/influxdb --name=influxdb -d -p 8086:8086 sensuapp/feature-test-day:20180529-influxdb
```

# Start grafana
```
sudo docker run   -d   -p 3001:3000   --name=grafana  --link influxdb -e "GF_SECURITY_ADMIN_PASSWORD=TestDay!"   sensuapp/feature-test-day:20180529-grafana
```


# start sensu backend

```
sudo docker run -v /var/lib/sensu:/var/lib/sensu -d --link influxdb --name sensu-backend -p 2380:2380 \
-p 3000:3000 -p 8080:8080 -p 8081:8081  sensuapp/feature-test-day:20180529-sensu sensu-backend start
```

# Start sensu-agent
```
sudo docker run -v /var/lib/sensu:/var/lib/sensu -d --link sensu-backend --name sensu-agent \
sensuapp/feature-test-day:20180529-sensu sensu-agent start --backend-url ws://sensu-backend:8081 --subscriptions metrics,system --cache-dir /var/lib/sensu
```
