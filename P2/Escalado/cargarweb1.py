import requests

def realizar_solicitudes():
    url = "http://192.168.10.2"
    for i in range(100):
        response = requests.get(url)
        if response.status_code != 200:
            print(f"Solicitud {i+1}: Error al realizar la solicitud. Código de estado: {response.status_code}")


# Llamar a la función para realizar las solicitudes
realizar_solicitudes()