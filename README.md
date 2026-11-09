# Retail Sales & Profitability Analytics

**An end-to-end business intelligence case study | Tableau · SQL · Python ETL · Data Modeling**

[**Explore the live Tableau dashboards**](https://public.tableau.com/app/profile/felix.akanno/viz/NationalRetailChainEnterpriseBICapstone/SalesOverview) · [**View my portfolio**](https://felixakanno.github.io/)

## Project overview

This capstone project examines sales, customer behaviour, product performance and profitability for a national retail chain. The aim was to turn a multi-table retail dataset into actionable insights for business leaders, store managers and marketing teams; not just build charts.

**Scope:** 5,000 transactions, 200 customers, 50 products and five stores, with transaction dates from **September 10, 2023 through September 9, 2025**.

### Business questions

- How are revenue and profitability changing over time and across stores?
- Which product categories and individual products generate the most revenue and net profit?
- How do sales patterns differ by customer age group, gender and city?
- How does realized net profit margin vary across discount bands?
- Can users inspect transactions behind the summary numbers?

## Executive snapshot

| Measure | Value |
|---|---:|
| Revenue after discounts | **$14,301,903.15** |
| Net profit after discounts | **$3,826,314.67** |
| Net profit margin | **26.75%** |
| Transactions | **5,000** |
| Stores | **5** |
| Products | **50** |
| Customers in the customer source table | **200** |

These totals are source-validated, unfiltered measures. Numbers shown in Tableau change when users apply filters.

## Data and analytical workflow

**Source:** an Excel workbook with four transactional and reference tables: Transactions, Products, Customers and Stores.

1. **Ingest and assess quality.** Inspect field types, null values, unique keys, duplicate transaction IDs and unmatched customer/product/store foreign keys.
2. **Transform locally.** Use reproducible local ETL to derive five curated tables: `fact_sales`, `dim_customers`, `dim_products`, `dim_stores` and `dim_date`.
3. **Calculate finance metrics.** Integrate product costs and prices with transaction quantities and discounts.
4. **Validate aggregates.** Reconcile transaction counts and revenue, discount, and net-profit totals against the source data.
5. **Prepare a public-safe extract.** Flatten the relevant fields for Tableau Public, omitting direct customer identifiers, names, and dates of birth.
6. **Build interactive Tableau dashboards.** Add filters, tooltips, rankings, conditional margin levels and transaction-level drill-through.

### Dimensional model

```text
   dim_customers            dim_products
          \                  /
           \                /
                 fact_sales
              /            \
       dim_stores         dim_date
```

The **fact table** contains transaction-level measures and dimension keys. The dimension tables describe customers, products, stores and calendar dates. Tableau uses a denormalized extract generated from these curated tables for convenient visualization.

### Metric definitions

The following definitions distinguish revenue before and after discounts and profit before and after discounts:

```text
Gross Sales       = Quantity × Unit Price
Discount Amount   = Gross Sales × Discount Rate
Total Sales       = Gross Sales − Discount Amount
Profit            = Gross Sales − (Quantity × Unit Cost)    [before discount]
Net Profit        = Total Sales − (Quantity × Unit Cost)    [after discount]
Net Profit Margin = SUM(Net Profit) / SUM(Total Sales)
```

The Tableau dashboards use **Net Profit** for profitability after discounts. Margin is calculated from summed profit and revenue, not an average of transaction-level percentages.

### Technology and implementation status

| Component | Used for | Status |
|---|---|---|
| Excel / CSV | Original retail tables, Tableau extract | Completed |
| Python / local ETL | Data transformation and validation | Executed and validated locally |
| SQL / BigQuery dialect | Documenting curated data model and transformations | Prepared; **not run in Google Cloud** |
| Tableau Public | Three interactive dashboards and transaction drill-through | Published |

The SQL under [`sql/`](sql/) is a documented BigQuery implementation. It is provided to show data modeling and SQL design, **not as evidence of a successfully deployed or executed BigQuery pipeline**. Replace the placeholder project ID and adjust source column names if executing it in your own environment.

## Interactive dashboards

The Tableau workbook includes four user-facing views:

| View | Focus |
|---|---|
| **Sales Overview** | Revenue, net profit, monthly trend, category and store performance, discount impact |
| **Customer Insights** | Revenue by age group/gender, age–gender transaction counts, top customer cities, tenure summary |
| **Product & Store Performance** | Top/bottom 10 products, profit by category, store category mix, payment-method breakdown |
| **Transaction Drill-Through** | Select a store, then a product, to inspect matching transaction records |

**[Open Sales Overview — interactive Tableau workbook](https://public.tableau.com/app/profile/felix.akanno/viz/NationalRetailChainEnterpriseBICapstone/SalesOverview)**

*Tip:* The live workbook is the best way to explore filters and drill-through. Its published views are publicly accessible.

## Findings

- **Category trade-offs:** Electronics generated the highest revenue (**$6.32M**). Fashion generated the highest net profit (**$1.66M**). Groceries generated less revenue but qualified as the high-margin category in the dashboard's threshold scheme.
- **Store performance:** MegaMart New Michele led revenue at approximately **$2.92M**; MegaMart Peckmouth generated approximately **$2.75M**.
- **Customer segments:** The 55–64 age group generated approximately **$2.89M** in sales. Transactions associated with male customers accounted for approximately **56.4%** of total revenue.
- **Discount bands:** Net profit margin was approximately **32.2%** for discounts below 5% versus **20.6%** for discounts from 15% up to but excluding 20%. This is a descriptive association, not proof that discounting caused the difference.
- **Payment methods:** Cash (1,284 transactions), Credit Card (1,281), and Mobile Money (1,276) were used at similar frequencies.

## Business recommendations

1. **Evaluate sales and profit together.** Compare product and category decisions using revenue, net profit and net margin—not sales volume alone.
2. **Investigate store and product gaps.** Review transaction counts, product mix, and margins in lower-revenue stores or products before making operational changes.
3. **Monitor promotional economics.** Track discount bands, realized margins and purchasing volume; use controlled tests before making causal claims about promotional effects.
4. **Support self-service decisions.** Use the Store → Product → Transaction workflow to move from performance summaries to individual records.

## Limitations and responsible interpretation

- The dataset ends on **September 9, 2025**; September 2025 is an **incomplete month** and should not be compared with a full month without adjustment.
- The Customer Tenure Distribution uses a **separate, fixed summary of 200 customers** and is not affected by transaction-based filters on the Customer Insights dashboard.
- The demographic stacked chart counts **transactions**, not unique customers. The public transaction extract deliberately omits direct customer identifiers.
- Source-data validation identified some transactions dated before the corresponding customer's recorded joining date. No records were silently altered; tenure is therefore reported as a fixed customer-level summary rather than tenure at purchase.
- All findings are descriptive; category differences and discount–margin associations do not establish causation.

## Repository contents

```text
retail-sales-business-intelligence/
├── README.md
├── sql/
│   └── Part2_Corrected_BigQuery_ETL.sql
└── docs/
    └── BI_Capstone_Part3_Executive_Summary_Felix_Akanno.docx
```

The raw and transaction-level datasets are not included in this repository. The Tableau extract is published separately on Tableau Public; share data only when you are authorized to do so.

## About the author

**Felix Akanno** — data analytics and biostatistics professional working with SQL, Python, R, Tableau and business intelligence tools.

[Portfolio](https://felixakanno.github.io/) · [GitHub](https://github.com/FelixAkanno) · [LinkedIn](https://www.linkedin.com/in/felixakanno)

---

*This project was completed as a business intelligence capstone case study supported by NPower Canada 2026 Cohort.*
