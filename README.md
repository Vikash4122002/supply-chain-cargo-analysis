# 🚢 Supply Chain Cargo Analysis Dashboard  
### 👨‍💻 Vikash Kumar | Data Analyst  

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![SQL](https://img.shields.io/badge/SQL-025E8C?style=for-the-badge&logo=amazon-dynamodb&logoColor=white)](https://en.wikipedia.org/wiki/SQL)
[![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)]()

---

## 🚀 PROJECT OVERVIEW

End-to-End Data Analysis Project analyzing **Supply Chain Cargo Flow across major Indian ports**.

📌 Built using:
- PostgreSQL
- SQL
- Power BI
- DAX

📌 Focus:
Understanding **before vs after disruption impact** on cargo movement.

---

## 🎥 LIVE DEMO (CLICK IMAGE 👇)

[![Watch Demo](https://img.youtube.com/vi/vhWI5-4j-qk/maxresdefault.jpg)](https://youtu.be/vhWI5-4j-qk)

---

## 📌 BUSINESS PROBLEM

Supply chain disruptions affect:
- Trade flow
- Port efficiency
- Cargo distribution

👉 This project answers:

- How cargo changed before vs after disruption?
- Which ports were most impacted?
- Which cargo types changed the most?
- How did import/export balance shift?

---

## 📊 DASHBOARD PREVIEW

### 🔹 KPI Overview
![KPI](./05_Presentation/Screenshots/KPI_CARD.png)

### 🔹 Supply Chain Overview
![Supply](./05_Presentation/Screenshots/SUPPLY%20CHAIN%20CARGO%20ANALYSIS.png)

### 🔹 Cargo Type Analysis
![Cargo](./05_Presentation/Screenshots/CARGO%20TYPE.png)

### 🔹 Incoming vs Outgoing
![Flow](./05_Presentation/Screenshots/INCOMING%20VS%20OUTGOING%20ANALYSIS.png)

### 🔹 Trade Balance
![Trade](./05_Presentation/Screenshots/TRADE%20BALANCE%20AFTER%20DISRUPTION%20PORT%20BY%20PORT.png)

### 🔹 Disruption Impact
![Impact](./05_Presentation/Screenshots/FLOW%20DISRUPTION%20.png)

---

## 📄 FULL REPORT (DOWNLOAD)

👉 [Download PDF](./04_Outputs/Reports/SUPPLY%20CHAIN%20CARGO%20ANALYSIS.pdf)

---

## 📊 KEY INSIGHTS

### 📈 Overall Impact
- Total Cargo ↑ **+2.4%**
- Incoming Cargo ↓
- Outgoing Cargo ↑
- Tanker Cargo ↑ (energy demand stable)

### 📍 Port-Level Insights
- Mumbai → Highest volume
- Chennai → Stable
- Kochi → Most impacted
- Kolkata → Lowest activity

---

## 📊 DAX MEASURES USED

```DAX
Total Cargo = SUM(port_cargo[cargo_value])

Cargo Before =
CALCULATE(
    SUM(port_cargo[cargo_value]),
    port_cargo[period] = "Before_Disruption"
)

Cargo After =
CALCULATE(
    SUM(port_cargo[cargo_value]),
    port_cargo[period] = "After_Disruption"
)

Growth % =
DIVIDE(
    [Cargo After] - [Cargo Before],
    [Cargo Before],
    0
)

Incoming Cargo =
CALCULATE(
    SUM(port_cargo[cargo_value]),
    port_cargo[flow_type] = "Incoming"
)

Outgoing Cargo =
CALCULATE(
    SUM(port_cargo[cargo_value]),
    port_cargo[flow_type] = "Outgoing"
)

Trade Balance =
[Incoming Cargo] - [Outgoing Cargo]

## 💡 Business Impact

- 📈 Export activity increased post disruption  
- 📦 Container cargo shows clear supply chain stress  
- ⛽ Tanker cargo remained stable → energy demand resilient  
- ⚠️ Kochi identified as most vulnerable port  
- 🏆 Mumbai demonstrated strongest operational resilience  

---

## 🎯 Recruiter Takeaways

✔ Strong SQL & Data Modeling skills  
✔ Solved real-world business problem  
✔ Converted raw data → actionable insights  
✔ Built interactive Power BI dashboards  
✔ Delivered complete end-to-end analytics pipeline  

---

## 🛠 Tech Stack

| Layer | Technology |
|------|------------|
| 🗄 Database | PostgreSQL |
| 🧠 Query Language | SQL |
| 📊 Visualization | Power BI |
| 📈 Analytics | DAX |
| 🔧 Version Control | GitHub |

---

## 📁 Project Structure

📦 **supply-chain-cargo-analysis**  
┣ 📂 00_Documentation  
┣ 📂 01_Data  
┣ 📂 02_SQL  
┣ 📂 03_PowerBI  
┣ 📂 04_Outputs/Reports  
┣ 📂 05_Presentation/Screenshots  
┗ 📄 README.md  

---

## 💡 What I Learned

- 🧹 Data cleaning & transformation  
- 📊 SQL aggregation & analytical querying  
- 📈 Power BI dashboard design  
- ⚡ DAX for KPI calculations  
- 📖 Data storytelling for business decisions  

---

## 👨‍💻 About Me

**Vikash Kumar**  
🎯 Aspiring Data Analyst  

📧 vikash111107@gmail.com  
🔗 https://github.com/Vikash4122002  

---
