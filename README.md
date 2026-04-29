cat > README.md << 'EOF'
# 🚢 Supply Chain Cargo Analysis Dashboard  
### 👨‍💻 Vikash Kumar | Data Analyst  

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Power BI](https://img.shields.io/badge/Power%20BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)](https://powerbi.microsoft.com/)
[![SQL](https://img.shields.io/badge/SQL-025E8C?style=for-the-badge&logo=amazon-dynamodb&logoColor=white)](https://en.wikipedia.org/wiki/SQL)
[![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)]()

---

## 🚀 Project Overview

End-to-End Data Analysis Project analyzing **Supply Chain Cargo Flow across major Indian ports** using:

- PostgreSQL
- SQL
- Power BI
- DAX

This project focuses on **before vs after disruption analysis** to uncover real-world supply chain insights.

---

## 🎥 Live Demo

👉 https://youtu.be/vhWI5-4j-qk

---

## 📊 Dashboard Preview

### 🔹 KPI Overview
![KPI](./05_Presentation/Screenshots/KPI_CARD.png)

### 🔹 Supply Chain Overview
![Supply](./05_Presentation/Screenshots/SUPPLY%20CHAIN%20CARGO%20ANALYSIS.png)

### 🔹 Cargo Type Analysis
![Cargo](./05_Presentation/Screenshots/CARGO%20TYPE.png)

### 🔹 Incoming vs Outgoing
![Flow](./05_Presentation/Screenshots/INCOMING%20VS%20OUTGOING%20ANALYSIS.png)

### 🔹 Trade Balance by Port
![Trade](./05_Presentation/Screenshots/TRADE%20BALANCE%20AFTER%20DISRUPTION%20PORT%20BY%20PORT.png)

### 🔹 Disruption Impact
![Impact](./05_Presentation/Screenshots/FLOW%20DISRUPTION%20.png)

---

## 📄 Download Full Report

👉 [Download PDF](./04_Outputs/Reports/SUPPLY%20CHAIN%20CARGO%20ANALYSIS.pdf)

---

## 📊 Key Insights

- Total cargo increased by **2.4%**
- Incoming cargo **decreased**
- Outgoing cargo **increased**
- Tanker cargo showed **growth (energy demand stable)**
- Mumbai handled the **highest cargo volume**

---

## 📍 Port Insights

- Mumbai → Highest activity
- Chennai → Stable performance
- Kochi → Most impacted
- Kolkata → Lowest volume

---

## 📊 DAX Measures Used

\`\`\`DAX
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
\`\`\`

---

## 🛠 Tech Stack

- PostgreSQL
- SQL
- Power BI
- DAX
- GitHub

---

## 📁 Project Structure

📦 supply-chain-cargo-analysis  
┣ 📂 00_Documentation  
┣ 📂 01_Data  
┣ 📂 02_SQL  
┣ 📂 03_PowerBI  
┣ 📂 04_Outputs/Reports  
┣ 📂 05_Presentation/Screenshots  
┗ 📄 README.md  

---

## 💡 What I Learned

- SQL-based data analysis  
- Dashboard design using Power BI  
- DAX for business metrics  
- Data storytelling  

---

## 👨‍💻 About Me

**Vikash Kumar**  
Aspiring Data Analyst  

📧 vikash111107@gmail.com  
🔗 https://github.com/Vikash4122002  
