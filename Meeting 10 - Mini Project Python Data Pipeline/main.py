import requests
import pandas as pd

def main():
    # Extract
    try:
        response = requests.get("https://jsonplaceholder.typicode.com/users")
        response.raise_for_status()
        data = response.json()
    except requests.RequestException as e:
        print(f"Request failed: {e}")
        return

    # Transform
    df = pd.DataFrame(data)
    df["city"] = df["address"].apply(lambda x: x["city"])

    # Clean
    clean_df = df [["name","email","city"]]
    print(clean_df.head())

    # Load
    clean_df.to_csv("clean_user.csv", index=False)
    print("Data successfully processed.!")

if __name__ == "__main__":
    main()