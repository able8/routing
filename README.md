# routing deployment

### install

```
./routing-control install
```

* config interfaces `enp2s0`, `enp3s0`, `br0`
* add `bay_routing.sevice` 
* enable and start `bay_routing.sevice`

### uninstall

```
./routing-control uninstall
```

* restore interfaces config
* remove service config file
* disbale and stop `bay_routing.sevice`

### start routing

```
./routing-control start
```

* enable and start `bay_routing.sevice`

### stop routing
```
./routing-control stop
```

* disbale and stop `bay_routing.sevice`

### status
```
./routing-control status
```

* display interfaces information
* display iptables rules
* display `bay_routing.service` status
