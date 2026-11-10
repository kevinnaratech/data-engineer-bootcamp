import requests

def extract_api(url, limit=10):
    all_data = []
    page = 1

    # TODO 1: Looping pagination
    while True: 

        # TODO 2: Params
        params = {
            "_page": page,
            "_limit": limit
        }

        try:
            # TODO 3: Kirim GET request
            response = requests.get(
            url,
            params=params,
            timeout=10
        )

        # TODO 4: Validasi HTTP response
            response.raise_for_status()

        # TODO 5: Ambil JSON response
            data = response.json()

        # TODO 6: Jika data kosong, hentikan loop
            if not data:
                break

        # TODO 7: Gabungkan data ke all_data
            all_data.extend(data)

        # TODO 8: Naikkan nomor halaman
            page += 1

        except requests.RequestException as e:
            print(f"Extraction failed: {e}")
            raise

    return all_data

def main():
    url = "https://jsonplaceholder.typicode.com/posts"

    # TODO 9: Panggil extract_api()
    data = extract_api(url, limit=10)

    # TODO 10: Tampilkan total records
    print(f"Total record  : {len(data)}")

    # TODO 11: Tampilkan first dan last record
    if data:
        print(f"First record  : {data[0]}")
        print(f"Last record   : {data[-1]}")
    else:
        print("No data extracted.")

if __name__ == "__main__":
    main()
    