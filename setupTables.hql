create database if not exists metamgr;
use metamgr;
create table if not exists dummy (dummy string) row format delimited fields terminated by ',';
load data local inpath 'dummyRow.txt' overwrite into table metamgr.dummy;

create table if not exists metamgr.tabledtls (
Table_name string,
Database_name string,
Owner string,
Location string,
Table_Type string,
Table_Parameters map<string, string>,
Partition_Columns string,
Serde_Library string,
Input_Format string,
Ouput_Format string,
Compressed string,
Num_Buckets string,
Bucket_Columns string,
Sort_Columns string,
Storage_Parameters map<string, string>)
row format delimited fields terminated by '@'
collection items terminated by '|'
map keys terminated by ':'
tblproperties ("skip.header.line.count"="1");

create table if not exists metamgr.columndtls (
Database_name string,
Table_name string,
column_name string,
data_type string)
row format delimited fields terminated by '@'
tblproperties ("skip.header.line.count"="1");
