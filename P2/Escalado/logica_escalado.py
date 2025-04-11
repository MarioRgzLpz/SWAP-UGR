import json
import os
import subprocess

def leer_datos_contenedores(nombre_archivo):
    with open(nombre_archivo, "r") as archivo:
        return json.load(archivo)

def calcular_medias(contenedores):
    memoria_total = sum(contenedor["memoria"] for contenedor in contenedores)
    cpu_total = sum(contenedor["uso_cpu_total"] for contenedor in contenedores)
    num_contenedores = len(contenedores)
    memoria_media = memoria_total / num_contenedores
    cpu_media = cpu_total / num_contenedores
    return memoria_media, cpu_media

def modificar_configuracion_nginx(num_contenedor):
    # Leer configuración actual
    with open("nginx.conf", "r") as archivo:
        lineas = archivo.readlines()

    # Agregar nueva IP al upstream
    # Encontrar la última línea con el patrón 'server 192.168.10.X'
    ultima_linea_index = -1
    for i, linea in enumerate(reversed(lineas)):
        if "server 192.168.10." in linea:
            ultima_linea_index = len(lineas) - 1 - i
            break

    # Añadir la nueva IP justo después de la última línea encontrada
    nueva_linea = f"        server 192.168.10.{num_contenedor} weight=1;\n"
    lineas.insert(ultima_linea_index + 1, nueva_linea)

    # Escribir nueva configuración
    with open("nginx.conf", "w") as archivo:
        archivo.writelines(lineas)

def eliminar_configuracion_nginx():
    # Leer configuración actual
    with open("nginx.conf", "r") as archivo:
        lineas = archivo.readlines()

    # Encontrar la última línea con el patrón 'server 192.168.10.X'
    ultima_linea_index = -1
    for i, linea in enumerate(reversed(lineas)):
        if "server 192.168.10." in linea:
            ultima_linea_index = len(lineas) - 1 - i
            break

    # Eliminar la última línea encontrada
    if ultima_linea_index != -1:
        del lineas[ultima_linea_index]

        # Escribir nueva configuración
        with open("nginx.conf", "w") as archivo:
            archivo.writelines(lineas)
    else:
        print("No se encontró ninguna línea con la IP 192.168.10.")

def recargar_contenedor_nginx():
    # Recargar el contenedor Nginx utilizando Docker Compose
    subprocess.run(["docker", "compose", "restart", "balanceador-nginx"])

def lanzar_siguiente_contenedor(num_contenedor):
    if(num_contenedor <= 8):
        # Lanzar el siguiente contenedor utilizando Docker Compose
        nombre = f"web{num_contenedor + 1}"
        subprocess.run(["docker" , "compose", "up", "-d", nombre])
    else: 
        print("Ampliando el número de contenedores en la red de balanceo")
        subprocess.run(["bash" , "crear_docker-compose.sh", num_contenedor + 1])
        subprocess.run(["docker" , "compose", "up", "-d", nombre])


def parar_contenedor(num_contenedor):
    if(num_contenedor > 3 ):
        # Lanzar el siguiente contenedor utilizando Docker Compose
        nombre = f"web{num_contenedor}"
        subprocess.run(["docker" , "compose", "stop" , nombre])
    else: 
        print("Ya no se pueden parar más contenedores, minimo 3 contenedores activos")

# Leer datos de los contenedores desde el archivo JSON
contenedores = leer_datos_contenedores("./data/datos.json")

# Calcular medias de memoria y uso de CPU
memoria_media, cpu_media = calcular_medias(contenedores)

# Verificar si algún contenedor supera los umbrales
num_contenedores = len(contenedores)
print(f"Verificando {num_contenedores} contenedores...")
for contenedor in contenedores:
    print(f"Contenedor {contenedor['nombre_contenedor']}:")
    print(f"  - Memoria: {contenedor['memoria']}")
    print(f"  - Uso de CPU total: {contenedor['uso_cpu_total']}")
    print("Umbral de memoria por arriba:", memoria_media*1.02)
    print("Umbral de CPU por arriba:", cpu_media*1.02)
    print("Umbral de memoria por debajo:",memoria_media*0.99)
    print("Umbral de CPU por debajo:", cpu_media*0.99)
    if contenedor["memoria"] > memoria_media*1.02 or contenedor["uso_cpu_total"] > cpu_media*1.02:
        print(f"El contenedor {contenedor['nombre_contenedor']} supera el umbral de memoria o uso de CPU. Añadiendo un nuevo contenedor.")
        # Modificar la configuración de Nginx y recargar
        lanzar_siguiente_contenedor(num_contenedores)
        modificar_configuracion_nginx(num_contenedores + 1)
        recargar_contenedor_nginx()
        # Lanzar el siguiente contenedor
        
        break  # Solo modificamos/recargamos para el primer contenedor que supera el umbral
    elif contenedor["memoria"] < memoria_media*0.99 or contenedor["uso_cpu_total"] < cpu_media*0.99:
        print(f"El contenedor {contenedor['nombre_contenedor']} no supera el umbral de memoria o uso de CPU. Parando el ultimo contenedor.")
        # Detener el contenedor
        parar_contenedor(num_contenedores)
        if(num_contenedores > 3):
            eliminar_configuracion_nginx()
            recargar_contenedor_nginx()
        break  # Solo detenemos el primer contenedor que no supera el umbral
