# Blinkist User Engagement - dbt Project  

## 🛠 Project Overview  
This dbt project processes **Blinkist user engagement data**, transforming raw tracking events from web and mobile into structured analytics-ready tables.  
The goal is to **standardize, unify, and aggregate** user interaction data for better engagement insights.  

---

## 📌 Why DuckDB?  

- **Optimized for analytics** → DuckDB is highly efficient for **analytical workloads**.  
- **Local & lightweight** → Can run fully in-memory, but also supports persistent storage.  
- **Stored as a local database** → The DuckDB instance is saved within the repository for reuse.  

---

## 📌 Exploratory Data Analysis (EDA)  

Before defining dbt models, **a detailed Exploratory Data Analysis (EDA) was conducted using `dtale`**.  

### **Key Findings from EDA**  
✅ **Data format changes (since February)** → The data source format changed and **column extraction no longer worked correctly**, causing incorrect values in `device_locale_country` & `device_locale_language`. This required manual intervention to extract it correctly.  
✅ **Column format changes** → Some columns had type inconsistencies → Standardized across all models.  
✅ **Deduplication needed in Staging** → Implemented using `SELECT DISTINCT` in staging models to remove duplicate events.  

---

## 📌 Data Sources  

### **Web Events**  
- **Source:** `web_events.csv`  
- **Key Fields:**  
  - `event_name`, `event_timestamp`, `user_id`, `session_id`, `item_id`, `item_type`, `item_title`  
- **Web-specific fields:**  
  - `browser_name`, `browser_version`, `language`, `screen_resolution`, `device_type`, `cookies_enabled`, `country_code`  
- **Modifications:**  
  - Added a constant `source_type = 'web'`  
  - Standardized timestamp formats  

### **Mobile Events**  
- **Source:** `mobile_events.csv`  
- **Key Fields:**  
  - `event_name`, `event_timestamp`, `user_id`, `session_id`, `item_id`, `item_type`, `item_title`  
- **Mobile-specific fields:**  
  - `app_version`, `device_locale_code`, `device_locale_country`, `device_locale_language`, `device_make`, `device_platform_name`, `device_platform_version`  
- **Modifications:**  
  - Added `source_type = 'mobile'`  
  - **Locale Fix (Post-February Change)** → Extracted `device_locale_country` & `device_locale_language` from `device_locale_code`.  

---

## 📊 Data Processing  

### **1️⃣ Staging Layer (`stg_*`)**  
Each source is processed separately.  

#### 📌 **Incremental Load**  
- Applied in staging models to process only new records instead of full dataset reloads.  
- Ensures efficient data transformation while keeping event tables up to date.  

#### **stg_web_events.sql**  
- Selects relevant columns from `web_events.csv`.  
- Casts timestamps and renames fields.  
- Removes duplicate events using `SELECT DISTINCT`.  

#### **stg_mobile_events.sql**  
- Processes `mobile_events.csv`.  
- Extracts `device_locale_country` & `device_locale_language` due to format changes.  
- Removes duplicate events using `SELECT DISTINCT`.  

---

### **2️⃣ Intermediate Layer (`int_*`)**  
📌 **Purpose:** Merges web & mobile events into a **consistent structure**.  

#### **int_engagement_events.sql**  
- Standardizes `event_timestamp` across sources.  
- Adds derived time dimensions (`event_date`, `event_hour`, `day_of_week`, `is_weekend`).  

---

### **3️⃣ Mart Layer (`fct_*`)**  
📌 **Final aggregations for reporting**  

#### **fct_engagement_daily.sql**  
- Computes:  
  - **Daily Active Users (DAU)**  
  - **Daily Active Learners (DAL)**  
  - **Content Completions (Web)**  
  - **Regional DAU (DACH)**  

#### **fct_engagement_timeframes.sql**  
- Aggregates engagement metrics over time periods (weekly, monthly, etc.).  

---

## ✅ Data Validation & Testing  

This project **ensures high data quality using dbt-expectations & dbt-utils**.  
**Examples of implemented tests:**  

✅ **Data Freshness** → `dbt source freshness` warns if **data is older than 2 hours**.  
✅ **Anomaly Detection** → `expect_column_values_to_be_within_n_stdevs` detects extreme metric shifts.  
✅ **Logical Consistency** → `expect_column_pair_values_A_to_be_greater_than_B` ensures `daily_active_users >= daily_active_learners`.  

---

## 📑 User Queries  
The queries are available here: [`QUERIES.sql`](QUERIES.sql)  

## 📖 Further Exploration  
The second part of this task—**"Further Exploration"**—is documented separately in: [`FURTHER_EXPLORATION.md`](FURTHER_EXPLORATION.md)  