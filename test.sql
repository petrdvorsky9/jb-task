-- 0 Drop Tables
/*
  Prevents data duplicity
  'GO' operator is not a part of SQL query, but directive for query execution in SSMS and other SQL Server tools
*/
DROP TABLE IF EXISTS dbfive.dbo.MATCH;
GO
DROP TABLE IF EXISTS dbfive.dbo.NS;
DROP TABLE IF EXISTS dbfive.dbo.PAYMENT;
GO