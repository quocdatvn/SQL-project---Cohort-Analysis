--COHORT ANALYSIS--

-- Data set: Paytm
-- Description about data: Paytm is an Indian multinational financial technology company. It specializes in digital payment system, e-commerce and financial services. Paytm wallet is a secure and RBI (Reserve Bank of India)-approved digital/mobile wallet that provides a myriad of financial features to fulfill every consumer’s payment needs. Paytm wallet can be topped up through UPI (Unified Payments Interface), internet banking, or credit/debit cards. Users can also transfer money from a Paytm wallet to recipient’s bank account or their own Paytm wallet. -- 
-- Below is a small database of payment transactions from 2019 to 2020 of Paytm Wallet. The database includes 6 tables:
-- fact_transaction: Store information of all types of transactions: Payments, Top-up, Transfers, Withdrawals--
-- dim_scenario: Detailed description of transaction types
-- dim_payment_channel: Detailed description of payment methods
-- dim_platform: Detailed description of payment devices
-- dim_status: Detailed description of the results of the transaction

-- Link download dataset: https://drive.google.com/drive/folders/1zLCSSH4vpw-xVsHXKNJFGniCsJ4M1xjT?usp=sharing

---Task: 
--One of the most common types of cohort analysis is retention analysis. To retain is to keep or continue something. Many skills need to be practiced to be retained. Businesses usually want their customers to keep purchasing their products or using their services, since retaining customers is more profitable than acquiring new ones. Employers want to retain their employees, because recruiting replacements is expensive and time consuming.

-- As you know that 'Telco Card' is the most product in the Telco group (accounting for more than 99% of the total). You want to evaluate the quality of user acquisition for period from Jan 2019 to Dec 2020 by the retention metric:  retention  =  number of retained customers / total users of the first month. 
WITH period_table AS (
SELECT customer_id, transaction_id, transaction_time
    , MIN(MONTH( transaction_time)) OVER( PARTITION BY customer_id) AS first_month
    , DATEDIFF(month, MIN(transaction_time) OVER( PARTITION BY customer_id), transaction_time) AS subsequent_month
FROM fact_transaction_2019 fact 
JOIN dim_scenario sce ON fact.scenario_id = sce.scenario_id
WHERE sub_category = 'Telco Card' AND status_id = 1
)
, retained_user AS (
SELECT first_month AS acquisition_month
    , subsequent_month
    , COUNT( DISTINCT customer_id) AS retained_users
FROM period_table
GROUP BY first_month , subsequent_month
-- ORDER BY acquisition_month, subsequent_month
)
SELECT *
    , FIRST_VALUE(retained_users) OVER( PARTITION BY acquisition_month ORDER BY subsequent_month) AS original_users
    , FORMAT(1.0*retained_users/FIRST_VALUE(retained_users) OVER( PARTITION BY acquisition_month ORDER BY subsequent_month), 'p') AS pct_retained_users
INTO #retention_month -- local table
FROM retained_user

SELECT * FROM #retention_month

-- DROP TABLE #retention_month
-- 1.2 B Pivot table 

SELECT acquisition_month
    , original_users
    , "0", "1", "2", "3","4", "5", "6", "7","8", "9", "10", "11"
FROM (
    SELECT acquisition_month, subsequent_month, original_users,  pct_retained_users
    FROM #retention_month
) AS source_table 
PIVOT ( -- MIN, MAX, AVG, SUM, COUNT
    MIN(pct_retained_users)
    FOR subsequent_month IN ("0", "1", "2", "3","4", "5", "6", "7","8", "9", "10", "11")
) pivot_table
ORDER BY acquisition_month





