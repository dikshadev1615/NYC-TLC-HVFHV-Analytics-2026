# NYC TLC HVFHV Analytics — Q1 2026

> End-to-end analytical study of New York City High-Volume For-Hire Vehicle (HVFHV) trip records, examining demand patterns, provider dynamics, trip economics, geographic concentration, airport activity, shared-ride operations, and changes across Q1 2026.

---

## Executive Summary

This project analyzes **62.87 million NYC TLC High-Volume For-Hire Vehicle (HVFHV) trips recorded during Q1 2026 (January–March)** to understand how the market behaved across demand, providers, trip characteristics, economics, geography, airport-related activity, and shared-ride operations.

The project follows a structured analytical workflow:

**Raw TLC trip records → Data quality investigation → Python EDA → Cleaned analytical datasets → SQL business analysis → Cross-question synthesis**

Rather than treating the dataset as a collection of isolated statistics, the analysis is organized around eight business questions that build a connected view of the Q1 2026 HVFHV market.

### Key Findings

- **Demand is strongly time-dependent:** 6 PM was the highest-demand hour in each month, while 3 AM was consistently the lowest-demand hour.
- **Weekend demand is stronger:** Saturday recorded the highest Q1 day-of-week volume, while Monday recorded the lowest.
- **Provider mix is relatively stable:** **HV0003 (Uber)** accounted for **72.16%** of Q1 recorded trips, while **HV0005 (Lyft)** accounted for **27.84%**.
- **Provider economics differ:** HV0003 (Uber) recorded higher average fare, driver pay, and trip distance, while HV0005 (Lyft) recorded higher average tips.
- **Trip length is strongly associated with trip value:** Most Q1 trips were relatively short, while longer distance and duration bands recorded substantially higher average fares.
- **Airport-fee trips are a small but higher-value segment:** Trips classified using `airport_fee > 0` represented **7.51%** of Q1 demand and had substantially higher average distance, duration, and fare.
- **Shared rides represent limited demand:** Shared requests accounted for **1.80%** of Q1 trips, with a **56.17%** successful match rate.
- **March changed the composition of demand more than its scale:** Normalized daily demand remained relatively stable while average fare, driver pay, tips, distance, and airport-trip share increased and shared-request participation declined.

The resulting analysis provides a business-oriented view of **when demand occurs, how providers differ, what is associated with higher trip value, where demand is concentrated, and which operational changes deserve further investigation.**

---

# Business Problem

A trip-level dataset containing tens of millions of records can describe what happened, but it does not automatically explain the business patterns within the data.

This project addresses eight practical analytical questions:

1. When is HVFHV demand concentrated?
2. How is recorded demand distributed between the two providers?
3. Do providers differ in trip economics and trip characteristics?
4. Where is trip activity concentrated, and which routes occur most frequently?
5. How do distance and duration relate to passenger fare and driver pay?
6. How significant are airport-fee trips within the market?
7. How frequently are shared-ride requests made and successfully matched?
8. What changed across the quarter, and which changes warrant further investigation?

The objective was not simply to calculate descriptive statistics, but to connect these questions into a coherent view of the Q1 2026 HVFHV market.

---

# Dataset

## Source

The project uses the **NYC Taxi & Limousine Commission (TLC) High-Volume For-Hire Vehicle Trip Record** data.

The analysis uses the official NYC TLC HVFHV trip-record data and its associated data dictionary.

## Analysis Period

**Q1 2026 — January, February, and March 2026**

| Month | Analytical Trips |
|---|---:|
| January | 20,940,367 |
| February | 19,875,686 |
| March | 22,058,357 |
| **Q1 Total** | **62,874,410** |

The project intentionally focuses on a single quarter to keep the analysis well-scoped while still working with a sufficiently large dataset for meaningful behavioral and operational analysis.

---

# Provider Identification

The underlying TLC trip records identify the High-Volume For-Hire Service provider through the `hvfhs_license_num` field.

For the providers present in this Q1 2026 analytical dataset:

| TLC HVFHS License | Provider |
|---|---|
| `HV0003` | **Uber** |
| `HV0005` | **Lyft** |

These identifiers are TLC HVFHS license identifiers used in the underlying trip-record data.

Throughout this project, provider-level analysis refers to these TLC identifiers and their corresponding providers.

The Q1 analysis found that:

- **HV0003 (Uber): 72.16% of recorded trips**
- **HV0005 (Lyft): 27.84% of recorded trips**

---

# Analytical Workflow

## 1. Python — Data Quality & Exploratory Analysis

Each monthly dataset was investigated independently before being brought together for the Q1 SQL analysis.

The Python workflow covered:

- Dataset structure and schema validation
- Duplicate detection
- Missing-value investigation
- Negative fare and driver-pay investigation
- Zero-distance and zero-duration investigation
- Timestamp consistency checks
- Trip-duration validation
- Extreme distance and duration investigation
- Speed anomaly investigation
- Provider distribution
- Hourly demand
- Day-of-week demand
- Trip distance and duration distributions
- Pickup and drop-off concentration
- Route frequency
- Fare and driver-pay patterns
- Airport activity
- Shared-ride activity
- Month-level comparisons

### Data Quality Approach
The project does not treat every unusual observation as an error.

Records were investigated before deciding whether they should be removed, retained, or flagged for interpretation.

The objective was to distinguish between:

- Clearly invalid records
- Unusual but potentially meaningful records
- Data-quality issues requiring analytical caution

Across the three monthly datasets:

- January: **6 non-informative records removed**
- February: **0 records removed**
- March: **1 exact duplicate removed**

The resulting analytical dataset contains:

**62,874,410 Q1 trips**

Important data-quality topics investigated included:

- Missing `originating_base_num`
- Negative passenger fares
- Negative driver pay
- Zero-mile and zero-time trips
- Extreme trip distances
- Long-duration trips
- Timestamp ordering inconsistencies
- Recorded versus timestamp-derived trip duration
- Speed anomalies

A key analytical decision was to retain unusual observations where they could not be conclusively established as invalid. This prevents the analysis from silently removing potentially meaningful operational records.

---

# SQL Business Analysis

After the monthly Python analysis and data preparation, the project moved into MySQL for structured business analysis.

Eight analytical views were created, each corresponding to a defined business question.

---

# Q1 — Demand Structure

## Question

**How does HVFHV trip demand vary by month, day of week, and hour of day across Q1 2026?**

The analysis examines:

- Monthly trip demand
- Day-of-week demand
- Hourly demand
- Month × day × hour combinations
- Relative demand shares
- Hourly rankings

### Finding

Demand is strongly concentrated around the evening period.

**6 PM was the highest-demand hour across all three months**, while **3 AM was consistently the lowest-demand hour**.

Saturday also recorded the highest total demand among days of the week, while Monday recorded the lowest.

This establishes the temporal structure of HVFHV demand before moving into provider, economic, and geographic analysis.

---

# Q2 — Provider Market Share

## Question

**How does trip demand and market share differ between HVFHV providers?**

The analysis examines:

- Monthly trip volume
- Provider market share
- Q1 provider totals
- Month-to-month provider mix

### Finding

The provider mix remained relatively stable across the quarter.

| Provider | Market Share |
|---|---:|
| HV0003 (Uber) | 72.16% |
| HV0005 (Lyft) | 27.84% |

HV0003 (Uber) remained the larger recorded provider in every month.

February showed the largest temporary shift in provider mix, with HV0003's share declining from **72.80% to 71.28%**, while HV0005's share increased correspondingly.

By March, the provider mix moved closer to the January pattern.

---

# Q3 — Provider Economics

## Question

**How do the two providers compare in average fare, driver pay, tips, and trip distance?**

| Metric | HV0003 (Uber) | HV0005 (Lyft) |
|---|---:|---:|
| Average Fare | $27.25 | $25.09 |
| Average Driver Pay | $20.88 | $19.25 |
| Average Tips | $1.16 | $1.28 |
| Average Trip Distance | 4.81 mi | 4.40 mi |

### Finding

HV0003 (Uber) recorded higher average fare, driver pay, and trip distance across the quarter.

HV0005 (Lyft) recorded the higher average tip.

The provider comparison therefore shows that differences between the two providers extend beyond trip volume into trip-level economics and characteristics.

The analysis does not interpret these differences as causal.

---

# Q4 — Geographic & Route Demand

## Question

**Which pickup and drop-off locations generate the highest trip volumes, and which routes are most frequently travelled?**

The analysis ranks:

- Pickup locations
- Drop-off locations
- Pickup → Drop-off routes

### Highest-Volume Pickup Locations

The largest pickup origin was:

**Location ID 138 — 1,115,621 trips — 1.77% of Q1 demand**

Other high-volume pickup locations included IDs 132, 61, 76, 79, 37, 161, and 230.

### Highest-Volume Drop-Off Locations

The largest destination was:

**Location ID 265 — 2,621,704 trips — 4.17% of Q1 demand**

This destination was followed by Location IDs 138, 132, 61, and 76.

### Route Patterns

The most frequent individual route was:

**76 → 76**

The highest-volume route between two different location IDs was:

**132 → 265**

Several high-frequency routes also had identical pickup and drop-off IDs.

### Important Geographic Limitation

The current SQL analysis contains **TLC Location IDs rather than geographic zone names**.

The project deliberately does not infer the physical identity of a location ID from the trip data alone.

A separate TLC location-zone lookup would be required before translating these IDs into actual NYC zone names.

---

# Q5 — Trip Characteristics & Fare

## Question

**How do trip distance and trip duration relate to passenger fares?**

Trips were grouped into analytical distance and duration bands and compared across:

- Trip volume
- Share of Q1 demand
- Average distance
- Average duration
- Average passenger fare
- Average driver pay

### Distance Analysis

| Distance Band | Share of Q1 | Average Fare |
|---|---:|---:|
| 0–2 miles | 38.34% | $12.67 |
| 2–5 miles | 32.31% | $22.22 |
| 5–10 miles | 17.59% | $35.51 |
| 10–20 miles | 9.69% | $61.08 |
| 20+ miles | 2.06% | $118.76 |

The relationship is consistently positive:

**Longer distance → higher average fare**

A 20+ mile trip averaged approximately **$118.76**, compared with **$12.67** for a 0–2 mile trip.

### Duration Analysis

Trips lasting under 20 minutes accounted for:

**64.04% of Q1 demand**

Longer duration bands similarly recorded higher average fares and driver pay.

### Business Interpretation

The analysis reveals an important **volume-versus-value distinction**:

- Short trips dominate total demand volume but have lower average fares.
- Long trips represent a relatively small portion of demand but generate substantially higher fare and driver-pay values per trip.

### Analytical Caveat

This analysis demonstrates an observed relationship, not causation.

The appropriate conclusion is:

> Trips in longer distance or duration bands have higher average fares.

The analysis does not establish:

> Distance causes fares to increase.

---

# Q6 — Airport-Fee Trip Analysis

## Question

**How significant are airport-fee trips, and how do they differ from non-airport trips?**

For this analysis, trips were classified using:

`airport_fee > 0`

The comparison covers:

- Trip volume
- Share of demand
- Average distance
- Average duration
- Average fare

| Metric | Airport-Fee Trips | Non-Airport Trips |
|---|---:|---:|
| Q1 Share | 7.51% | 92.49% |
| Average Distance | 13.34 mi | 3.99 mi |
| Average Duration | 36.27 min | 17.72 min |
| Average Fare | $66.10 | $23.43 |

### Finding

Airport-fee trips represent a relatively small share of total Q1 demand but have substantially higher average distance, duration, and fare.

The pattern is consistent across the three months.

March recorded:

- Highest airport-fee trip volume
- Highest airport-trip share
- Highest average airport distance
- Highest average airport duration
- Highest average airport fare

### Important Classification Caveat

This analysis specifically identifies trips with a **positive airport fee**.

Therefore, the analysis should be described as an analysis of **airport-fee trips** rather than assuming that every physical trip to or from an airport is captured by this classification.

---

# Q7 — Shared-Ride Operations

## Question

**What is the scale of shared-ride demand, and how often do shared requests result in successful matches?**

A shared request was identified using:

`shared_request_flag = 'Y'`

A successful shared match required:

`shared_request_flag = 'Y' AND shared_match_flag = 'Y'`

### Q1 Results

| Metric | Q1 Result |
|---|---:|
| Total Trips | 62,874,410 |
| Shared Requests | 1,131,233 |
| Shared Request Rate | 1.80% |
| Successful Matches | 635,362 |
| Match Rate | 56.17% |

### Monthly Pattern

| Month | Shared Request Rate | Match Rate |
|---|---:|---:|
| January | 1.98% | 57.40% |
| February | 1.94% | 56.42% |
| March | 1.50% | 54.34% |

### Finding

Shared rides represent a relatively small portion of total HVFHV demand.

More than half of recorded shared requests resulted in successful matches during Q1, but both participation and match rate declined through the quarter.

The most notable change occurred in March, when the shared-request rate fell from **1.94% to 1.50%**.

---

# Q8 — Monthly Changes & Operational Signals

## Question

**Are there notable changes or anomalies in demand or trip economics across the three months that require further investigation?**

To make monthly demand comparable despite different month lengths, Q8 uses **average daily trips** rather than relying only on raw monthly totals.

The analysis compares month-to-month changes in:

- Average daily demand
- Average fare
- Driver pay
- Tips
- Trip distance
- Trip duration
- Airport-trip share
- Shared-request rate

### Monthly Progression

| Metric | January | February | March |
|---|---:|---:|---:|
| Avg. Daily Trips | ~675K | ~710K | ~712K |
| Avg. Fare | $25.65 | $26.63 | $27.60 |
| Avg. Driver Pay | $19.83 | $20.53 | $20.89 |
| Avg. Tips | $1.16 | $1.19 | $1.23 |
| Avg. Distance | 4.64 mi | 4.65 mi | 4.80 mi |
| Airport-Trip Share | 7.41% | 7.41% | 7.78% |
| Shared-Request Rate | 1.98% | 1.94% | 1.50% |

### Key Signals

#### 1. Trip economics increased consistently

Average fare increased:

**$25.65 → $26.63 → $27.60**

Average driver pay increased:

**$19.83 → $20.53 → $20.89**

Average tips increased:

**$1.16 → $1.19 → $1.23**

This represents a consistent upward movement in observed trip-level economics across the quarter.

#### 2. March distance increased

Average distance moved from:

**4.64 → 4.65 → 4.80 miles**

The March increase is notable because Q5 established a strong relationship between distance bands and average fare.

#### 3. Shared-ride participation declined

Shared-request rate moved from:

**1.98% → 1.94% → 1.50%**

The March decline of **0.44 percentage points** is one of the clearest changes identified in the analysis.

#### 4. Airport-trip share increased modestly

Airport-trip share moved from:

**7.41% → 7.41% → 7.78%**

The increase is smaller than the shared-ride change, but it is relevant because airport-fee trips have substantially higher average fares.

### March as an Investigation Point

March did not experience a major increase in normalized daily demand.

Instead, its most notable characteristic was a **change in trip composition and economics**:

- Daily demand: approximately **+0.24%**
- Average fare: **+3.65%**
- Driver pay: **+1.71%**
- Tips: **+3.12%**
- Distance: **+3.23%**
- Duration: **−0.71%**
- Airport share: **+0.37 pp**
- Shared-request rate: **−0.44 pp**

These patterns are treated as signals for further investigation rather than definitive explanations.

---

# Cross-Analysis Business Story

The eight SQL questions are intentionally connected rather than treated as independent analyses.

The overall Q1 2026 story is:

**Demand is concentrated around specific hours and days → provider mix remains relatively stable → providers exhibit different trip economics → longer trips are associated with higher trip value → airport-fee trips form a smaller but substantially higher-value segment → shared rides represent limited demand and decline through March → March shows meaningful changes in trip composition despite relatively stable normalized demand.**

This progression moves the analysis from simple descriptive statistics toward a more business-oriented understanding of:

- Demand behavior
- Provider structure
- Trip economics
- Geographic concentration
- Airport activity
- Shared-ride operations
- Month-to-month operational changes

---

# Key Methodological Decisions

## 1. Preserve Unusual Observations

Unusual records were not automatically deleted.

The project distinguishes between:

- Clearly invalid records
- Unusual but potentially meaningful records
- Data-quality issues requiring analytical caution

This reduces the risk of introducing unnecessary bias through aggressive filtering.

---

## 2. Use Calendar-Aware Comparisons

February contains 28 days, while January and March contain 31.

Therefore, raw monthly totals should not be interpreted as directly comparable measures of underlying daily demand.

Q8 uses average daily trips when comparing normalized monthly demand.

---

## 3. Separate Observation from Explanation

The analysis deliberately avoids converting observed relationships into causal claims.

For example:

> Longer trips have higher average fares.

is supported by the data.

Whereas:

> Longer distance causes fares to increase.

is not established by this project.

---

## 4. Treat Location IDs as Identifiers

Q4 uses TLC Location IDs exactly as recorded.

The project does not infer the physical identity of IDs such as 138, 265, 132, or 76 without an official TLC location lookup.

---

## 5. Use Field-Based Airport Classification

Airport-related analysis uses:

`airport_fee > 0`

Therefore, the findings specifically describe **airport-fee trips** rather than making assumptions about all trips physically involving an airport.

---

## 6. Use Recorded Trip Duration as the Primary Business Metric

The project investigated differences between TLC-recorded trip duration and timestamp-derived duration during data-quality analysis.

Rather than replacing the TLC-provided field with a calculated value without justification, the recorded `trip_time` field was retained as the primary business duration measure, while timestamp-derived duration was used for quality checks.

---

# Technology Stack

| Layer | Tools |
|---|---|
| Data Source | NYC TLC HVFHV Trip Records |
| Data Format | Parquet |
| Data Preparation | Python |
| Exploratory Analysis | Python / Pandas |
| Database Analysis | MySQL |
| SQL Techniques | CTEs, Window Functions, Aggregations, Ranking, Analytical Views |
| Documentation | Jupyter Notebook / Markdown |
| Version Control | Git / GitHub |

---

# Project Deliverables

## Python

Three month-level notebooks covering:

- Data understanding
- Data-quality investigation
- Cleaning decisions
- Exploratory data analysis
- Business-oriented findings

## SQL

A structured MySQL analytical layer containing:

- Eight business questions
- Analytical queries
- Reusable SQL views
- CTE-based transformations
- Window-function analysis
- Ranking logic
- Cross-month comparisons
- Business-oriented outputs

## Documentation

A consolidated analytical summary documenting:

- Monthly EDA
- SQL findings
- Cross-question insights
- Methodological decisions
- Limitations
- Further investigation areas

---

# Limitations & Further Investigation

This project is intentionally scoped to **Q1 2026** and the fields available in the TLC HVFHV trip records.

Potential extensions include:

- Joining the official TLC Location ID → Taxi Zone lookup
- Translating location IDs into interpretable NYC zone names
- Investigating the drivers of March's change in trip composition
- Examining high-volume locations during peak demand periods
- Comparing route-level economics
- Further segmentation of airport-fee trips
- Deeper analysis of shared-ride matching behavior
- Extending the analysis to additional quarters for seasonal comparison

These are potential extensions rather than conclusions from the current analysis.

---

# Analytical Takeaway

The strongest outcome of this project is not a single KPI.

It is the analytical workflow used to move from **62.87 million raw trip records to a structured business narrative**:

**Understand the data → investigate data quality → clean carefully → explore patterns → formulate business questions → analyze at scale in SQL → connect findings → identify areas for further investigation.**

The project demonstrates how large-scale transactional data can be transformed into a structured analytical framework without relying on unsupported assumptions or treating correlations as causal explanations.

---

# Author

**Diksha Dev**

Miranda House, University of Delhi

LinkedIn: `linkedin.com/in/dikshadev1615`



---

# Data Source & Attribution

Data provided by the **New York City Taxi & Limousine Commission (NYC TLC)**.

The provider identifiers used in this analysis are based on the **TLC HVFHS trip-record data dictionary**.

For this project:

- `HV0003` = **Uber**
- `HV0005` = **Lyft**

These provider identifiers are used as recorded in the TLC HVFHS trip-record data.

This project is an independent analytical portfolio project and is **not affiliated with or endorsed by NYC TLC**.
