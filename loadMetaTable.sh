HiveTblMeta='HiveTblMeta.txt'
HiveColMeta='HiveColMeta.txt'


if [ ! -f $HiveTblMeta ]; then
   echo "File does not exist. Exiting..."
   exit 1
fi


if [ ! -f $HiveColMeta ]; then
   echo "File does not exist. Exiting..."
   exit 1
fi

nohup hive -e "set skip.header.line.count=1; load data local inpath '$HiveTblMeta' overwrite into table metamgr.tabledtls;"
nohup hive -e "set skip.header.line.count=1; load data local inpath '$HiveColMeta' overwrite into table metamgr.columndtls;"

