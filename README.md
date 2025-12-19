# B2B Customer Purchasing & Seasonal Trends Analysis (SQL)

This project analyses B2B customer purchasing behaviour and seasonal sales trends for **Wide World Importers (WWI)** using SQL.  
The objective is to uncover customer segments, high-value buyers, and demand patterns to support data-driven pricing, inventory, and supplier decisions.

---

## 🎯 Project Objective
Understanding customer purchasing behaviour is critical for B2B organisations aiming to optimise marketing strategies and sales performance.

This project addresses key business questions:
- Who are WWI’s most valuable customers?
- How do purchasing patterns vary across customer categories?
- Do seasonal periods significantly impact sales and order behaviour?
- Which regions, cities, and products drive the highest revenue?

The analysis focuses on identifying **actionable insights** that support strategic decision-making rather than isolated query outputs.

---

## 📊 Analytical Approach
SQL was used to perform structured analysis across multiple dimensions of customer and sales data, including:

- Customer purchasing behaviour (order frequency, total spend, average order value)
- Customer category comparison (e.g. novelty shops, supermarkets)
- Seasonal vs regular period analysis
- Geographic performance analysis (state and city level)
- Product-level performance and best-selling items

Complex queries were developed using:
- Joins across multiple relational tables
- Aggregations (SUM, AVG, COUNT, DISTINCT)
- Subqueries
- Conditional logic
- Data filtering across time periods (2013–2016)

---

## 🔍 Key Insights

### Customer & Category Insights
- **Novelty Shops** are the largest revenue contributors, driven by high order frequency and consistent demand  
- **Supermarkets** place frequent orders but with lower average order values, presenting opportunities for targeted pricing and upselling strategies  
- Several customer categories (e.g. wholesalers, agents) show minimal or no recorded sales, indicating potential disengagement or data limitations  

### Seasonal Trends
- Sales remain relatively **stable throughout the year**, with no significant spikes during the October–December period  
- Packaging materials (rather than novelty items) demonstrate consistent demand across both regular and seasonal periods  
- This suggests WWI’s core revenue is driven by essential products rather than seasonal goods  

### Regional & Product Performance
- **Texas** is the top-performing state in total sales  
- **Rockwall, Texas** records the highest city-level sales  
- The **Air Cushion Machine** consistently ranks as the best-selling product, highlighting the importance of operational and packaging supplies  

---

## 💡 Business Implications
- Focus marketing efforts on **high-frequency, high-value customers** within the novelty shop segment  
- Explore strategies to **increase average order value** for supermarket customers  
- Prioritise inventory planning for **non-seasonal, essential products** to ensure revenue stability  
- Replicate successful regional strategies (e.g. Texas) in comparable markets  

---

## 🧱 Project Structure
- `sql_queries.sql` — Core SQL queries used for analysis  
- `analysis_summary.pdf` — Final analytical report and business insights  
- `README.md` — Project overview and findings  

---

## 🛠 Tools Used
- SQL (relational database querying)
- Data aggregation & exploratory analysis techniques

---

## ⚠ Disclaimer
This project was developed as part of academic coursework at the University of Auckland and is shared for educational and portfolio purposes only.
