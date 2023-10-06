-- 0 Drop Tables
DROP TABLE IF EXISTS dbfive.dbo.MATCH;
GO
DROP TABLE IF EXISTS dbfive.dbo.NS;
DROP TABLE IF EXISTS dbfive.dbo.PAYMENT;
GO

-- 1 Load NetSuite Data
DROP TABLE IF EXISTS dbfive.dbo.NS;
GO
SELECT tra.TRANSACTION_ID,
  tra.TRANID,
  tra.ORDER_REF,
  CASE WHEN tra.TRANSACTION_TYPE = 'Payment' THEN 'Settled' WHEN tra.TRANSACTION_TYPE = 'Customer Deposit' THEN 'Refund' ELSE 'Unknown' END as TRANSACTION_TYPE,
  tra.TRANDATE,
  tra.MERCHANT_ACCOUNT,
  tra.BATCH_NUMBER,
  CASE WHEN acc.ACCOUNTNUMBER = '548201' THEN 1 ELSE 0 END as IS_FEE, -- NetSuite splits settlement data into two transactions - net and fee amount
  traLine.AMOUNT_FOREIGN as AMOUNT,
  cur.SYMBOL as CURRENCY,
  acc.ACCOUNTNUMBER
INTO dbfive.dbo.NS
FROM dea.netsuite.TRANSACTIONS tra
JOIN dea.netsuite.TRANSACTION_LINES traLine ON tra.TRANSACTION_ID = traLine.TRANSACTION_ID
JOIN dea.netsuite.ACCOUNTS acc ON traLine.ACCOUNT_ID = acc.ACCOUNT_ID
JOIN dea.netsuite.CURRENCIES cur ON tra.CURRENCY_ID = cur.CURRENCY_ID
WHERE acc.ACCOUNT_ID IN (SELECT ACCOUNT_ID FROM dea.netsuite.ACCOUNTS WHERE ACCOUNTNUMBER IN ('315700', '315710', '315720', '315800', '548201'))
;
GO
ALTER TABLE dbfive.dbo.NS ADD PRIMARY KEY (TRANSACTION_ID);
GO

-- 2 Load Payment Data
-- 2.1 Create Table
DROP TABLE IF EXISTS dbfive.dbo.PAYMENT;
CREATE TABLE dbfive.dbo.PAYMENT
(
	PAYMENT_ID int identity(1,1) primary key,
	ORDER_REF varchar(11) not null,
	TRANSACTION_TYPE varchar(7) not null,
	TRANDATE date not null,
	MERCHANT_ACCOUNT varchar(20),
	BATCH_NUMBER int,
	IS_FEE smallint,
	AMOUNT decimal(38,2),
	CURRENCY varchar(4)
)
;

-- 2.2 Insert Data
-- Source table CSV_PAYMENT was loaded by Python pandas
-- Net amounts
INSERT INTO dbfive.dbo.PAYMENT (ORDER_REF, TRANSACTION_TYPE, TRANDATE, MERCHANT_ACCOUNT, BATCH_NUMBER, IS_FEE, AMOUNT, CURRENCY)
SELECT ORDER_REF,
  TYPE as TRANSACTION_TYPE,
  DATE as TRANDATE,
  MERCHANT_ACCOUNT,
  BATCH_NUMBER,
  0 as IS_FEE,
  NET as AMOUNT,
  CURRENCY
FROM dbfive.dbo.Settlement
;
-- Fee amounts
INSERT INTO dbfive.dbo.PAYMENT (ORDER_REF, TRANSACTION_TYPE, TRANDATE, MERCHANT_ACCOUNT, BATCH_NUMBER, IS_FEE, AMOUNT, CURRENCY)
SELECT ORDER_REF,
  TYPE as TRANSACTION_TYPE,
  DATE as TRANDATE,
  MERCHANT_ACCOUNT,
  BATCH_NUMBER,
  1 as IS_FEE,
  FEE as AMOUNT,
  CURRENCY
FROM dbfive.dbo.Settlement
;
GO

-- 3 Match
-- 3.1 Create matching table
DROP TABLE IF EXISTS dbfive.dbo.MATCH;
CREATE TABLE dbfive.dbo.MATCH
(
  TRANSACTION_ID INT NOT NULL PRIMARY KEY,
  PAYMENT_ID INT NOT NULL UNIQUE,
  MATCH_METHOD VARCHAR(50) NOT NULL, -- might be useful for debugging
  FOREIGN KEY (TRANSACTION_ID) REFERENCES dbfive.dbo.NS(TRANSACTION_ID),
  FOREIGN KEY (PAYMENT_ID) REFERENCES dbfive.dbo.PAYMENT(PAYMENT_ID)
);

-- 3.2 Match data
INSERT INTO dbfive.dbo.MATCH
SELECT ns.TRANSACTION_ID,
  pay.PAYMENT_ID,
  'Direct Match' as MATCH_METHOD
FROM dbfive.dbo.NS ns
JOIN dbfive.dbo.PAYMENT pay ON ns.ORDER_REF = pay.ORDER_REF AND ns.IS_FEE = pay.IS_FEE AND ns.TRANSACTION_TYPE = pay.TRANSACTION_TYPE
;
GO

-- 4 Results
-- 4.1 Results - Excess
SELECT *
FROM dbfive.dbo.NS
WHERE TRANSACTION_ID NOT IN (SELECT TRANSACTION_ID FROM dbfive.dbo.MATCH)
;

-- 4.2 Results - Missing
SELECT *
FROM dbfive.dbo.PAYMENT
WHERE PAYMENT_ID NOT IN (SELECT PAYMENT_ID FROM dbfive.dbo.MATCH)
;

-- 4.3 Results - Difference
SELECT *
FROM
(
    SELECT ns.ORDER_REF,
      ns.IS_FEE,
      ns.TRANSACTION_TYPE,
      ns.TRANDATE as TRANDATE_NS,
      pay.TRANDATE as TRANDATE_PAY,
      ns.AMOUNT as AMOUNT_NS,
      pay.AMOUNT as AMOUNT_PAY,
      ns.CURRENCY as CURRENCY_NS,
      pay.CURRENCY as CURRENCY_PAY,
      ns.MERCHANT_ACCOUNT as MERCHANT_ACCOUNT_NS,
      pay.MERCHANT_ACCOUNT as MERCHANT_ACCOUNT_PAY,
      ns.BATCH_NUMBER as BATCH_NUMBER_NS,
      pay.BATCH_NUMBER as BATCH_NUMBER_PAY,
       CONCAT(
            CASE WHEN ISNULL(pay.TRANDATE, '2999-01-01') <> ISNULL(ns.TRANDATE, '2998-01-01') THEN 'TRANDATE;' ELSE '' END,
            CASE WHEN ISNULL(pay.CURRENCY, '-1') <> ISNULL(ns.CURRENCY, '-2') THEN 'CURRENCY;' ELSE '' END,
            CASE WHEN ISNULL(pay.MERCHANT_ACCOUNT, '') <> ISNULL(ns.MERCHANT_ACCOUNT, '') THEN 'MERCHANT_ACCOUNT;' ELSE '' END,
            CASE WHEN ISNULL(pay.BATCH_NUMBER, -1) <> ISNULL(ns.BATCH_NUMBER, -2) THEN 'BATCH_NUMBER;' ELSE '' END,
            CASE WHEN ISNULL(pay.AMOUNT, -999.98) <> ISNULL(ns.AMOUNT, -999.99) THEN 'AMOUNT;' ELSE '' END
      ) as DIFFERENCE
    FROM dbfive.dbo.NS ns
    JOIN dbfive.dbo.MATCH m ON ns.TRANSACTION_ID = m.TRANSACTION_ID
    JOIN dbfive.dbo.PAYMENT pay ON m.PAYMENT_ID = pay.PAYMENT_ID
) as main
WHERE   DIFFERENCE <> ''
;