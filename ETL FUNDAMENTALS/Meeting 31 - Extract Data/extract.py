# TODO 1: Kirim GET request
# TODO 2: Periksa status code
# TODO 3: Ambil response dalam format JSON
# TODO 4: Periksa tipe data hasil response
# TODO 5: Tampilkan 1 data pertama

import requests

url = "https://jsonplaceholder.typicode.com/posts"

def main ():
    try:
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()

    except requests.RequestException as e:
            print(f"Request failed: {e}")
            return

    print(type(data))
    print(data[0])

if __name__ == "__main__":
    main()