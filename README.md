# JetBrains Data Engineering & Analysis Test Assignment

## Technologies & Software used
- DBeaver used for SQL Server client
- Python 3 used for transformation Settlement batch reports
- Google Sheets used for data visualization

## Task 1: Data quality – the difference between NetSuite ERP and payment gateway
Solution steps:
1. After downloading Settlement reports I built a Python script ([settlement ETL.ipynb](https://github.com/petrdvorsky9/jb-task/blob/main/settlements/settlement%20ETL.ipynb)) that vertically merges all the .csv files (except merged_settlements.csv) within a directory and saves them into one file called merged_settlements.csv. File merged_settlements.csv is excluded from the merging just to make the script more versatile.
   The same data are also stored in the variable merged_data that is used in the row count check.
2. After merging files into one, it is necessary to check if all data were loaded into the output CSV. So I used a simple approach I called 'Row count check'. All the files are loaded into one dictionary and count all the rows accross all files. Then simple if-else clause is used to compare the count of all rows from dictionary with mentioned merged_data. Loading all settlement files to one dictionary can also be used to do checksums. I did checksums in the initial part of analysis in SQL.
3. When the Row count check went OK, I loaded the merged file into table 'Settlement' in SQL server manually (Table: _dbfive.dbo.Settlement_). I also tried to load merged data to SQL Server via Python script, but I wasn't 100% sure if it works well so I decided to do it manually. In my honest opinion, for one-off analyses it can save time than building a script from scratch. If this task should be done regularly, a script or automation will be needed. Therefore the 'MS SQL Server connection and Load' section is fully commented. I understand it shouldn't be like that in real world but I think for test assignments it is good to show I can think about the task more broadly.
4. After creation of the Settlement table, I Investigated Netsuite data (Aggregated data) and I was looking for the right filtration which will return same result as it is in table in task description. I compared aggregated data from Netsuite and Settlements reports to get correct numbers according to the task description. In the following queries are samples of my aggragated data insights for both Netsuite and Settlements reports [task1 settlements main.sql](https://github.com/petrdvorsky9/jb-task/blob/main/task1/task1%20settlements%20main.sql) , [task1 netsuite main.sql
](https://github.com/petrdvorsky9/jb-task/blob/main/task1/task1%20netsuite%20main.sql) . I admit, it was not easy without any knowledge of related business. I found the way how to correctly filter data and the sample of the aggregated queries can be seen in [task1 - Aggregated queries with correct filters.sql](https://github.com/petrdvorsky9/jb-task/blob/main/task1/task1%20-%20Aggregated%20queries%20with%20correct%20filters.sql)
5. The next step was to change the level of detail from aggregated data to order level. In the following script [task1 - List of ORDER_REF differences.sql
](https://github.com/petrdvorsky9/jb-task/blob/main/task1/task1%20-%20List%20of%20ORDER_REF%20differences.sql) you can find all partial queries tied together using WITH clause and merged together using UNION ALL and saved to separated table called _dbfive.dbo.netsuite_settlement_differences_. I admit that the creation of a new table just for the one-off task is not the ideal solution, but in this case, it could provide a higher speed of further work with the data. In this step I also added column FLAG which indicates whether the order is in Netsuite, Settlements reports or there are different prices.
6. Data are ready in the table _dbfive.dbo.netsuite_settlement_differences_ and can be queried.

Note: 
1. It is necessary to apply filters on the table _dbfive.dbo.netsuite_settlement_differences_ to get all the relevant data about a particular account but in my honest opinion it is more for further work with visualization tools (Tableau or PowerBI) that allow user to intuitively filter tha data and which can handle large data like this.
2. I found an error between Netsuite and Settlements where orders have different prices. In settlements were Net prices, in Netsuite were Gross prices. 


## Task 2: Sale analysis – revenue decline in ROW region

1. First of all I ran the attached query to see what was reported.
2. Then I ran "SELECT TOP(10) * FROM..." queries for every single table used in the original query to see what dimensions I could use to investigate revenue decline.
3. After that I started with adding more dimensions which could give me more insights in further analysis.
    I added the following dimensions country code (iso), product_family, product name, price, month (extracted from exec_date), year (extracted from exec_date)
4. I started with building a report in Google Sheets but none of these dimensions offered any useful insight to make a bulletproof conclusion. So I decided to create another dimension derived from _SalesUsd2018H1_ and _SalesUsd2019H1_. I calculated Sales in their original currencies - in SQL they are called Sales2018H1 and Sales2019H1. In the report, they are called _SUM of sales 2018H1_ CUR and _SUM of sales 2019H1 CUR_ (I chose different metrics names because queries are mainly for analysts but the report is primarily for the Sales team or the Regional manager and it is necessary to name the metrics in a way that makes sense to them).
5. Before loading data to the report I created a query with data aggregated on the country level and also filtered on region = ROW and for H1 of 2018 and 2019. I found out meanwhile Sales calculated in USD declined by more than 3M USD, In original currencies the Sales numbers are slightly higher in more than half of ROW countries in YoY perspective.
6. To back up my claim, I calculated the following metrics: Count of unique orders in 2018H1, Count of unique orders in 2019H1, AOV 2018H1, AOV2019H1, YoY Sales differences in absolute numbers and in percantage.
7. Then I loaded new data (with Sales in original currencies) into the Google Sheets and built a report for ROW Regional manager.
   Link to the report - https://docs.google.com/spreadsheets/d/1-FjZ9-o-kQuEVCivIGKavUeA2DhFwQamJK1RoSMJvFA/edit?usp=sharing

All the SQL queries are here: [task2 scripts.sql](https://github.com/petrdvorsky9/jb-task/blob/main/task2/task2%20scripts.sql)

Note:
If we look closer at the overall view in Google Sheets report, we can seehigher number of orders in 2019, slightly higher AOV in 2019, and higher sales in original currency in 2019 but USD sales are lower. I've investigated also _dea.sales.ExchangeRate_ table. In the file with queries is also basic investigation of exchange rate and it's change. I found out that the exchange rate declined YoY and therefore it seems that sales declined as well. But Sales declined only in USD. Actually, sales are slightly better YoY in the original currency. 
