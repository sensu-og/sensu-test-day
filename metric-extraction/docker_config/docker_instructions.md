# Docker Images for Migration Extraction Example
These images provide most of what you need to work through the `collect_metrics` test plan example. Once you have the docker containers running, you will need to use sensuctl to create the check and handler definitions as per the [Test Plan](https://github.com/sensu/sensu-test-day/blob/master/metric-extraction/metric-extraction-test-plan.md).

Assuming you are running docker on localhost, the pre-configured grafana dashboard will be available at http://localhost:3001


You'll also need the [sensuctl program](https://docs.sensu.io/sensu-core/2.0/getting-started/configuring-sensuctl/) running on localhost. 

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

### Start Influxdb

```
docker run -v /var/lib/influxdb:/var/lib/influxdb --name=influxdb -d -p 8086:8086 sensuapp/feature-test-day:20180529-influxdb
```

### Start Grafana
The 2018-05-29-grafana image is pre-configured with an influxdb datastore definition matching the above docker commands. The influxdb docker container needs to be started first

```
docker run   -d   -p 3001:3000   --name=grafana  --link influxdb -e "GF_SECURITY_ADMIN_PASSWORD=TestDay!"   sensuapp/feature-test-day:20180529-grafana
```


### Start Sensu Backend
20180529-sensu docker image pre-loaded with influxdb handler command as used in example metrics handler in test plan. The influxdb docker container needs to be started first
```
docker run -v /var/lib/sensu:/var/lib/sensu -d --link influxdb --name sensu-backend -p 2380:2380 \
-p 3000:3000 -p 8080:8080 -p 8081:8081  sensuapp/feature-test-day:20180529-sensu sensu-backend start
```

### Start Sensu Agent
20180529-sensu docker image pre-loaded wih the metrics-graphite.sh command for use in the example metric check in the test plan. The sensu-backend docker container needs to be started first

```
docker run -v /var/lib/sensu:/var/lib/sensu -d --link sensu-backend --name sensu-agent \
sensuapp/feature-test-day:20180529-sensu sensu-agent start --backend-url ws://sensu-backend:8081 --subscriptions metrics,system --cache-dir /var/lib/sensu
```
## Sensuctl Commands
Once the containers are running, you'll need to use sensuctl on localhost to create sensu resource definitions.

### Sensuctl Configure
configure sensuctl with default sensu-backend admin user and password
Set user to `admin`  password `P@ssw0rd!`
```
sensuctl configure
```
### Reset Admin Password
change the admin password.
```
sensuctl user change-password admin --interactive
```

### Create Check
```
sensuctl check create collect-metrics --command metrics-graphite.sh --interval 1 --subscriptions metrics --output-metric-format graphite_plaintext
```

### Create Handler
```
sensuctl handler create sensu-influxdb-handler --command "sensu-influxdb-handler --addr http://influxdb:8086 --username telegraf --password TestDay --db-name testdaydb0" --type pipe
```

### Update Check
```
sensuctl check set-output-metric-handlers collect-metrics sensu-influxdb-handler
```

## Resources

### Output Metric Format Check Subscriptions
| Check | collect-graphite | collect-influx | collect-nagios | collect-opentsdb |
| ----- | ---------------- | -------------- | -------------- | ---------------- |
| Subscription | `graphite` | `influx` | `nagios` | `opentsdb` |
| Command | [metrics-graphite.sh][1] | [metrics-influx.sh][2] | [metrics-nagios.sh][3] | [metrics-opentsdb.sh][4] |
| Output Metric Format | `graphite_plaintext` | `influxdb_line` | `nagios_perfdata` | `opentsdb_line` |

These metric check commands are pre-loaded into the 20180529-sensu docker image. They may need adjustment to work correctly in other operating system environments.

### [resources.json][6]
Use with `sensuctl create` to setup the collection of output metric format check subscriptions listed above. `resources.json` in this directory is pre-configured with influxdb authorization matching the db init command above.
```
sensuctl create -f resources.json
```
you can now cycle through the subscriptions by removing the existing sensu-agent container and re-running it using a different subscription.

### [grafana-config.json][5]
grafana dashboard pre-loaded into grafana docker image

[1]: metrics-graphite.sh
[2]: metrics-influx.sh
[3]: metrics-nagios.sh
[4]: metrics-opentsdb.sh
[5]: grafana-config.json
[6]: resources.json

