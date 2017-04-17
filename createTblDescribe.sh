######################################################
# Script to extract table properties from Hive       #
# Input file format expected is                      #
# database ==> Database                              #
# tablename                                          #
# database ==> Database                              #
# uses describe command and flattens it to a row     #
######################################################
noOfArgs=$#
tblFileName=$1

if [ $noOfArgs -ne 1 ]; then
   echo "Insufficient number of arguments. Exiting... "
   exit 1
fi

if [ ! -f $tblFileName ]; then
   echo "File does not exist. Exiting... "
   exit 1
fi

###############
# Build describe strings
###############
completeStmt=''
while read record
do
    rc=`echo $record | grep 'Database' | wc -c`
    if [ $rc -gt 0 ]; then
       currentDBName=`echo $record | cut -d':' -f1 | tr -d ' '`
       continue
    fi
    completeStmt+="!echo ==========; !echo describe table "$currentDBName"."$record";"$'\n'"describe formatted "$currentDBName"."$record";"$'\n'
done < $tblFileName


echo "$completeStmt" > hqlTblDescribe.hql
################
# Run describe commands and remove hive logs
################
nohup  hive -hiveconf hive.cli.errors.ignore=true -f hqlTblDescribe.hql > hiveTblDescribe.txt

if [ $? -ne 0 ]; then
   echo "Describe commands failed. Check hiveDescribe.txt file "
   exit 1
fi

###############
# File cleanup to remove unwanted text
###############
sed -i -e '/^OK/d; /^Time taken/d; /^Logging/d; /^[[:space:]]*$/d' hiveTblDescribe.txt

if [ $? -ne 0 ]; then
   echo "Failed processing Describe file hiveTblDescribe.txt"
   exit 1
fi

echo '=========' >> hiveTblDescribe.txt
exit 0

