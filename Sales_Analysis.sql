
WITH new_table AS (
    SELECT
        YEAR(f.order_date) AS years,
        d.product_name,
        SUM(f.sales_amount) AS Total_Sales
    FROM sales AS f
    LEFT JOIN products AS d
        ON f.product_key = d.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        d.product_name
),

sales_analysis AS (
    SELECT
        years,
        product_name,
        Total_Sales,

        AVG(Total_Sales) OVER (
            PARTITION BY product_name
        ) AS Avg_Sales,

        LAG(Total_Sales) OVER (
            PARTITION BY product_name
            ORDER BY years
        ) AS Previous_Year_Sales

    FROM new_table
)

SELECT
    years,
    product_name,
    Total_Sales,
    Avg_Sales,

    CASE
        WHEN Total_Sales > Avg_Sales THEN 'Above AVG'
        WHEN Total_Sales < Avg_Sales THEN 'Below AVG'
        ELSE 'In Range'
    END AS Sales_Status,

    Previous_Year_Sales,

    CASE
        WHEN Previous_Year_Sales IS NULL THEN 'FIRST YEAR'
        WHEN Total_Sales > Previous_Year_Sales THEN 'INCREASE'
        WHEN Total_Sales < Previous_Year_Sales THEN 'DECREASE'
        ELSE 'NO CHANGE'
    END AS YEARLY_PROGRESS

FROM sales_analysis
ORDER BY product_name, years;
