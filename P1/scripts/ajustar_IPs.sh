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

# Función para asignar la IP y conectar el contenedor a la red especificada
asignar_ip_y_conectar() {
    local network_id=$1
    local container_name=$2
    local desired_ip=$3

    # Verificar si el contenedor está conectado a la red
    if [[ $(docker network inspect -f '{{.Containers}}' $network_id | grep -c $container_name) -eq 0 ]]; then
        docker network connect $network_id $container_name
    fi

    # Obtener la IP actual del contenedor
    current_ip=$(obtener_ip "$network_id" "$container_name")

    # Verificar si la IP actual no coincide con la IP deseada
    if [[ "$current_ip" != "$desired_ip" ]]; then
        echo "Ajustando IP para el contenedor $container_name a $desired_ip"
        docker network disconnect $network_id $container_name
        docker network connect --ip $desired_ip $network_id $container_name
    fi
}

echo "Verificando y ajustando direcciones IP de los contenedores:"
echo "----------------------------------------------------------"

# Iterar sobre los contenedores web
for i in {1..8}; do
    CONTAINER_NAME="web$i"
    IP_WEB="192.168.10.$((i+1))"
    asignar_ip_y_conectar "$NETWORK_ID_WEB" "$CONTAINER_NAME" "$IP_WEB"
done

# Iterar sobre los contenedores de servicios
for i in {1..8}; do
    CONTAINER_NAME="web$i"
    IP_SERVICIOS="192.168.20.$((i+1))"
    asignar_ip_y_conectar "$NETWORK_ID_SERVICIOS" "$CONTAINER_NAME" "$IP_SERVICIOS"
done

echo "Proceso completado."