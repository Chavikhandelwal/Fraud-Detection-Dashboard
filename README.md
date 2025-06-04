# Fraud-Detection-Dashboard
Built using MySQL and Power BI to identify and visualize suspicious digital transactions. Implemented 5 SQL-based fraud rules, created a dynamic alerts table, and built an interactive dashboard to track resolution status, fraud severity, and daily alert trends with drill-down capabilities.

# 🔍 Fraud Detection Dashboard | SQL + Power BI

This project showcases an end-to-end **fraud detection system**, built using **SQL logic and Power BI**, to identify suspicious financial activity in a simulated digital payments platform.

## 🎯 Project Objective

To create a smart, interactive fraud detection engine that tracks, classifies, and visualizes alerts generated from transactional anomalies — helping analysts quickly spot fraud patterns and take action.

---

## 🧠 What I Built

✅ **Fraud Detection Logic in SQL**  
Designed 5+ business rules to flag:
- Transactions from blacklisted IPs
- High-value international transfers
- Repeated usage of unregistered devices
- Abnormal user behavior or spending
- Rapid multiple transactions by same user/device

✅ **Automated Alerts Table**  
- Stored all fraud flags with reason, timestamp, amount, and resolution status
- Created a true case-tracking system, not just a visual report

✅ **Power BI Dashboard**  
- Donut chart for resolution status  
- KPI card for total alerts  
- Interactive line chart (alerts over time)  
- Bar chart by fraud reason  
- Toggle buttons for **Severity** & **Resolution**
- Drill-down table of full alert records  
- Transparent theme for executive polish ✨

---

## 🛠 Tech Stack

- **MySQL** — fraud rule logic + alert generation  
- **Power BI** — dashboard design & visualization  
- **DAX** — dynamic columns (severity, resolution text)  
- **CSV files** — mock data import for visual modeling

---

## 🖼 Preview

![Dashboard Preview](images/dashboard.png)

---

## 📁 What’s Inside This Repo?

| File                     | Purpose                             |
|--------------------------|--------------------------------------|
| `fraud_dashboard.pbix`   | Full Power BI dashboard file         |
| `alerts.csv`             | Alert table data (from SQL)          |
| `transactions.csv`       | Source transaction data              |
| `fraud_rules.sql`        | SQL fraud detection logic (optional) |
| `README.md`              | This documentation                   |

---

## 👩‍💻 Author

**Chavi Khandelwal**  
📫 www.linkedin.com/in/chavi-khandelwal-1626a12b9 | ✉️ chavikhandelwal47@gmail.com

---

## ✅ Why This Matters

This dashboard simulates what real fraud analysts or risk managers use in banks, fintechs, and e-commerce. It blends data engineering (SQL), business logic, and BI visualization — making it a strong portfolio project for any data/analytics role.

