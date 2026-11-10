# Retail Sales & Customer Intelligence Using PostgreSQL

SQL analysis of sales and customer data for **Duka Smart Electronics**, a (fictional) Kenyan
electronics retailer trading in ten towns since January 2025. The project sets up a PostgreSQL
database, answers 46 business questions in SQL — from basic filters to window functions, a view and a
PL/pgSQL function — and turns the results into recommendations for management.

**Headline results:** 800 orders · KSh 24.16M completed revenue · KSh 2.89M profit (12.0% margin) ·
revenue up 86% year on year (Jan–Sep 2026 vs 2025) · top 25% of customers = 69% of revenue.
See [`insights.md`](insights.md) for the full findings.

---

## Repository layout

```
retail-sales-sql/
├── README.md        # this file
├── schema.sql       # CREATE TABLE statements (tightened version of the provided 02 script)
├── queries.sql      # all 46 answers, numbered -- Q1 … -- Q46
├── insights.md      # 7 business insights with numbers, impact and recommendations
└── screenshots/     # 05_verify_data output + selected query results
```

## The data

Two tables, one customer to many orders:

```
customers (1) ──────────< orders (many)
customer_id               customer_id
```

| Table | Rows | Key columns |
|---|---|---|
| `customers` | 150 | `customer_id` (PK), name, gender, city, `registration_date`, `customer_segment` (Retail / Corporate / VIP) |
| `orders` | 800 | `order_id` (PK), `customer_id` (FK), `order_date`, product, category, `quantity`, `unit_price`, `cost_price`, `discount` (%), payment method, `order_status` |

Orders run from **2025-01-01 to 2026-09-30** across 21 products in 5 categories.

## Setup

Requires **PostgreSQL 14+**.

```bash
# 1. Create the database (connected to the default postgres DB)
psql -U postgres -d postgres -c "CREATE DATABASE retail_analytics;"

# 2. Create the tables
psql -U postgres -d retail_analytics -f schema.sql

# 3. Load the data (insert scripts from the project page — not included in this repo)
psql -U postgres -d retail_analytics -f 03_insert_customers.sql
psql -U postgres -d retail_analytics -f 04_insert_orders.sql

# 4. Check the load: expect 150 customers, 800 orders, 0 orphan orders
psql -U postgres -d retail_analytics -f 05_verify_data.sql
```

In **pgAdmin**: create `retail_analytics` from the Databases menu, open the Query Tool on it, then
open and run each file in the same order.

`schema.sql` improves on the provided table script: `NOT NULL` on every column the analysis relies
on, `CHECK` lists for city and product category, and two extra indexes (`order_status`,
`product_category`) for the filters and groupings used in nearly every query. All of the provided
data loads into it without errors.

## Running the queries

Run everything at once:

```bash
psql -U postgres -d retail_analytics -f queries.sql
```

or open `queries.sql` in pgAdmin / DBeaver and run one question at a time (highlight the query and
press F5 / Ctrl+Enter). Q43 creates the view `monthly_sales_summary`, and Q44 creates the function
`customer_completed_revenue(id)`. Both use `CREATE OR REPLACE`, so the file can be run repeatedly.
Run Q43 before Q46, which reads the view.

| Section | Questions | Covers |
|---|---|---|
| A — Fundamentals | Q1–Q10 | `SELECT`, `WHERE`, `DISTINCT`, `ORDER BY`, `LIMIT`, `LIKE`, `BETWEEN` |
| B — Aggregation | Q11–Q20 | `COUNT`/`SUM`/`AVG`, `GROUP BY`, `HAVING`, `FILTER` |
| C — Joins | Q21–Q28 | `INNER`/`LEFT JOIN`, customers with no orders, segment analysis |
| D — Subqueries & CTEs | Q29–Q34 | above-average spenders, monthly top 3, category margins, lapsed customers |
| E — Window functions | Q35–Q42 | `RANK`, `ROW_NUMBER`, `DENSE_RANK`, running totals, `LAG`, MoM growth, `NTILE`, share of total |
| F — Business intelligence | Q43–Q46 | view, PL/pgSQL function, value segmentation, management report |

## Business rules and definitions

| Measure | Formula |
|---|---|
| Revenue | `quantity * unit_price * (1 - discount / 100)` |
| Cost | `quantity * cost_price` |
| Profit | `revenue - cost` |
| Profit margin % | `profit / NULLIF(revenue, 0) * 100` |

- **Money questions use Completed orders only**; order counts include every status; customer counts
  are distinct.
- **"Today" = `MAX(order_date)`** (2026-09-30), so results do not depend on when the queries run.
- **Months** are `DATE_TRUNC('month', order_date)` — year and month together.
- Money is rounded to 2 decimal places.

Choices where a question was open to more than one reading (each is also commented in `queries.sql`):

| Question | Definition used |
|---|---|
| Q18 quantity sold | Units in Completed orders only |
| Q22 spending by customer | `LEFT JOIN` so all 150 customers appear; non-buyers show 0 |
| Q27 average spending by segment | Total per purchasing customer first, then averaged per segment |
| Q28 most popular VIP category | Number of orders placed (units as tie-breaker) → **Home Appliances** |
| Q30 average unit price | Average across all order lines |
| Q32 purchasing from 3+ categories | Completed orders only |
| Q35 / Q41 ranking and quartiles | Purchasing customers only (132) |
| Q45 value bands | High ≥ KSh 250,000 · Medium KSh 50,000–249,999 · Low < KSh 50,000 · plus "No Purchase" — based on the quartiles of customer spending (75th percentile ≈ 253k, median ≈ 90k); reasoning in the Q45 comments |

## Key findings

1. **Accessories are 4.5% of revenue but 15.8% of profit** (42% margin vs ~10% for phones and laptops).
2. **Discounts of 15% or more lose money** — those 97 orders made a combined loss of KSh 26,810.
3. **Revenue +86% year on year**, but January 2026 was 84% below December 2025.
4. **34 High Value customers produce 70% of revenue.**
5. **The VIP label does not match spending** — the top 5 customers are all labelled Retail.
6. **47 buying customers (36%) have lapsed for 90+ days**, including 6 VIPs.
7. **Nairobi is 40% of revenue**, and 11.25% of orders are cancelled (M-Pesa 12.5% vs Bank Transfer 4.8%).

Details and recommendations: [`insights.md`](insights.md).

## Screenshots

See [`screenshots/`](screenshots/): the `05_verify_data.sql` checks, plus the results of Q33
(category profitability), Q40 (month-on-month growth), Q45 (value bands) and Q46 (management report).

## Tools

PostgreSQL 16 · psql / pgAdmin 4 · Git & GitHub