# Marketing Campaign Analysis (SQL Case Study)

### Project Overview
This project analyzes **marketing campaign performance** using SQL in **PostgreSQL (pgAdmin 4)**.  
The goal was to measure how effectively marketing spend translated into revenue across different **platforms**, **audience types**, and **days of the week**, and to calculate performance metrics such as **ROMI**, **CPC**, **CAC**, and **AOV**.  

The analysis identifies which campaigns were most profitable, when customers were most active, and how the company could optimize its marketing budget to maximize ROI.

---

##  Objectives
- Evaluate overall **Return on Marketing Investment (ROMI)** and profitability.  
- Compare performance across **marketing platforms** (Facebook, YouTube, Instagram, Google, etc.).  
- Analyze **target audience types** (Blogger, Retargeting, Tier 1, Tier 2, etc.).  
- Determine performance differences between **Weekdays vs Weekends**.  
- Identify **daily ROMI trends** to uncover peak and low-performing days.

---

##  Key Metrics Calculated
| Metric | Formula | Description |
|---------|----------|-------------|
| **ROMI** | `(Revenue - Marketing Spend) / Marketing Spend` | Return on Marketing Investment |
| **CPC** | `Marketing Spend / Clicks` | Cost per Click |
| **CPL** | `Marketing Spend / Leads` | Cost per Lead |
| **CAC** | `Marketing Spend / Orders` | Customer Acquisition Cost |
| **AOV** | `Revenue / Orders` | Average Order Value |
| **CTR** | `Clicks / Impressions` | Click-through Rate |
| **Conversion 1** | `Leads / Clicks` | Visitor → Lead conversion |
| **Conversion 2** | `Orders / Leads` | Lead → Customer conversion |
| **Profit** | `Revenue - Marketing Spend` | Net marketing profit |

---

##  Tools & Technologies Used
- **Database:** PostgreSQL (pgAdmin 4)  
- **Language:** SQL (Aggregations, CASE statements, Views, Grouping)  
- **Environment:** pgAdmin Query Tool  
- **Data Source:** Kaggle – Marketing Campaign Performance Dataset  

---

##  Project Workflow

1. **Data Preparation**
   - Imported `marketing.csv` into PostgreSQL database.  
   - Created the main table `marketing_data` with proper data types.  

2. **Data Cleaning & Enrichment**
   - Added columns:
     - `day_type` → Weekday / Weekend using SQL `CASE` & `EXTRACT(DOW)`  
     - `geo` / `target_type` → Derived from campaign names (Tier1, Blogger, etc.)  

3. **Metric View Creation**
   - Built a SQL **VIEW** called `marketing_metrics` to calculate ROMI, CPC, CAC, AOV, CTR, and Profit automatically for each campaign.

4. **Performance Analysis**
   - Overall ROMI  
   - ROMI by Platform  
   - ROMI by Target Type  
   - ROMI by Day Type (Weekday vs Weekend)  
   - Date-wise ROMI trends  

---

## Key Insights

### Overall Performance
| Metric | Value (₹) |
|---------|------------|
| **Total Spend** | 30,590,879.82 |
| **Total Revenue** | 42,889,366.00 |
| **Profit** | 12,298,486.18 |
| **Overall ROMI** | **0.40** |

*For every ₹1 spent, the company earned ₹1.40 — profitable overall.*

---

### Platform-wise Performance
| Platform | ROMI | Total Spend | Total Revenue | Avg CAC | Avg AOV |
|-----------|------|--------------|----------------|----------|----------|
| **YouTube** | **2.77** | 4.06M | 15.31M | 2,090 | 8,046 |
| **Instagram** | 0.40 | 7.88M | 11.02M | 3,480 | 4,402 |
| **Banner** | 0.22 | 5.03M | 6.15M | 3,071 | 3,888 |
| **Google** | 0.07 | 3.46M | 3.70M | 4,177 | 5,359 |
| **Facebook** | **-0.34** | 10.17M | 6.70M | 5,655 | 4,003 |

**Insight:**  
YouTube was the most efficient channel with the highest ROMI (2.77).  
Facebook campaigns performed poorly, showing a significant loss.

---

### Target Type Performance
| Target Type | ROMI | Total Revenue | Total Spend | Avg CAC | Avg AOV |
|--------------|------|---------------|--------------|----------|----------|
| **Blogger** | **1.54** | 21.1M | 8.3M | 2,995 | 6,592 |
| **Retargeting** | **1.01** | 0.54M | 0.27M | 2,120 | 4,984 |
| **Hot** | 0.84 | 2.21M | 1.20M | 4,295 | 7,937 |
| **Tier 1** | 0.35 | 6.94M | 5.13M | 4,407 | 5,414 |
| **Lookalike** | **-0.89** | 0.30M | 2.64M | 8,422 | 1,062 |

**Best audiences:** Blogger and Retargeting  
**Worst:** Lookalike and Tier 2 audiences

---

### Weekday vs Weekend Performance
| Day Type | ROMI | Avg CAC | Avg AOV | Total Revenue | Total Spend |
|-----------|------|----------|----------|---------------|--------------|
| **Weekday** | **0.43** | 4,202.93 | 4,711.48 | 31.22M | 22.39M |
| **Weekend** | 0.34 | 4,268.06 | 4,784.85 | 11.67M | 8.20M |

**Insight:**  
- Weekdays delivered higher efficiency (ROMI 0.43).  
- Weekends showed slightly higher order values (AOV).

---

###  Daily ROMI Trends (February 2021)
- ROMI ranged between **0.11** and **0.95**.  
- Best-performing days: **Feb 3, Feb 11, Feb 26**.  
- Low-performing days: **Feb 10, Feb 16–18**.  
- Mid-month dip suggests **campaign fatigue** or **budget reallocation**.

---

### Combined Platform + Target Type Insights
| Platform | Target Type | ROMI | Key Finding |
|-----------|--------------|------|--------------|
| **YouTube + Blogger** | **2.77** | Best-performing combination |
| **Facebook + Retargeting** | 1.01 | Strong remarketing efficiency |
| **Google + Hot** | 0.84 | Good for intent-driven conversions |
| **Facebook + Lookalike** | **-0.89** | Worst — costly and ineffective |

 **Winning Combo:** YouTube + Blogger  
**Losing Combo:** Facebook + Lookalike

---

##  Business Recommendations

| Area | Action |
|-------|--------|
| **Budget Allocation** | Shift 20–30% of Facebook budget to YouTube |
| **Audience Focus** | Prioritize Blogger and Retargeting audiences |
| **Channel Optimization** | Continue YouTube, Instagram Tier 1, Google Hot |
| **Stop / Pause** | Facebook Lookalike, Tier 2, and Wide targeting |
| **Scheduling** | Focus spend on weekdays for higher efficiency |

---

## 📂 Repository Structure
marketing-campaign-analysis/
│
├── README.md                  ← Project summary (this file)
├── marketing_analysis.sql      ← SQL queries with comments
├── marketing_insights.pdf      ← Report with results and explanations
├── marketing_data_sample.csv   ← Optional sample dataset
└── screenshots/                ← SQL outputs and charts

## 🏁 Conclusion
> The marketing campaigns were overall profitable with an **Overall ROMI of 0.40**, meaning ₹1.40 earned per ₹1 spent.  
> The **YouTube + Blogger** combination achieved the highest ROI (ROMI 2.77), while **Facebook + Lookalike** performed worst (ROMI -0.89).  
> By reallocating budgets toward high-performing channels and optimizing low-performing ones, overall marketing ROI can increase by **30–40%**.

---

## Author
**Project by:** Dinesh Auzi  
**Database:** PostgreSQL (pgAdmin 4)  
**Language:** SQL  
**Dataset:** Kaggle – Marketing Campaign Performance  
