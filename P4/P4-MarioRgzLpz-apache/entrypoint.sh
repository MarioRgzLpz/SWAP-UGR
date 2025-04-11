#!/bin/bash
# Ejecuta el script de iptables
./MarioRgzLpz-iptables-web.sh
# Luego, ejecuta el comando principal del contenedor
exec httpd -D FOREGROUND