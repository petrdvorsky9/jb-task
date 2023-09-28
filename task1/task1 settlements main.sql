--FUNGUJICI KOD PRO SETTLEMENTS
SELECT
	ACC_BATCH,
	SumSettlementGross
FROM (
	SELECT
		MERCHANT_ACCOUNT,
		BATCH_NUMBER,
		CONCAT(MERCHANT_ACCOUNT, '_', BATCH_NUMBER) AS ACC_BATCH,
		CASE 
			WHEN SUM(GROSS) IS NULL THEN 0
			ELSE SUM(GROSS)
		END as SumSettlementGross
	FROM dbfive.dbo.Settlement	
	GROUP BY 
		MERCHANT_ACCOUNT,	
		BATCH_NUMBER
	) a
WHERE
	ACC_BATCH IN ('JetBrainsAmericasUSD_', 'JetBrainsAmericasUSD_139', 'JetBrainsAmericasUSD_141', 'JetBrainsEUR_138', 'JetBrainsEUR_139', 'JetBrainsGBP_141')
