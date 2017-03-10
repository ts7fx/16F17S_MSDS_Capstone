Data_Dir_nfcapd="/home/jwc3f/netflow" # Location of raw nfcapd data files
Prog_Dir="/home/jwc3f/scripts" # Location of this script
Work_Dir="/home/jwc3f/flowFiles" # Output directory after filtering of IP from DNS.csv and concatenation
Temp_Dir="/home/jwc3f/flowData" # Folder for scratch work
NfDumpData="nfcapd-file-list.txt"

Year=$1
Month=$2
Day=$3
Date=$1$2$3

#get the names of the nfcapd files for a particular day, around 288 files
#echo Getting file list ...
ls -1 $Data_Dir_nfcapd | grep $Date > $NfDumpData

rm -f xa*


#chop up the file $NfDumpData into small portions
split -l 12 $NfDumpData


#First make directory for filtered
Temp_Date_Dir_Fil =  "$Temp_Date_Dir/Filtered-Records"
if [ ! -d "$Filtered-Records" ]; then
    mkdir -p $Filtered-Records
fi


Comment="Date_first_seen         Date_last_seen           Duration Proto      Src_IP_Addr Src_Pt         Dst_IP_Addr Dst_Pt  Packets    Bytes  Flags  Input Output        Router_IP      Next_hop_IP  BG\P_next_hop_IP Src_AS Dst_AS S_Mask D_Mask Max_Rate" # Comment line at top of output
CommentLine="#"
CommentLine+=$Comment


Date1=$1-$2-$3

echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-00-55.txt
echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-01-55.txt
echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-02-55.txt
echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-03-55.txt
echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-04-55.txt
echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-05-55.txt
echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-06-55.txt
echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-07-55.txt
#echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-08-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-09-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-10-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-11-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-12-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-13-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-14-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-15-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-16-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-17-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-18-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-19-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-20-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-21-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-22-55.txt
# echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date1-23-55.txt

#create the filter of IP addresses from DNS.csv
Filter_StaticIP=$Prog_Dir/FilterStaticIP.filt
Filter_Script_IP=$Prog_Dir/filter-IPaddress-from-DNS.py

echo Creating filter list in $Filter_StaticIP ...
#python $Filter_Script_IP $Prog_Dir/DNS2.csv > $Filter_StaticIP


./filter-flows-per-nfcapd-parallel_hour.sh xaa $Date1+"00" filteredFlowRecords-$Date1-00-55.txt &
./filter-flows-per-nfcapd-parallel_hour.sh xab $Date1+"01" filteredFlowRecords-$Date1-01-55.txt &
./filter-flows-per-nfcapd-parallel_hour.sh xac $Date1+"02" filteredFlowRecords-$Date1-02-55.txt &
./filter-flows-per-nfcapd-parallel_hour.sh xad $Date1+"03" filteredFlowRecords-$Date1-03-55.txt &
./filter-flows-per-nfcapd-parallel_hour.sh xae $Date1+"04" filteredFlowRecords-$Date1-04-55.txt &
./filter-flows-per-nfcapd-parallel_hour.sh xaf $Date1+"05" filteredFlowRecords-$Date1-05-55.txt &
./filter-flows-per-nfcapd-parallel_hour.sh xag $Date1+"06" filteredFlowRecords-$Date1-06-55.txt &
./filter-flows-per-nfcapd-parallel_hour.sh xah $Date1+"07" filteredFlowRecords-$Date1-07-55.txt &



while [ ! -f xaa-complete ];
do
    echo Waiting on xaa
    sleep 60
done;
echo "xaa list completed"

while [ ! -f xab-complete ];
do
    echo Waiting on xab
    sleep 60;
done;
echo "xab list completed"

while [ ! -f xac-complete ];
do
    echo Waiting on xac
    sleep 60;
done;
echo "xac list completed"

while [ ! -f xad-complete ];
do
    echo Waiting on xad
    sleep 60;
done;
echo "xad list completed"

while [ ! -f xae-complete ];
do
    echo Waiting on xae
    sleep 60;
done;
echo "xad list completed"


while [ ! -f xaf-complete ];
do
    echo Waiting on xaf
    sleep 60;
done;
echo "xad list completed"


while [ ! -f xag-complete ];
do
    echo Waiting on xag
    sleep 60;
done;
echo "xad list completed"

while [ ! -f xah-complete ];
do
    echo Waiting on xah
    sleep 60;
done;
echo "xad list completed"







