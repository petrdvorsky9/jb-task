/* Detailed data */
SELECT 
	*,
	SalesUSD2019H1 - SalesUSD2018H1 as diffUSD,
	SalesCUR2019H1 - SalesCUR2018H1 as diffCUR
FROM (
	SELECT
	month,
	region,
	iso,
	name,
	product_family,
	price,
	ROUND(SUM(SalesUSD2018H1), 2) as SalesUSD2018H1,
	ROUND(SUM(SalesUSD2019H1), 2) as SalesUSD2019H1,
	ROUND(SUM(SalesCUR2018H1), 2) as SalesCUR2018H1,
	ROUND(SUM(SalesCUR2019H1), 2) as SalesCUR2019H1
	FROM (
		SELECT 
			FORMAT(CONVERT(DATE, ord.exec_date, 120), 'MM') as month,
			YEAR(ord.exec_date) as Year,
			cou.region,
			cou.iso,
			prod.name,
			prod.product_family,
			prod.price,
		  	SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as SalesUSD2018H1,
		  	SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as SalesUSD2019H1,
		  	SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total ELSE 0.00 END) as SalesCUR2018H1,
			SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total ELSE 0.00 END) as SalesCUR2019H1
		FROM dea.sales.Orders ord
			JOIN dea.sales.OrderItems ordItm ON ord.id = ordItm.order_id
			JOIN dea.sales.Customer cust ON ord.customer = cust.id
			JOIN dea.sales.Country cou ON cust.country_id = cou.id
			JOIN dea.sales.ExchangeRate exRate ON ord.exec_date = exRate.date AND ord.currency = exRate.currency
			JOIN dea.sales.Product prod ON ordItm.product_id = prod.product_id
		WHERE ord.is_paid = 1 -- Only paid orders, exclude pre-orders
		  AND YEAR(ord.exec_date) IN (2018, 2019) -- Year 2018, 2019
		  AND MONTH(ord.exec_date) BETWEEN 1 AND 6 -- H1
		GROUP BY cou.region, ord.exec_date, cou.iso, prod.name, prod.product_family, prod.price
) a
	GROUP BY 
	month,
	region,
	iso,
	name,
	product_family,
	price
)b

--

/* Aggregated data USD*/
SELECT cou.iso,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as SalesUsd2018H1,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as SalesUsd2019H1,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) - SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as diff,
  1 - SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) / SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as ratio
FROM dea.sales.Orders ord
JOIN dea.sales.OrderItems ordItm ON ord.id = ordItm.order_id
JOIN dea.sales.Customer cust ON ord.customer = cust.id
JOIN dea.sales.Country cou ON cust.country_id = cou.id
JOIN dea.sales.ExchangeRate exRate ON ord.exec_date = exRate.date AND ord.currency = exRate.currency
JOIN dea.sales.Product prod ON ordItm.product_id = prod.product_id
WHERE ord.is_paid = 1 -- Only paid orders, exclude pre-orders
  AND YEAR(ord.exec_date) IN (2018, 2019) -- Year 2018, 2019
  AND MONTH(ord.exec_date) BETWEEN 1 AND 6 -- H1
  AND cou.region = 'ROW'
GROUP BY cou.iso
ORDER BY ratio desc
;

/* FX rate */
-- AVG 2018H1 = 0.826132
-- AVG 2019H1 = 0.8852
select 
	AVG(rate)
from dea.sales.ExchangeRate
where currency = 'EUR'
	and month(date) in (1,2,3,4,5,6)
	and year(date) = 2018
	
select 
	AVG(rate)
from dea.sales.ExchangeRate
where currency = 'EUR'
	and month(date) in (1,2,3,4,5,6)
	and year(date) = 2019
	

/* Aggregated data original curr*/
SELECT cou.iso,
  COUNT(DISTINCT(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ord.id ELSE '0' END) ) as orders2018,
  COUNT(DISTINCT(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ord.id ELSE '0' END) ) as orders2019,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total ELSE 0.00 END) / COUNT(DISTINCT(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ord.id ELSE '0' END) ) as AVGorders2018,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total ELSE 0.00 END) / COUNT(DISTINCT(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ord.id ELSE '0' END) ) as AVGorders2019,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total ELSE 0.00 END) as Sales2018H1,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total ELSE 0.00 END) as Sales2019H1,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as SalesUsd2018H1,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as SalesUsd2019H1,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total ELSE 0.00 END) - SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total ELSE 0.00 END) as diffCUR,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) - SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as diffUSD,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total ELSE 0.00 END) / SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total ELSE 0.00 END) as YoYratioCUR,
  SUM(CASE WHEN YEAR(ord.exec_date) = 2019 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) / SUM(CASE WHEN YEAR(ord.exec_date) = 2018 THEN ordItm.amount_total / exRate.rate ELSE 0.00 END) as YoYratioUSD
FROM dea.sales.Orders ord
JOIN dea.sales.OrderItems ordItm ON ord.id = ordItm.order_id
JOIN dea.sales.Customer cust ON ord.customer = cust.id
JOIN dea.sales.Country cou ON cust.country_id = cou.id
JOIN dea.sales.ExchangeRate exRate ON ord.exec_date = exRate.date AND ord.currency = exRate.currency
JOIN dea.sales.Product prod ON ordItm.product_id = prod.product_id
WHERE ord.is_paid = 1 -- Only paid orders, exclude pre-orders
  AND YEAR(ord.exec_date) IN (2018, 2019) -- Year 2018, 2019
  AND MONTH(ord.exec_date) BETWEEN 1 AND 6 -- H1
  AND cou.region = 'ROW'
--  AND cou.iso = 'DE'
GROUP BY cou.iso
ORDER BY YoYratioCUR desc
