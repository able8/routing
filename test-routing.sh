#!/bin/bash

path=$(dirname "$0")
name="$0"

Usage(){
    echo "Usage: $name { install | uninstall }"
    exit 1
}

install(){
    cd $path/routingtest
    sudo python test_routing_install.py -v
}

uninstall(){
    cd $path/routingtest
    sudo python test_routing_uninstall.py -v
}

if [ "$#" -ne 1 ] ; then
    Usage
else
    case "$1" in 
        install)
            install
            ;;

        uninstall)
            uninstall
            ;;

        *)
            Usage
            ;;
    esac
fi


