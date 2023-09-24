# JetBrains Data Engineering & Analysis Test Assignment

## Technologies & Software used
DBeaver used for SQL Server client
Python 3 used for transformation Settlement batch reports

## Task 1: Data quality – the difference between NetSuite ERP and payment gateway
Solution steps:
1. After downloading Settlement reports I built a Python script that vertically merge all the .csv files (except merged_settlements.csv) within a directory and saves them into one file called merged_settlements.csv. File merged_settlements.csv is excluded from the merging just to make the script more versatile.
   Same data are also stored into variable merged_data that is used in the row count check.
2. After merging files into one, it is necessary to check if all data were loaded into the output csv. So I used simple approach I called 'Row count check'. All the files are loaded into one dictionary and count all the rows accross all files. Then simple if-else clause is used to compare count of all rows from dictionary with mentioned merged_data. Loading all settlement files to one dictionary can also be used to do checksums. I did checksums in the initial part of analysis in SQL.
3. When Row count check went OK, I loaded the merged file into table 'Settlement' in SQL server manually. I also tried to load merged data to SQL Server via Python script, but I wasn't 100% sure it works well so I decided to do it manually. In my honest opinion, for one-off analyses it can save time than building a script from scratch. If this task should be done regularly, a script or automation will be needed. Therefore the 'MS SQL Server connection and Load' section is fully commented. I understand it shouldn't be like that in real world but I think for test assignments it is good to show I can think about the task more broadly.



## Task 2: Sale analysis – revenue decline in ROW region

1. First of all I ran the attached query to see what was reported.
2. Then I ran "SELECT TOP(10) * FROM..." queries for every single table used in the original query to see what dimensions I can use to investigate revenue decline.
3. After that I started with adding more dimensions which could give me more insights in further analysis.
    I added following dimensions country code (iso), product_family, product name, price, month (extracted from exec_date), year (extracted from exec_date)
4. I started with building a report in Google Sheets but none of these dimensions offered any useful insight to make a bulletproof conclusion. So I decided to create another dimension derived from _SalesUsd2018H1_ and _SalesUsd2019H1_. I calculated Sales in their original currencies - in SQL they are called Sales2018H1 and Sales2019H1. In the report, they are called _SUM of sales 2018H1_ CUR and _SUM of sales 2019H1 CUR_ (I chose different metrics names because queries are mainly for analysts but the report is primarily for the Sales team or the Regional manager and it is necessary to name the metrics in a way that makes sense to them).
5. Before loading data to the report I created a query with data aggregated on the country level and also filtered on region = ROW and for H1 of 2018 and 2019. I found out meanwhile Sales calculated in USD declined by more than 3M USD, In original currencies the Sales numbers are slightly higher in more than half of ROW countries in YoY perspective.
6. To back up my claim, I calculated the following metrics: Count of unique orders in 2018H1, Count of unique orders in 2019H1, AOV 2018H1, AOV2019H1, YoY Sales differences in absolute numbers and in percantage.
7. Then I loaded new data (with Sales in original currencies) into the Google Sheets and built a report for ROW Regional manager.
   Link to the report - https://docs.google.com/spreadsheets/d/1-FjZ9-o-kQuEVCivIGKavUeA2DhFwQamJK1RoSMJvFA/edit?usp=sharing
