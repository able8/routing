# routing


## deployment

### install

```
./routing-control install
```

* config interfaces enp2s0 enp3s0 br0
* add bay_routing.sevice to systemctl
* use ststemctl to enable and start service

### uninstall

```
./routing-control uninstall
```

* restore interfaces config
* remove service file
* use systemctl disbale and stop service

### start routing

```
./routing-control start
```

* use ststemctl to enable and start service
* use this after install

### stop routing
```
./routing-control stop
```

* use systemctl disbale and stop service
* use this after install

### status
```
./routing-control status
```

* show interfaces informations
* show iptables rules
* show bay_routing.service status
