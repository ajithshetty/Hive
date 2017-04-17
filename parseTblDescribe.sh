#######################################
# Script to parse describe table text #
# processes the file line by line     #
#######################################
noOfArgs=$#
descFileName=$1

if [ $noOfArgs -ne 1 ]; then
   echo "Insufficient arguments. Exiting..."
   exit 1
fi

if [ ! -f $descFileName ]; then
   echo "File does not exist. Exiting..."
   exit 1
fi

#######################################
# Intialization statements            #
#######################################
tblMetaData=''
colMetaData=''
strMetaInfo=''
partMetaInfo=''
HiveTblMeta='HiveTblMeta.txt'
HiveColMeta='HiveColMeta.txt'
echo "Table_name@Database@Owner@Location@Table_Type@Table_Parameters@Partition_Columns@Serde_Library@Input_Format@Ouput_Format@Compressed@Num_Buckets@Bucket_Columns@Sort_Columns@Storage_Parameters">$HiveTblMeta
echo "Database@Table_Name@Column_Name@Data_Type">$HiveColMeta
sed -i -e '/^[[:space:]]*$/d' $descFileName


#######################################
# Data availability flags             #
#######################################
tblLocation=''
tblOwner=''
tblType=''
tblPartition=''
tblParams=''
strSerde=''
strInput=''
strOutput=''
strCompress=''
strNumBuckets=''
strBucketCols=''
strSortCols=''
strParams=''

#######################################
# Reading file line by line           #
# Maintain flag of current section in #
# the file and process the records    #
#######################################
while read record
do
    if [ "`echo $record | cut -c-4`" == "====" ]; then
         tblMetaData=$tblName'@'$dbName'@'$tblOwner'@'$tblLocation'@'$tblType'@'$tblParams'@'$tblPartition'@'
         tblMetaData=$tblMetaData$strSerde'@'$strInput'@'$strOutput'@'$strCompress'@'$strNumBuckets'@'$strBucketCols'@'$strSortCols'@'$strParams
         echo "$tblMetaData" >> $HiveTblMeta
         echo "$colMetaData" >> $HiveColMeta
         colMetaData=''
         tblPartition=''
         tblParams=''
         tblParamFlag=''
         strParams=''
         strParamFlag=''
    fi

#######
# Setting up the section flag
#######

    if [ `echo $record | grep '# col_name' | wc -c` -gt 0  -a "$sectionFlag" != 'partition' -a "$sectionFlag" != 'table' ]; then
       sectionFlag='column'
       continue
    elif [ `echo $record | grep '# Partition' | wc -c` -gt 0 ]; then
       sectionFlag='partition'
       continue
    elif [ `echo $record | grep '# Detailed Table' | wc -c` -gt 0 ]; then
       sectionFlag='table'
       continue
    elif [ `echo $record | grep '# Storage Information' | wc -c` -gt 0 ]; then
       sectionFlag='storage'
       continue
    elif [ `echo $record | grep '# View Information' | wc -c` -gt 0 ]; then
       sectionFlag='view'
       continue
    elif [ "`echo $record | cut -c-1`" == '=' ]; then
       sectionFlag=''
       continue
    fi

#######
# Get table name
#######

    isDescribe=`echo $record | grep 'describe' | wc -c`
    if [ $isDescribe -gt 0 ]; then
        dbName=`echo $record | cut -d' ' -f3 | cut -d'.' -f1 | tr -d ' ' | tr -d "'"`
        tblName=`echo $record | cut -d' ' -f3 | cut -d'.' -f2 | tr -d ' ' | tr -d "'"`
    fi

#######
# Get table columns
#######

    if [ "$sectionFlag" == 'column' ]; then
       colName=`echo $record | cut -d' ' -f1 | tr -d ' '`
       dataType=`echo $record | cut -d' ' -f2 | tr -d ' '`
       colMetaData+="${dbName}"'@'"${tblName}"'@'"${colName}"'@'"${dataType}"$'\n'
    fi

#######
# Get Partition columns
#######

    if [ "$sectionFlag" == 'partition'  ]; then
       if [ "`echo $record | cut -c-1`" == "#" ]; then
          continue
       fi
       colName=`echo $record | cut -d' ' -f1 | tr -d ' '`
       colType=`echo $record | cut -d' ' -f2 | tr -d ' '`
       tblPartition=$tblPartition$colName':'$colType
    fi

#######
# Get table properties
#######

    if [ "$sectionFlag" == 'table'  ]; then
       keyField=`echo $record | cut -d':' -f1 | sed -e 's/^ *//g;s/ *$//g'`
       valueField=`echo $record | cut -d':' -f2 | sed -e 's/^ *//g;s/ *$//g'`

       case $keyField in
            "Database") tblDatabase=$valueField
            ;;
            "Owner")tblOwner=$valueField
            ;;
            "Location") tblLocation=`echo $record | awk '{print $2}'`
            ;;
            "Table Type") tblType=$valueField
            ;;
            "Table Parameters") tblParamFlag='y'
       esac

       if [ "$tblParamFlag" == 'y' -a "$keyField" != 'Table Parameters' ]; then
          key=`echo $record | cut -d' ' -f1 | sed -e 's/^ *//g;s/ *$//g'`
          value=`echo $record | cut -d' ' -f2 | sed -e 's/^ *//g;s/ *$//g'`

          tblParams=$tblParams$key':'$value'|'
       fi
     fi

#######
# Get Storage Information
#######

    if [ "$sectionFlag" == 'storage' ]; then
       keyField=`echo $record | cut -d':' -f1 | sed -e 's/^ *//g;s/ *$//g'`
       valueField=`echo $record | cut -d':' -f2 | sed -e 's/^ *//g;s/ *$//g'`

       case $keyField in
            "SerDe Library") strSerde=$valueField
            ;;
            "InputFormat") strInput=$valueField
            ;;
            "OutputFormat") strOutput=$valueField
            ;;
            "Compressed") strCompress=$valueField
            ;;
            "Num Buckets") strNumBuckets=$valueField
            ;;
            "Bucket Columns") strBucketCols=`echo $valueField | tr -d '[' | tr -d ']'`
            ;;
            "Sort Columns") strSortCols=`echo $valueField | tr -d '[' | tr -d ']'`
            ;;
            "Storage Desc Params") strParamFlag='y'
       esac

       if [ "$strParamFlag" == 'y' -a "$keyField" != 'Storage Desc Params' ]; then
          key=`echo $record | cut -d' ' -f1 | sed -e 's/^ *//g;s/ *$//g'`
          value=`echo $record | cut -d' ' -f2 | sed -e 's/^ *//g;s/ *$//g'`

          strParams=$strParams$key':'$value'|'
       fi
    fi

#######
# View Information
# Currently ignored
#######

    if [ "$sectionFlag" == 'view' ]; then
       continue
    fi

done < $descFileName


#########
# Remove blank lines from output files
#########
sed -i -e '/^@/d;/^[[:space:]]*$/d' $HiveTblMeta
sed -i -e '/^[[:space:]]*$/d' $HiveColMeta

exit 0
