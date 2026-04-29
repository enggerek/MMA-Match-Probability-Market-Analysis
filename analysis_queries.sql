-- ============================================================
-- MMA Match Probability & Market Analysis
-- SQL Analysis File
-- ============================================================
-- This file contains the SQL queries used to analyze probability
-- data collected from 15 different sports betting markets via API.
-- The goal is to understand market efficiency, pricing differences,
-- and which operators offer the most competitive (lowest spread) markets.
-- ============================================================


-- ============================================================
-- SECTION 1: TABLE SETUP
-- ============================================================

CREATE TABLE mma_fight_analysis (
  match_id VARCHAR(50),
  commence_time TIMESTAMP,
  fighter_1 VARCHAR(100),
  fighter_2 VARCHAR(100),
  data_source VARCHAR(100),
  win_prob_fighter1 DECIMAL(5,2),  -- decimal market quote for fighter 1
  win_prob_fighter2 DECIMAL(5,2)   -- decimal market quote for fighter 2
);

-- Quick check after data insertion
SELECT * FROM mma_fight_analysis LIMIT 10;


-- ============================================================
-- SECTION 2: TOP UNDERDOG QUOTES
-- ============================================================
-- Looking at the highest decimal quotes for fighter 2  these are
-- the matches where fighter 2 is considered a heavy underdog.

SELECT fighter_1, fighter_2, data_source, win_prob_fighter1, win_prob_fighter2
FROM mma_fight_analysis
ORDER BY win_prob_fighter2 DESC
LIMIT 10;


-- ============================================================
-- SECTION 3: PRICING DISAGREEMENT ACROSS MARKETS
-- ============================================================
-- Which matches have the largest pricing spread between operators?
-- A wide spread means markets disagree on the outcome interesting
-- from a market efficiency perspective.

SELECT
  fighter_1,
  fighter_2,
  COUNT(data_source) AS provider_count,
  ROUND(MIN(win_prob_fighter1), 2) AS min_value,
  ROUND(MAX(win_prob_fighter1), 2) AS max_value,
  ROUND(MAX(win_prob_fighter1) - MIN(win_prob_fighter1), 2) AS value_spread
FROM mma_fight_analysis
GROUP BY fighter_1, fighter_2
ORDER BY value_spread DESC;


-- ============================================================
-- SECTION 4: MARKET COVERAGE BY DATA SOURCE
-- ============================================================
-- How many matches does each operator cover

SELECT data_source, COUNT(DISTINCT match_id) AS match_count
FROM mma_fight_analysis
GROUP BY data_source
ORDER BY match_count DESC;


-- ============================================================
-- SECTION 5: AVERAGE PROBABILITY ANALYSIS
-- ============================================================
-- Average decimal quotes per operator  the closer the total
-- probability is to 100%, the more efficient the market.

SELECT
  data_source,
  ROUND(AVG(win_prob_fighter1), 2) AS avg_winprob_fighter1,
  ROUND(AVG(win_prob_fighter2), 2) AS avg_winprob_fighter2,
  ROUND(AVG(win_prob_fighter1 + win_prob_fighter2), 2) AS avg_total_probability
FROM mma_fight_analysis
GROUP BY data_source
ORDER BY avg_total_probability DESC;


-- ============================================================
-- SECTION 6: IMPLIED PROBABILITY & MARKET MARGIN
-- ============================================================
-- Converting decimal quotes into implied probabilities
-- Total margin > 100% reveals the operator's overround
-- (the structural edge built into the market)

SELECT
  fighter_1,
  fighter_2,
  data_source,
  win_prob_fighter1,
  win_prob_fighter2,
  ROUND((1.0 / win_prob_fighter1 * 100), 2) AS implied_prob_fighter1,
  ROUND((1.0 / win_prob_fighter2 * 100), 2) AS implied_prob_fighter2,
  ROUND((1.0 / win_prob_fighter1 + 1.0 / win_prob_fighter2) * 100, 2) AS total_margin
FROM mma_fight_analysis
ORDER BY total_margin DESC;


-- ============================================================
-- SECTION 7: AVERAGE MARGIN PER OPERATOR
-- ============================================================
-- Lowest average margin = most efficient market for the bettor,
-- since the operator's structural edge is smallest.

SELECT
  data_source,
  ROUND(AVG((1.0 / win_prob_fighter1 + 1.0 / win_prob_fighter2) * 100), 2) AS avg_margin
FROM mma_fight_analysis
GROUP BY data_source
ORDER BY avg_margin ASC;
-- BetOnline appears to offer the most competitive pricing on average (103.73).
-- Betfair, however, shows an unusually high margin (118.18) likely because
-- it operates as a betting exchange rather than a fixed-odds operator,
-- which inflates raw margin calculations


-- ============================================================
-- SECTION 8: BETFAIR ADJUSTMENT — FILTERING OUT EXCHANGE OUTLIERS
-- ============================================================
-- Removing extreme margin outliers (>150%) to get a fair comparison.
-- This corrects for Betfair's exchange style pricing distortion.

SELECT
  data_source,
  ROUND(AVG((1.0 / win_prob_fighter1 + 1.0 / win_prob_fighter2) * 100), 2) AS avg_margin
FROM mma_fight_analysis
WHERE (1.0 / win_prob_fighter1 + win_prob_fighter2) * 100 < 150
GROUP BY data_source
ORDER BY avg_margin ASC;
-- After filtering: Pinnacle takes the lead at 103.72% (most efficient market),
-- BetOnline follows closely as a strong second.
-- Betfair, even after adjustment, still shows the highest spread at 122.57%.
