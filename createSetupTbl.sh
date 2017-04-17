################################################
# Script to create metamgr.dummy table         #
# This table is used by rest of the scripts    #
# of this tool                                 #
# Similar to Oracle tab table                  #
################################################
showTBCommand="show tables in metamgr like 'dummy*';"
nohup hive -e "$showTBCommand" > tempDummy.txt

if [ `grep 'dummy' tempDummy.txt | wc -c` -le 0 ]; then
   nohup hive -f setupTables.hql
fi

rm tempDummy.txt
exit 0
