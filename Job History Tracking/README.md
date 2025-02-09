# SQL Job Execution Monitoring

# Project Overview
This repository contains SQL scripts used to track **SQL Server job execution history** and ensure proper data administration for the BI team.  

**Why is this important?**
- The BI team is responsible for **data integrity & governance**.
- Ensuring scheduled jobs **run successfully** is a **performance KPI** for the team.
- This data will be used to calculate KPI scores for the team.

**How It Works**
- The stored procedure `[maint].[pSQL_JobHistory]` pulls job execution details daily.
- Uses **MERGE** to **update existing job runs** or **insert new ones**.
- Maintains a **historical record of job execution success/failure**.

**SQL Code Highlights**
- Uses a **table variable (`@JobHistory`)** instead of temp tables for performance.
- Tracks **success & failure counts, along with percentage rates**.
- **MERGE operation** ensures:
  - Jobs running multiple times in a day **update existing records**.
  - Jobs running for the first time **insert new records**.

**Business Value**

**Better Data Governance:**  
- Ensures SQL jobs are **running as expected**.
- Helps **detect failures quickly** for BI team action.

**Improves BI Team Performance Metrics:**  
- **Automates SQL job tracking**, saving time on **manual log checks**.  
- Supports **performance KPIs** for job execution monitoring.

**Facilitates Historical Analysis:**  
- Provides **historical job performance trends** for insights.
- Helps in **predicting failures & optimizing scheduling**.

