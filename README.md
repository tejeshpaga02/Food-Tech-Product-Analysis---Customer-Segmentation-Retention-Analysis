# Food-Tech Customer Analysis - RFM Segmentation and Retention Analysis
  Segmented 206,209 food tech customers into 10 behavioral groups using RFM analysis with NTILE window functions on 3.4 million orders — identifying that Champions (11.33%) average 46.79 orders each while 42% of the base shows active churn signals.

# Business Problem
Consumer food tech platforms live and die by customer retention. Without understanding which customers are loyal, which are at risk, and which are already lost — product and marketing teams allocate budget blindly. This project builds a complete customer segmentation system using RFM (Recency, Frequency, Monetary) analysis to answer: who are our best customers, who is about to churn, and where should we focus retention efforts?

# Dataset
Source : kaggle.com/datasets/psparks/instacart-market-basket-analysis
Files : 6 CSV files
Scale : 3.4 million orders, 206,209 unique customers, 32 million product-level records
Domain : Food Tech / Consumer Internet — Product Analytics

# Files Contents
orders.csv - order_id, user_id, order_number, days_since_prior_order
order_products__prior.csv - Product-level order data — 32M rows
products.csv - Product names and categories
aisles.csv - Aisle classifications
departments.csv - Department names

# Tools Used
SQL(SSMS) - Data cleaning, 4-table JOIN to build orders_enriched, customer_summary aggregation, RFM scoring using NTILE(4) window function, segment assignment
Python(Pandas) - EDA on RFM output, customer distribution analysis
Python(Seaborn) - 5 charts - segment distribution, frequency histogram, recency boxplot, department reorder rates, RFM heatmap
Power BI(Power Query) - Conditional columns — Churn_Risk, User_Type, Segment_Priority
Power BI(DAX) - 11 DAX measures
Power BI Dashboard - 2-page interactive dashboard

# RFM Methodology
Recency (R): Days since customer's last order - lower = more recent = better
Frequency (F): Total orders placed — higher = more frequent = better
Monetary (M): Total reorders (proxy for value since price data unavailable) - higher = more valuable = better
Each dimension scored 1–4 using NTILE(4) window function in SQL:
Score 4 = best quartile
Score 1 = worst quartile
Recency: ORDER BY ASC (lower days = score 4)
Frequency + Monetary: ORDER BY DESC (higher = score 4)

# Customer Segments
Lost - 35,364 - 17.1% - Maximum recency gap — inactive
Needs Attention - 29,495 - 14.3% - Below average across all dimensions
Champion23,370 - 11.3% - Recent, frequent, high reorders
At Risk 22,057 - 10.7% - Good history, going quiet
Promising - 21,748 - 10.5% - Recent but low frequency
New Customer - 16,498 - 8.0% - Very recent, few orders
Cannot Lose Them - 16,188 - 7.9%- High value but recency gap
Other - 16,009 - 7.8% - Mixed signals
Potential Loyal - 13,795 - 6.7% - Good frequency, growing
Loyal - 11,685 - 5.7% - Consistent, reliable

# Key Findings
Total customers segmented - 206,209
Champion customers - 23,370 (11.33%)
Champion avg orders - 46.79 per customer
Platform avg orders - 16.59 per customer
Champion vs platform avg - 2.8x more orders
At Risk customers - 22,057
Lost customers - 35,364 (17.1%)
Churn risk total - 42.15% of base
Avg days between orders - 13.43 days
Cannot Lose Them recency - 30 days — maxed out

# Strongest insight 
Champions represent 11.33% of customers but average 46.79 orders each - nearly 3x the platform average of 16.59. The At-Risk segment (22,057 customers) has strong historical frequency but 23+ days since last order - these are the highest-ROI re-engagement targets because they have demonstrated loyalty and just need a nudge back

# Business Recommendation
Champions and Loyal customers (17% of base) drive disproportionate order volume - protecting this segment is the single highest-ROI retention strategy. The 22,057 At-Risk customers with strong order histories but recent disengagement represent immediate re-engagement opportunity - a targeted discount or push notification campaign within 7 days could recover an estimated 30–40% of this segment before they move to Lost. The 35,364 Lost customers (17.1%) should receive a win-back campaign with a significantly higher incentive given their demonstrated historical value. Do not allocate equal marketing budget across segments — concentrate 60% of retention spend on At-Risk and Cannot-Lose-Them segments for maximum ROI

# DAX Measures Built
Total Customers, Champion Count, Champion %, At Risk Count, Lost Count, Cannot Lose Count, Churn Risk %, Avg Order Frequency, Avg Days Since Last Order, Avg Days Between Orders,Retained Customer %

# Python EDA Charts
Segment distribution bar - Lost is largest segment - retention problem visible
Order frequency histogram - Right-skewed — few heavy users pull mean above median
Recency boxplot by segment - At Risk has high recency despite good history
Department reorder rates - Staples departments drive repeat purchases
RFM heatmap - Champions dark across all metrics - confirms segmentation

# Skills Demonstrated
SQL, SSMS, NTILE, Window Function, CTEs, Multi-table JOINs, Python, Pandas, Seaborn, RFM Analysis, Customer Segmentation, Power BI, DAX, Power Query, Product Analytics, Retention Analysis
