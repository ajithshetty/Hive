####################################################
# Utility to extract list of tables for a database #
# Input is a file with list of databases           #
# output is written to hiveTblList.txt             #
# in the current working directory                 #
# Tool uses metaDummy table in hive                #
####################################################
noOfArgs=$#
dbFileName=$1

if [ $noOfArgs -ne 1 ]; then
   echo "Insufficient number of arguments. Exiting... "
   exit 1
fi

if [ ! -f $dbFileName ]; then
   echo "File does not exist. Exiting... "
   exit 1
fi

##########
# Building the hive execution string to avoid multiple hive sessions
##########

selectStmt="!echo "
fromStmt=":Database"
completeStmt=''
while read dbName
do
    completeStmt+=$selectStmt${dbName}$fromStmt";"$'\n'"show tables in "$dbName";"$'\n'
done < $dbFileName

echo "$completeStmt" > hqlTblList.hql
##########
# Executing contactenated hive commands
##########
nohup hive -f hqlTblList.hql > hiveTblList.txt

if [ $? -ne 0 ]; then
   echo "Hive command execution to get table list failed "
   exit 1
fi

##########
# Removing hive logs from file
##########
sed -i -e '/^OK/d; /^Time taken/d; /^Logging/d; /^[[:space:]]*$/d' hiveTblList.txt
if [ $? -ne 0 ]; then
   echo "Parsing table extract failed "
   exit 1
fi

exit 0

