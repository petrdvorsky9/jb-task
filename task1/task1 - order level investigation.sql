/* USD AMERICAS ORDER DETAIL INVESTIGATION  | SEARCHING COMMON DIMENSIONS */

-- Getting the list of unique ORDER_REFs from Settlement table
SELECT 
	DISTINCT ORDER_REF
FROM dbfive.dbo.Settlement
WHERE 
	MERCHANT_ACCOUNT = 'JetBrainsAmericasUSD'
	AND BATCH_NUMBER = 138

-- Investigating sample of orders from previous query to find common attributes
SELECT
	*
FROM dea.netsuite.TRANSACTION_LINES tl
LEFT JOIN dea.netsuite.TRANSACTIONS t ON tl.TRANSACTION_ID = t.TRANSACTION_ID
LEFT JOIN dea.netsuite.SUBSIDIARIES sub ON tl.SUBSIDIARY_ID = sub.SUBSIDIARY_ID
LEFT JOIN dea.netsuite.ACCOUNTS a ON tl.ACCOUNT_ID = a.ACCOUNT_ID
LEFT JOIN dea.netsuite.ENTITY e ON tl.COMPANY_ID = e.ENTITY_ID
LEFT JOIN dea.netsuite.CURRENCIES c ON t.CURRENCY_ID = c.CURRENCY_ID
WHERE 
	t.TRANSACTION_TYPE IN ('Payment', 'Customer Deposit')
	AND t.ORDER_REF IN ('R000013255',
						'C000021905',
						'R000149248',
						'Z000145102',
						'C000072888',
						'E000024942',
						'E000113043',
						'C000056761',
						'Z000115068',
						'E000025365')