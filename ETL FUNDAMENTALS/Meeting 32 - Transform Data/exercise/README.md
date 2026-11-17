# Meeting 32 — Data Transformation with Pandas

## Overview

This project demonstrates the basic data transformation process in Python using Pandas.

The data is extracted from the JSONPlaceholder API and converted into a Pandas DataFrame. Several data quality checks and transformation steps are then performed to prepare the data for further processing.

## Tech Stack

- Python
- Pandas
- Requests
- JSONPlaceholder API

## Data Source

This project uses the JSONPlaceholder Users API:

`https://jsonplaceholder.typicode.com/users`

The API provides sample user data in JSON format, including user information, addresses, and company details.

## Project Structure

```text
Meeting 32 - Transform Data/
│
└── exercise/
    ├── extract.py
    ├── transform.py
    ├── main.py
    └── README.md
```

## Transformation Workflow

```text
JSONPlaceholder API
        |
        v
     Extract
        |
        v
  Create DataFrame
        |
        v
 Check Missing Values
        |
        v
 Check Duplicates
        |
        v
 Remove Duplicates
        |
        v
  Validate Schema
        |
        v
 Validate Data Types
        |
        v
  Select Required Columns
        |
        v
 Transformed DataFrame
```

## Features

### 1. Data Extraction

- Retrieve user data from the JSONPlaceholder API.
- Send HTTP GET requests using the Requests library.

### 2. DataFrame Creation

- Convert extracted JSON data into a Pandas DataFrame.
- Inspect the first rows, shape, columns, and data types.

### 3. Missing Value Check

- Identify missing values in each column.
- Count missing values using Pandas.

### 4. Duplicate Check

- Identify duplicate records based on the `id` column.
- Use `id` as the business key for uniqueness checking in this dataset.

### 5. Remove Duplicates

- Remove duplicate records based on `id`.
- Compare the number of rows before and after deduplication.

### 6. Schema Validation

- Verify that required columns exist.
- Raise an error if required columns are missing.

### 7. Data Type Validation

- Validate the expected data types of important columns.
- Raise an error when a column does not meet the expected type check.

### 8. Column Selection

Select only the required columns:

- `id`
- `name`
- `username`
- `email`
- `phone`

## Learning Objectives

Through this exercise, I practiced:

- Working with JSON API responses.
- Converting JSON data into Pandas DataFrames.
- Performing basic data quality checks.
- Identifying and removing duplicate records.
- Validating data schema and data types.
- Selecting relevant columns for downstream processing.
- Organizing Python code into separate modules.

## Key Takeaways

Data transformation is an important part of an ETL pipeline. Before loading data into a database, data engineers need to inspect, validate, and prepare the extracted data to ensure it meets the expected requirements.

This exercise focuses on the fundamental transformation and validation steps using Pandas.
