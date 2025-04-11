#!/bin/bash

# Ruta absoluta para el archivo de salida
output_file="logcontenedores.txt"

# Obtener una lista de los contenedores que comienzan con "web"
contenedores=$(docker ps --filter "name=web" --format "{{.Names}}")

# Iterar sobre cada contenedor y guardar los logs en el archivo
for contenedor in $contenedores; do
    logs=$(docker logs -t $contenedor)  # Corregir esta línea
    echo "Logs para el contenedor $contenedor:$logs"  # Corregir esta línea
done
