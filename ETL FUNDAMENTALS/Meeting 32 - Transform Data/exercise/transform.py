import pandas as pd

def create_dataframe(data):
    df = pd.DataFrame(data)

    print(df.head(5))
    print(df.shape)
    print(df.columns)
    print(df.dtypes)

    return df

def check_missing_values(df):
    missing_data =  df.isnull().sum()

    print(missing_data)

    return missing_data

def check_duplicates(df):
    duplicate_data = df.duplicated(subset=["id"]).sum()

    print(duplicate_data)

    return duplicate_data

def remove_duplicates(df):
    shape_before = df.shape[0]

    remove_duplicate = df.drop_duplicates(subset=["id"])

    shape_after = remove_duplicate.shape[0]

    removed_rows = shape_before - shape_after

    print(f"Before: {shape_before}")
    print(f"After: {shape_after}")
    print(f"Removed: {removed_rows}")

    return remove_duplicate

def validate_schema(df):
    required_columns = ["id", "name", "username", "email"]

    missing_columns = set(required_columns) - set(df.columns)

    print(missing_columns)

    if missing_columns:
        raise ValueError(f"Missing required columns: {missing_columns}")

    return True

def validate_data_types(df):
    expected_types = {
        "id": pd.api.types.is_integer_dtype,
        "name": pd.api.types.is_string_dtype,
        "username": pd.api.types.is_string_dtype,
        "email": pd.api.types.is_string_dtype,
    }

    for column, check_func in expected_types.items():
        if not check_func(df[column]):
            raise ValueError(
                f"Tipe data kolom '{column}' tidak sesuai: "
                f"didapatkan '{df[column].dtype}'."
            )
    print("Validasi tipe data berhasil")
    return True

def select_columns(df):
    required_columns = [
        "id",
        "name",
        "username",
        "email",
        "phone"
    ]

     
    selected_df = df[required_columns]
    
    print(selected_df)
    
    return selected_df