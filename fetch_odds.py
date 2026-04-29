"""
MMA Match Probability Data Pipeline
====================================
Fetches live MMA match odds from The Odds API across multiple market operators
and stores them in a PostgreSQL database for further analysis.

Data source: https://the-odds-api.com
"""

import os
import json
import requests
import psycopg2
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# ============================================================
# API CONFIGURATION
# ============================================================
API_KEY = os.getenv("ODDS_API_KEY")
URL = "https://api.the-odds-api.com/v4/sports/mma_mixed_martial_arts/odds"

params = {
    "apiKey": API_KEY,
    "regions": "eu",         # European market operators
    "markets": "h2h",        # Head-to-head (moneyline) bets
    "oddsFormat": "decimal"  # Decimal odds format (e.g. 1.85 instead of -120)
}

# ============================================================
# FETCH DATA FROM API
# ============================================================
response = requests.get(URL, params=params)
data = response.json()

print(f"Type of response: {type(data)}")
print(f"Number of upcoming matches: {len(data)}")
print(json.dumps(data[0], indent=2))  # Preview of first match


# ============================================================
# DATABASE CONNECTION
# ============================================================
conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    port=os.getenv("DB_PORT"),
    database=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD")
)

cursor = conn.cursor()


# ============================================================
# INSERT MATCH DATA INTO DATABASE
# ============================================================
# Each match contains multiple bookmakers (data sources),
# so we loop through both layers and insert one row per
# (match × bookmaker) combination.

for match in data:
    match_id = match["id"]
    commence_time = match["commence_time"]
    fighter_1 = match["home_team"]
    fighter_2 = match["away_team"]

    for bookmaker in match["bookmakers"]:
        bookmaker_name = bookmaker["title"]
        outcomes = bookmaker["markets"][0]["outcomes"]
        odds_1 = outcomes[0]["price"]
        odds_2 = outcomes[1]["price"]

        cursor.execute(
            """
            INSERT INTO mma_fight_analysis 
            (match_id, commence_time, fighter_1, fighter_2, data_source, 
             win_prob_fighter1, win_prob_fighter2)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
            """,
            (match_id, commence_time, fighter_1, fighter_2, 
             bookmaker_name, odds_1, odds_2)
        )

conn.commit()
cursor.close()
conn.close()

print("Data successfully loaded into database!")
