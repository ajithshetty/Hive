# Hive Metadata Extractor

1.	Overview

Hive metadata is stored outside Hadoop environment in relation databases like MYSQL or default Derby database. Hive also provides commands like Show database, tables, describe commands etc. to retrieve the metadata. These commands only help retrieve details about only one table at time and impact analysis becomes cumbersome. 

The focus of this tool was to help extract all the metadata from Hive at once for easier impact analysis. It supports options to filter the tables for which metadata is required. 

2.	Context

One of the leading retail clients was using Hadoop Hortonworks platform. One of the key usage of this environment was moving the ETL developed using Datastage to Hadoop platform primarily using Hive, Sqoop and Oozie technologies. 

Infosys was involved in migrating few of their ETL jobs to Hadoop environment. One of the key pre requisite was to migrate source tables to Hadoop prior to rebuilding the ETL. It was a must for development teams to ensure that source tables are not replicated in Hadoop environment and teams check all the existing database and tables before copying them over. 

Searching for a table or a column across all databases becomes very manual due to lack of access to Hive metastore (mysql, derby etc.) and also Hive commands work on a single table at a time. 

This tool addresses this gap by running the hive commands in a loop and parsing describe formatted output to build a set of metadata tables which are similar to metadata tables offered by relational databases.

3.	Use cases

This tool can be used for requirements related to 
1)	Searching for hive table or columns across databases
2)	Impact analysis of identifying all the tables with the impacted columns
3)	Offline metadata for documentation and analysis
4.	Pre-Requisites 

This tool creates a hive database called as “metamgr” and builds following 3 tables:
tabledtls 	> Stores owner, table, storage and partition properties about a table
columndtls 	> Stores table and columns details 
dummy 	    > Helper table used by the scripts

It is mandatory for the user to have enough access to create database and the tables if the tool is used as it is. Users can always modify the script to point to different database as required.


5.	Tool Details

The tool is composed of following scripts. High level details of the functionality are provided below:

a. HiveMetaExtractor.sh	Interface script to guide the users in choosing the options for extracting Hive Metadata
b. createSetupTbl.sh	Creates the metamgr database and above 3 tables if they are not present in your hive setup
c. createDBList.sh	Runs the Show databases command and stores in a file
d. createTblList.sh	Uses the file from the previous step and extracts all the tables for each database. The Format retrieved needs to be maintained for subsequent steps. Refer to sample
e. createTblDescribe.sh	Runs the describe command for each table in the file created by the previous step. 
f. parseTblDescribe.sh	Parses the describe command output to generate data for tabledtls and columndtls tables in metamgr database
g. loadMetaTbl.sh	Loads the data into Hive tables in metagmr database

Interface script provides following options.  Setup table script is run every time. Setup tables are created only if they are not present. 
Get List of databases 			> Runs createDBList.sh
Get list of tables across all databases 	>  Runs createTblList.sh
Get the table descriptions 		> Runs createTblDescribe.sh
Parse Describe and Load Meta Table	> Runs parseTblDescribe.sh and loadMetaTbl.sh

Output Information captured by the tool at table and column level are provided below for reference:


Metamgr.tabledtls

Table_name	string
Database_name	string
Owner	string
Location	string
Table_Type	string
Table_Parameters	map<string, string>
Partition_Columns	string
Serde_Library	string
Input_Format	string
Ouput_Format	string
Compressed	string
Num_Buckets	string
Bucket_Columns	string
Sort_Columns	string
Storage_Parameters	map<string, string>

Metamgr.columndtls

Database_name	string
Table_name	string
Column_name	string
Data_type	string


Note

•	Target table column sequence is based on assumption of order of data in describe command. Any change to that order will cause the data to be inaccurately placed. In such scenario target table has to be updated to reflect the changes

•	Output file has headers. Target table has skip header table property set. If users manually prepare the file or modify the output file, header row has to be retained to avoid missing the rows.
