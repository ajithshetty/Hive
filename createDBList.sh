#############################################
# Create list of all databases in Hive      #
# No input required for this script         #
# Runs hive -e "Show databases" command     #
# Output file is "hiveDBList.txt            #
# created in the script directory           #
#############################################
echo "Creating a list of databases from Hive"
nohup hive -e "show databases;"  > ./tempDBList.txt
if [ $? -ne 0 ]; then
   echo "Show database command failed "
   exit 1
fi

#Removing hive logs from the output
sed -n '/OK/,$p' tempDBList.txt | sed '1d;$d' >  hiveDBList.txt
rm ./tempDBList.txt
exit 0
