#!/bin/bash

# Verificar si se proporciona un número de contenedores como argumento
if [ $# -ne 1 ]; then
    echo "Uso: $0 <numero_de_contenedores>"
    exit 1
fi

num_contenedores=$1

# Verificar si el número de contenedores es un entero positivo
if ! [[ $num_contenedores =~ ^[1-9][0-9]*$ ]]; then
    echo "El número de contenedores debe ser un entero positivo."
    exit 1
fi

# Generar el contenido del docker-compose.yaml
cat > docker-compose.yaml <<EOF
version: '4'

services:
EOF

# Agregar cada servicio al docker-compose.yaml
for ((i = 1; i <= num_contenedores; i++)); do
    cat >> docker-compose.yaml <<EOF
  web${i}:
    image: mariorgzlpz-apache-image:p1
    volumes:
      - ./web_MarioRgzLpz:/var/www/localhost/htdocs
      - ./configsphp:/etc/php8/conf.d
    container_name: web${i}
    networks:
      red_web:
        ipv4_address: 192.168.10.$((1 + i))
      red_servicios:
        ipv4_address: 192.168.20.$((1 + i))
EOF
done

cat >> docker-compose.yaml <<EOF
networks:
  red_web:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.10.0/24
          gateway: 192.168.10.1
  red_servicios:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 192.168.20.0/24
          gateway: 192.168.20.1
EOF

echo "docker-compose.yaml generado con $num_contenedores contenedores."
