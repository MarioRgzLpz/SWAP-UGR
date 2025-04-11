#!/bin/bash

# Definir las direcciones IP de los contenedores
contenedor1_ip_1="192.168.10.2"
contenedor1_ip_2="192.168.20.2"
contenedor2_ip_1="192.168.10.3"
contenedor2_ip_2="192.168.20.3"

# Realizar ping desde el contenedor 1 al contenedor 2
echo "Ping desde el contenedor 1 al contenedor 2 (IP 1):"
docker exec web1 ping -c 2 $contenedor2_ip_1
echo "Ping desde el contenedor 1 al contenedor 2 (IP 2):"
docker exec web1 ping -c 2 $contenedor2_ip_2

# Realizar ping desde el contenedor 2 al contenedor 1
echo "Ping desde el contenedor 2 al contenedor 1 (IP 1):"
docker exec web2 ping -c 2 $contenedor1_ip_1
echo "Ping desde el contenedor 2 al contenedor 1 (IP 2):"
docker exec web2 ping -c 2 $contenedor1_ip_2