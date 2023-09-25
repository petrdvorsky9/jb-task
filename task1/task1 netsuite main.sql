/* Task1 Netsuite main */
--SELECT
--	SUM(AMOUNT_FOREIGN)
----	* 
--FROM dea.netsuite.TRANSACTIONS t
--LEFT JOIN dea.netsuite.TRANSACTION_LINES tl ON t.TRANSACTION_ID = tl.TRANSACTION_ID
--LEFT JOIN dea.netsuite.ENTITY ent ON tl.COMPANY_ID = ent.ENTITY_ID
--LEFT JOIN dea.netsuite.SUBSIDIARIES sub ON tl.SUBSIDIARY_ID = sub.SUBSIDIARY_ID
--LEFT JOIN dea.netsuite.CURRENCIES cur ON t.CURRENCY_ID  = cur.CURRENCY_ID
--LEFT JOIN dea.netsuite.ACCOUNTS acc ON tl.ACCOUNT_ID = acc.ACCOUNT_ID
--WHERE 
--	t.BATCH_NUMBER = 139
--	AND acc.ACCOUNTNUMBER IN (315720, 548201)
--	AND cur.SYMBOL = 'GBP'
--	AND tl.AMOUNT_FOREIGN >= 0
--	AND t.TRANSACTION_TYPE IN ('Customer Deposit', 'Payment')
--	AND tl.TRANSACTION_LINE_ID = 1
--	
--
--select * from dea.netsuite.TRANSACTIONS	
--select * from dea.netsuite.TRANSACTION_LINES
--select * from dea.netsuite.TRANSACTIONS
--select * from dea.netsuite.SUBSIDIARIES
--select * from dea.netsuite.CURRENCIES
--select * from dea.netsuite.ACCOUNTS
--select * from dea.netsuite.ENTITY



--

SELECT
	x.ACCOUNTNUMBER,
	x.NAME,
	x.BATCH_NUMBER,
	x.SYMBOL,
	SUM(AMOUNT_TOTAL_FOREIGN) AS AMOUNT_TOTAL_FOREIGN
FROM (
	SELECT
		b.ACCOUNTNUMBER,
		b.NAME,
		b.BATCH_NUMBER,
		b.SYMBOL,
		SUM(b.AMOUNT_TOTAL_FOREIGN) AS AMOUNT_TOTAL_FOREIGN
	FROM (
		SELECT 
			a.ACCOUNTNUMBER,
			a.NAME,	
			t.BATCH_NUMBER,
			e.BILL_COUNTRY,
			c.SYMBOL,
			SUM(tl.AMOUNT_FOREIGN) AS AMOUNT_TOTAL_FOREIGN
		FROM dea.netsuite.TRANSACTION_LINES tl
		LEFT JOIN dea.netsuite.SUBSIDIARIES sub ON tl.SUBSIDIARY_ID = sub.SUBSIDIARY_ID
		LEFT JOIN dea.netsuite.ACCOUNTS a ON tl.ACCOUNT_ID = a.ACCOUNT_ID
		LEFT JOIN dea.netsuite.TRANSACTIONS t ON tl.TRANSACTION_ID = t.TRANSACTION_ID
		LEFT JOIN dea.netsuite.ENTITY e ON tl.COMPANY_ID = e.ENTITY_ID
		LEFT JOIN dea.netsuite.CURRENCIES c ON t.CURRENCY_ID = c.CURRENCY_ID
		GROUP BY
			a.ACCOUNTNUMBER,
			a.NAME,	
			t.BATCH_NUMBER,
			e.BILL_COUNTRY,
			c.SYMBOL
	) b
	WHERE 
		b.AMOUNT_TOTAL_FOREIGN > 0
		AND b.SYMBOL IN ('GBP', 'EUR')
	GROUP BY
		b.ACCOUNTNUMBER,
		b.NAME,	
		b.BATCH_NUMBER,
		b.SYMBOL
) x
	GROUP BY
		x.ACCOUNTNUMBER,
		x.NAME,
		x.BATCH_NUMBER,
		x.SYMBOL
--
		

		
-- nejnovejsi idea
WITH netsuite AS (
	SELECT
		t.ORDER_REF
	FROM dea.netsuite.TRANSACTION_LINES tl
	LEFT JOIN dea.netsuite.TRANSACTIONS t ON tl.TRANSACTION_ID = t.TRANSACTION_ID
),

settlements AS (
	SELECT 
		ORDER_REF
	FROM dbfive.dbo.Settlement
)

SELECT 
	* 
FROM settlements s
INNER JOIN netsuite n ON s.ORDER_REF = n.ORDER_REF
		
		
		
		
		