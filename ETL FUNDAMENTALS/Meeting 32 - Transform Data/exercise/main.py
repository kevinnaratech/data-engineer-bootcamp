from extract import extract_data
from transform import create_dataframe, check_missing_values, check_duplicates, remove_duplicates, validate_schema    
from transform import validate_data_types, select_columns

url = "https://jsonplaceholder.typicode.com/users"

raw_data = extract_data(url)

df = create_dataframe(raw_data)

print(df.dtypes)
print(df["name"].dtype)
print(type(df["name"].iloc[0]))

check_missing_values(df)
check_duplicates(df)

df = remove_duplicates(df)

validate_schema(df)
validate_data_types(df)

df = select_columns(df)