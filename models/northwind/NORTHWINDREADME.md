# Northwind Sales Analytics dbt Project

## Business Problem Solved
This project solves three key problems at Northwind Trading:
1. **Messy data** → Standardized column names and data types in staging models
2. **Slow dashboards** → Pre-joined, aggregated mart table for fast BI queries
3. **Inconsistent metrics** → Centralized revenue calculation logic in prep_sales

## Models Overview

### Staging Layer (Clean)
- `staging_orders.sql` - Clean orders with proper dates and snake_case columns
- `staging_order_details.sql` - Clean line items with proper numeric types
- `staging_products.sql` - Clean product catalog
- `staging_categories.sql` - Clean category names

### Prep Layer (Enrich)
- `prep_sales.sql` - **Heart of the project!** Joins all staging tables and calculates revenue

### Mart Layer (Aggregate)
- `mart_sales_performance.sql` - Monthly sales KPIs by category, ready for BI tools

## Key Business Insights Available
- 📊 **Revenue trends** - See which categories are growing month-over-month
- 📦 **Order volume** - Track number of orders per category
- 💰 **Order value** - Monitor average revenue per order
- 🎯 **Category performance** - Compare Beverages vs. Seafood vs. Confections, etc.

## My Biggest Learning Moment
- "Understanding how dbt builds dependencies between models"
- "Getting the revenue calculation exactly right with discount logic"
- "Debugging the source configuration and database permissions"
- "Seeing how staging, prep, and mart layers separate concerns"

