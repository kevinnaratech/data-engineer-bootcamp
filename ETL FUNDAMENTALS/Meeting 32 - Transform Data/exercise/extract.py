import requests

def extract_data(url):
    response = requests.get(url, timeout=10)
    response.raise_for_status()

    return response.json()