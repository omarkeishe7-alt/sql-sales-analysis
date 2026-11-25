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
)

SELECT
    years,
    product_name,
    Total_Sales,

    AVG(Total_Sales) OVER (
        PARTITION BY product_name
    ) AS Avg_Sales,

    CASE
        WHEN Total_Sales - AVG(Total_Sales) OVER (
            PARTITION BY product_name
        ) > 0 THEN 'Above AVG'

        WHEN Total_Sales - AVG(Total_Sales) OVER (
            PARTITION BY product_name
        ) < 0 THEN 'Below AVG'

        WHEN Total_Sales - AVG(Total_Sales) OVER (
            PARTITION BY product_name
        ) = 0 THEN 'In Range'
    END AS Sales_Status,

    LAG(Total_Sales) OVER (
        PARTITION BY product_name
        ORDER BY years
    ) AS Yearly_Sales,

    CASE
        WHEN Total_Sales - LAG(Total_Sales) OVER (
            PARTITION BY product_name
            ORDER BY years
        ) > 0 THEN 'INCREASE'

        WHEN Total_Sales - LAG(Total_Sales) OVER (
            PARTITION BY product_name
            ORDER BY years
        ) < 0 THEN 'DECREASE'

        ELSE 'NO CHANGE'
    END AS YEARLY_PROGRESS

FROM new_table;