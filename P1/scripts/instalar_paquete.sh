#!/bin/bash

package_name="$1"

if [ -z "$package_name" ]; then
    echo "Usage: $0 <package_name>"
    exit 1
fi

# Obtener una lista de todos los contenedores web
containers=$(docker ps --filter "name=web" --format "{{.Names}}" )

# Iterar sobre cada contenedor y ejecutar el comando de instalación
for container in $containers; do
    echo "Instalando $package_name en el contenedor $container..."
    docker exec "$container" /bin/bash -c "apk update && apk add $package_name"
    if [ $? -eq 0 ]; then
        echo "Instalación exitosa en el contenedor $container."
    else
        echo "No se pudo instalar $package_name en el contenedor $container."
    fi
done