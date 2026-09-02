# Data Engineer Bootcamp — Self-Taught

Notes and projects from a self-directed Data Engineering learning journey, structured around a 6-month syllabus.
- **Total:** 6 Months | 24 Weeks | ±73 Sessions
Every session's exercises are pushed to this repo, so the portfolio builds up along the way — not all dumped at the end.

---

## Progress & Folder Structure

| # | Module | Sessions | Folder | Status |
|---|---|---|---|---|
| 1 | Python Fundamentals | 1–10 | [`PYTHON/`](./PYTHON) | ✅ Done |
| 2 | SQL | 11–18 | [`SQL/`](./SQL) | ✅ Done |
| 3 | Linux & Git | 19–21 | `LINUX-GIT/` | ⏳ Not started |
| 4 | PostgreSQL | 22–25 | `POSTGRESQL/` | ⏳ Not started |
| 5 | Data Modeling | 26–29 | `DATA-MODELING/` | ⏳ Not started |
| 6 | ETL Fundamentals | 30–34 | `ETL/` | ⏳ Not started |
| 7 | Spark & PySpark | 35–40 | `SPARK/` | ⏳ Not started |
| 8 | Data Warehousing | 41–44 | `DATA-WAREHOUSING/` | ⏳ Not started |
| 9 | Docker | 45–47 | `DOCKER/` | ⏳ Not started |
| 10 | Airflow | 48–51 | `AIRFLOW/` | ⏳ Not started |
| 11 | Kafka | 52–55 | `KAFKA/` | ⏳ Not started |
| 12 | AWS | 56–59 | `AWS/` | ⏳ Not started |
| 13 | dbt | 60–62 | `DBT/` | ⏳ Not started |
| 14 | Data Lake | 63–64 | `DATA-LAKE/` | ⏳ Not started |
| 15 | Capstone Project | 65–69 | `CAPSTONE/` | ⏳ Not started |
| 16 | Career Preparation | 70–73 | `CAREER-PREP/` | ⏳ Not started |

> Update this table each time a module starts/finishes, so progress is always visible from the README without opening every folder.

---

## Syllabus Breakdown

### TERM 1 — Foundations (Month 1)

<details>
<summary><b>Module 1: Python Fundamentals</b> (Sessions 1–10)</summary>

| Session | Topic |
|---|---|
| 1 | Introduction & Environment (Python, VS Code, venv, variables, operators) |
| 2 | Basic Data Structures (list, tuple, mutable vs immutable) |
| 3 | Dictionary & Set |
| 4 | Control Flow (if/else, loops, list comprehension) |
| 5 | Functions (parameters, `*args`/`**kwargs`, scope) |
| 6 | OOP in Python (classes, inheritance, overriding) |
| 7 | File & Error Handling (CSV/JSON, try/except) |
| 8 | Pandas Part 1 (DataFrame, filtering, indexing) |
| 9 | Pandas Part 2 (groupby, merge/join, missing values) |
| 10 | Mini Project — **Deliverable: Project 1** (extract API/CSV → clean → export) |

</details>

<details>
<summary><b>Module 2: SQL</b> (Sessions 11–18)</summary>

| Session | Topic |
|---|---|
| 11 | SQL Basics (SELECT, WHERE, ORDER BY, LIMIT) |
| 12 | Aggregates & Grouping (COUNT, SUM, GROUP BY, HAVING) |
| 13 | JOIN Part 1 (INNER, LEFT) |
| 14 | JOIN Part 2 (RIGHT, FULL OUTER, SELF) |
| 15 | Subqueries & CTEs |
| 16 | Window Functions (ROW_NUMBER, RANK, LAG/LEAD) |
| 17 | CASE WHEN & Set Operations (UNION, INTERSECT) |
| 18 | Basic Query Optimization (Index, EXPLAIN) |

</details>

<details>
<summary><b>Module 3: Linux & Git</b> (Sessions 19–21)</summary>

| Session | Topic |
|---|---|
| 19 | Linux Command Line (navigation, permissions, text processing) |
| 20 | Advanced Linux + Git Setup (piping, cron, git init–push) |
| 21 | Advanced Git + Month 1 Review (branching, merge conflicts, .gitignore) |

</details>

### TERM 2 — Data Modeling & ETL (Month 2)

<details>
<summary><b>Module 4: PostgreSQL</b> (Sessions 22–25)</summary>

| Session | Topic |
|---|---|
| 22 | Setup & Data Types (JSONB, ARRAY, UUID) |
| 23 | Constraints & Relationships (PK, FK, UNIQUE, CHECK) |
| 24 | Indexes & Transactions (B-tree, ACID, ROLLBACK) |
| 25 | Views & Stored Procedures |

</details>

<details>
<summary><b>Module 5: Data Modeling</b> (Sessions 26–29)</summary>

| Session | Topic |
|---|---|
| 26 | Normalization (1NF, 2NF, 3NF) |
| 27 | Dimensional Modeling (Star vs Snowflake schema) |
| 28 | Slowly Changing Dimensions (SCD Type 1/2/3) |
| 29 | ERD Practice (dbdiagram.io / draw.io) |

</details>

<details>
<summary><b>Module 6: ETL Fundamentals</b> (Sessions 30–34)</summary>

| Session | Topic |
|---|---|
| 30 | ETL vs ELT Concepts, Batch vs Streaming |
| 31 | Extracting Data (APIs, pagination, rate limits) |
| 32 | Transforming Data (advanced cleaning, data quality checks) |
| 33 | Loading into PostgreSQL (psycopg2/SQLAlchemy, bulk insert) |
| 34 | Logging & Error Handling — **Deliverable: Project 2** (end-to-end ETL) |

</details>

### TERM 3 — Big Data (Month 3)

<details>
<summary><b>Module 7: Spark & PySpark</b> (Sessions 35–40)</summary>

| Session | Topic |
|---|---|
| 35 | Why Spark? (distributed computing, architecture) |
| 36 | Setting Up PySpark (Docker, SparkSession) |
| 37 | DataFrame API Part 1 (read/write, select, filter) |
| 38 | DataFrame API Part 2 (groupBy, join, Spark SQL) |
| 39 | Partitioning & Optimization (broadcast vs shuffle join) |
| 40 | UDFs & Advanced Practice |

</details>

<details>
<summary><b>Module 8: Data Warehousing</b> (Sessions 41–44)</summary>

| Session | Topic |
|---|---|
| 41 | OLTP vs OLAP |
| 42 | Columnar Format — Parquet (columnar vs row-based) |
| 43 | Popular Data Warehouses (Redshift, BigQuery, Snowflake) |
| 44 | Big Data Project — **Deliverable: Project 3** (PySpark → Parquet → warehouse) |

</details>

### TERM 4 — Orchestration & Streaming (Month 4)

<details>
<summary><b>Module 9: Docker</b> (Sessions 45–47)</summary>

| Session | Topic |
|---|---|
| 45 | Docker Basics (container vs VM, images, basic commands) |
| 46 | Dockerfile (build & run custom images) |
| 47 | Docker Compose (multi-container, volumes, networking) |

</details>

<details>
<summary><b>Module 10: Airflow</b> (Sessions 48–51)</summary>

| Session | Topic |
|---|---|
| 48 | Airflow Concepts (DAGs, setup via Docker Compose) |
| 49 | Operators & Tasks (PythonOperator, BashOperator, dependencies) |
| 50 | Scheduling & XCom |
| 51 | Sensors, Hooks, Connections — **Deliverable: Project 4** (ETL → Airflow DAG) |

</details>

<details>
<summary><b>Module 11: Kafka</b> (Sessions 52–55)</summary>

| Session | Topic |
|---|---|
| 52 | Streaming Concepts (pub-sub, topic, partition, broker) |
| 53 | Setting Up Kafka (Docker, producer-consumer via CLI) |
| 54 | Kafka with Python (kafka-python/confluent-kafka) |
| 55 | Kafka vs Airflow + Month 4 Review |

</details>

### TERM 5 — Cloud & Modern Data Stack (Month 5)

<details>
<summary><b>Module 12: AWS</b> (Sessions 56–59)</summary>

| Session | Topic |
|---|---|
| 56 | IAM & S3 (data lake concepts) |
| 57 | AWS Glue (Crawler, Catalog, Glue Jobs) |
| 58 | Redshift (cluster setup, loading from S3) |
| 59 | Lambda & boto3 |

</details>

<details>
<summary><b>Module 13: dbt</b> (Sessions 60–62)</summary>

| Session | Topic |
|---|---|
| 60 | dbt Concepts (ELT paradigm, project setup) |
| 61 | Models & Sources (staging → intermediate → mart) |
| 62 | Testing & Documentation — **Deliverable: Project 5** (S3 → Glue → Redshift → dbt) |

</details>

<details>
<summary><b>Module 14: Data Lake</b> (Sessions 63–64)</summary>

| Session | Topic |
|---|---|
| 63 | Data Lake vs Warehouse vs Lakehouse |
| 64 | Data Governance + Month 5 Review (Delta Lake/Iceberg) |

</details>

### TERM 6 — Capstone & Career Prep (Month 6)

<details>
<summary><b>Module 15: Capstone Project</b> (Sessions 65–69)</summary>

| Session | Topic |
|---|---|
| 65 | Capstone Planning (use case, architecture diagram) |
| 66 | Build: Extract & Streaming Layer |
| 67 | Build: Transform Layer (Spark/PySpark) |
| 68 | Build: Orchestration & Load Layer (Airflow → cloud warehouse) |
| 69 | Build: Transformation Layer (dbt) & Containerize — **Deliverable: Capstone Project** |

</details>

<details>
<summary><b>Module 16: Career Preparation</b> (Sessions 70–73)</summary>

| Session | Topic |
|---|---|
| 70 | Resume & Portfolio (ATS-friendly, GitHub profile README) |
| 71 | SQL & Technical Interview Prep |
| 72 | System Design for Data Engineers |
| 73 | Mock Interview & Behavioral + Final Review |

</details>

---

## Deliverables Summary by Month

| Month | Deliverable |
|---|---|
| 1 | Project 1: Python data cleaning script |
| 2 | Project 2: ETL pipeline (API → transform → PostgreSQL) |
| 3 | Project 3: Big data processing with PySpark → Parquet |
| 4 | Project 4: Scheduled Airflow DAG pipeline |
| 5 | Project 5: Cloud pipeline (S3 → Glue → Redshift → dbt) |
| 6 | Capstone: Full-stack pipeline + Resume + Interview ready |
