/* Create the list of all differences on transaction level between NetSuite and payment gateway along with all accounting relevant columns */
SELECT
	DISTINCT t.TRANSACTION_ID,
	d.ORDER_REF,
	t.TRANDATE,
	t.TRANSACTION_TYPE,
	t.BATCH_NUMBER,
	CASE 
		WHEN t.BATCH_NUMBER IS NULL THEN s.BATCH_NUMBER
		ELSE s.BATCH_NUMBER
	END AS NEW_BN,
	sub.TRAN_NUM_PREFIX,
	sub.NAME AS SUBSIDIARY_NAME,
	a.ACCOUNTNUMBER,
	IS_NON_POSTING,
	a.FULL_NAME,
	a.ISINACTIVE,
	a.IS_BALANCESHEET,
	a.IS_LEFTSIDE,
	a.IS_SUMMARY,
	a.TYPE_NAME,
	a.TYPE_SEQUENCE,
	e.ENTITY_ID,
	e.NAME,
	e.ENTITY_TYPE,
	e.BILL_COUNTRY,
	c.SYMBOL,
	s.PAYMENT_METHOD,
	s.TYPE,
	s.NET,
	s.FEE,
	s.GROSS,
	tl.AMOUNT AS NETSUITE_PRICE,
	tl.AMOUNT_FOREIGN AS NETSUITE_PRICE_FOREIGN,
	s.GROSS AS SETTLEMENTS_GROSS_PRICE
FROM dbfive.dbo.ns_sett_diff d
INNER JOIN dbfive.dbo.Settlement s ON s.ORDER_REF = d.ORDER_REF
INNER JOIN dea.netsuite.TRANSACTIONS t ON s.ORDER_REF = t.ORDER_REF
INNER JOIN dea.netsuite.TRANSACTION_LINES tl ON tl.TRANSACTION_ID = t.TRANSACTION_ID
INNER JOIN dea.netsuite.SUBSIDIARIES sub ON tl.SUBSIDIARY_ID = sub.SUBSIDIARY_ID
INNER JOIN dea.netsuite.ACCOUNTS a ON tl.ACCOUNT_ID = a.ACCOUNT_ID
INNER JOIN dea.netsuite.ENTITY e ON tl.COMPANY_ID = e.ENTITY_ID
INNER JOIN dea.netsuite.CURRENCIES c ON t.CURRENCY_ID = c.CURRENCY_ID