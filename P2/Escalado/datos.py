import json
import requests

def obtener_datos_contenedores():
    # Hacer solicitud HTTP a cAdvisor
    url = "http://localhost:8080/api/v1.2/docker"
    response = requests.get(url)
    
    # Verificar si la solicitud fue exitosa
    if response.status_code == 200:
        data = response.json()
        contenedores_webX = []

        # Filtrar contenedores webX y obtener memoria y uso total de CPU
        for contenedor_id, datos_contenedor in data.items():
            nombre = datos_contenedor.get("aliases", [""])[0]
            if "web" in nombre:
                uso_cpu_total = datos_contenedor.get("stats", [])[0].get("cpu", {}).get("usage", {}).get("total", 0)
                memoria = datos_contenedor.get("stats", [])[0].get("memory", {}).get("usage", 0)
                
                contenedor = {
                    "nombre_contenedor": nombre,
                    "contenedor_id": datos_contenedor.get("id"),
                    "memoria": memoria,
                    "uso_cpu_total": uso_cpu_total
                }
                contenedores_webX.append(contenedor)
        
        return contenedores_webX
    else:
        print("Error al obtener datos de cAdvisor:", response.status_code)
        return []

# Obtener datos
contenedores_webX = obtener_datos_contenedores()

# Guardar datos en un archivo JSON
nombre_archivo = "./data/datos.json"
with open(nombre_archivo, "w") as archivo:
    json.dump(contenedores_webX, archivo, indent=4)

print("Datos guardados en:", nombre_archivo)