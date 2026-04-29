"""
MMA Match Probability Analysis
==============================
Reads raw market data from PostgreSQL, calculates implied probabilities
and total market margin (overround), removes duplicates, and exports
the result to a CSV file for use in Power BI.
"""

import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


# ============================================================
# DATABASE CONNECTION
# ============================================================
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")

engine = create_engine(
    f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
)


# ============================================================
# READ DATA FROM DATABASE
# ============================================================
query = "SELECT * FROM mma_fight_analysis"
df = pd.read_sql(query, engine)

print(f"Data shape: {df.shape}")
print(df.head())


# ============================================================
# CALCULATE IMPLIED PROBABILITIES & MARGIN
# ============================================================
# Convert decimal market quotes into implied probabilities.
# Total margin > 100% reveals the operator's overround
# (the structural edge built into the market).

df["implied_prob_fighter1"] = round(1.0 / df["win_prob_fighter1"] * 100, 2)
df["implied_prob_fighter2"] = round(1.0 / df["win_prob_fighter2"] * 100, 2)
df["total_margin"] = round(
    df["implied_prob_fighter1"] + df["implied_prob_fighter2"], 2
)

print(df.head())


# ============================================================
# CLEAN & EXPORT
# ============================================================
df = df.drop_duplicates()
df.to_csv("mma_fight_analysis.csv", index=False, decimal=",")

print("CSV saved successfully!")
