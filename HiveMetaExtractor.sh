#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

createSchema()
{
   echo "Please wait getting the scripts ready... "
   ./createSetupTbl.sh
   if [ $? -eq 0 ]; then
      :
      else
      echo "Failed while creating the table schema."
      exit 1
   fi
}

createDBList()
{
createSchema
./createDBList.sh
if [ $? -eq 0 ]; then
   #count= `wc -l hiveDBList.txt | awk '{print $1;}'`
   echo "Please check the list of Databases in the file : hiveDBList.txt"
   #echo "Total number of Databases: $count"
else
   echo "Failed while fetching Database List"
fi

}

createTableList()
{
createSchema
file_name=hiveDBList.txt
if [ ! -f $file_name ]; then
   echo "File does not exist. Exiting..."
   exit 1
fi

./createTblList.sh $file_name

if [ $? -eq 0 ]; then
   :
else
   echo "Failed while fetching Table List"
   exit 1
fi
echo "Please check the list of tables across all the databases in the file: hiveTblList.txt"

}

createTableDescribe()
{
createSchema
file_name=hiveTblList.txt
if [ ! -f $file_name ]; then
   echo "File does not exist. Exiting..."
   exit 1
fi

./createTblDescribe.sh $file_name
if [ $? -eq 0 ]; then
   :
else
   echo "Failed while describing the table"
   exit 1
fi
echo "Please check the table description in the file: HiveTblDescribe.txt "

}

parseTableDescribe()
{
createSchema
file_name=hiveTblDescribe.txt
if [ ! -f $file_name ]; then
   echo "File does not exist. Exiting..."
   exit 1
fi

./parseTblDescribe.sh $file_name
if [ $? -eq 0 ]; then
   :
else
   echo "Failed while parsing the table description"
   exit 1
fi

./loadMetaTable.sh
if [ $? -eq 0 ]; then
   :
else
   echo "Failed while creating the table meta data"
   exit 1
fi

echo "Please check the table description in the file: HiveTblDescribe.txt "
echo "Loaded the data into Hive tables:  metamgr.tabledtls and  metamgr.columndtls"

}

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

while true; do
printf "
#####################################################
       ${GREEN}Welcome to HiveMetaExtractor!!${NC}               #
                                                    #
${GREEN}1: Get the list of databases${NC}                        #
${GREEN}2: Get the list of tables across the databases${NC}      #
${GREEN}3: Get the table description${NC}                        #
${GREEN}4: Parse table description into a Hive Table${NC}        #
${GREEN}5: EXIT ${NC}                                            #
#####################################################
Your Option: "

read num

        case $num in
                1)createDBList
                break;;
                2) createTableList
                break;;
                3)createTableDescribe
                    break;;
                4)parseTableDescribe
                   break;;
                5) exit;;
                * )echo "Please enter your option: "
        esac
done


