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
Link to the report - https://docs.google.com/spreadsheets/d/1-FjZ9-o-kQuEVCivIGKavUeA2DhFwQamJK1RoSMJvFA/edit?usp=sharing
