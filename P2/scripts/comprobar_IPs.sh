#!/bin/bash

# Nombre de la red de los contenedores web
RED_WEB="red_web"

# Nombre de la red de los servicios
RED_SERVICIOS="red_servicios"

# Función para obtener el ID completo de una red dado un fragmento de su nombre
obtener_id_red() {
    local fragmento_nombre=$1
    local network_name=$(docker network ls --filter name=${fragmento_nombre} --format "{{.Name}}")
    network_id=$(docker network inspect $network_name --format "{{.Id}}")
    echo "$network_id"
}

# Obtener el ID completo de la red web
NETWORK_ID_WEB=$(obtener_id_red "$RED_WEB")

# Obtener el ID completo de la red de servicios
NETWORK_ID_SERVICIOS=$(obtener_id_red "$RED_SERVICIOS")

# Función para obtener la IP de un contenedor en la red especificada por su ID
obtener_ip() {
    docker inspect -f '{{range .NetworkSettings.Networks}}{{if eq .NetworkID "'$1'"}}{{.IPAddress}}{{end}}{{end}}' "$2"
}

echo "Direcciones IP de los contenedores:"
echo "-----------------------------------"

# Iterar sobre los contenedores web
for i in {1..8}; do
    CONTAINER_NAME="web$i"
    IP_WEB=$(obtener_ip "$NETWORK_ID_WEB" "$CONTAINER_NAME")
    echo "Contenedor $CONTAINER_NAME - IP de la red web: $IP_WEB"
done

# Iterar sobre los contenedores de servicios
for i in {1..8}; do
    CONTAINER_NAME="web$i"
    IP_SERVICIOS=$(obtener_ip "$NETWORK_ID_SERVICIOS" "$CONTAINER_NAME")
    echo "Contenedor $CONTAINER_NAME - IP de la red de servicios: $IP_SERVICIOS"
done 