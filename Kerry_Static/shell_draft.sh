
#Set directory
Data_Dir_nfcapd="/home/jwc3f/netflow" # Location of raw nfcapd data files
Prog_Dir="/home/jwc3f/scripts" # Location of this script
Work_Dir="/home/jwc3f/flowFiles" # Output directory after filtering of IP from DNS.csv and concatenation
Temp_Dir="/home/jwc3f/flowData" # Folder for scratch work
NfDumpData="nfcapd-file-list.txt"


#Input arguments for date of interest:
Year=$1
Month=$2
Day=$3
Hour=$4

Date=$1$2$3$4

#get the names of the nfcapd files for a particular hour, 12 files
#echo Getting file list ...
ls -1 $Data_Dir_nfcapd | grep $Date > $NfDumpData


Date1=$1"-"$2"-"$3
#create the flow directory for keeping the flow information in ascii
Temp_Date_Dir="$Temp_Dir/$Date1"
if [ ! -d "$Temp_Data_Dir" ]; then
    mkdir -p $Temp_Data_Dir
fi

#First make directory for filtered
Temp_Date_Dir_Fil =  "$Temp_Date_Dir/Filtered-Records"
if [ ! -d "$Filtered-Records" ]; then
    mkdir -p $Filtered-Records
fi


### Function to check return codes for nfdump errors and print an explanation
### Argument: string containing the nfdump command to check
checkError() {
    if [ "$1" = "255" ]; then
        logError "Initialization failed. Command that failed was: $2"
    elif [ "$1" = "254" ]; then
        logError "Error in filter syntax. Command that failed was: $2"
    elif [ "$1" = "250" ]; then
        logError "Internal error. Command that failed was: $2"
    fi
}


Comment="Date_first_seen         Date_last_seen           Duration Proto      Src_IP_Addr Src_Pt         Dst_IP_Addr Dst_Pt  Packets    Bytes  Flags  Input Output        Router_IP      Next_hop_IP  BG\
P_next_hop_IP Src_AS Dst_AS S_Mask D_Mask Max_Rate" # Comment line at top of output
CommentLine="#"
CommentLine+=$Comment


#Create empty text file for all records for particular hour
#echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-2017-02-11-00-55.txt 
echo "$CommentLine" > $Temp_Date_Dir_Fil/filteredFlowRecords-$Date-55.txt

#create the filter of IP addresses from DNS.csv
Filter_StaticIP=$Prog_Dir/FilterStaticIP.filt
Filter_Script_IP=$Prog_Dir/filter-IPaddress-from-DNS.py

echo Creating filter list in $Filter_StaticIP ...
python $Filter_Script_IP $Prog_Dir/DNS2.csv > $Filter_StaticIP

while read filename
do

    cmd="time /home/sm8kk/stats4995/persistent-flow/nfdump-1.6.13/bin/nfdump -f $Filter_StaticIP -N -q -r $Data_Dir_nfcapd/$filename -o 'fmt:%ts %te %td %pr %sa %sp -> %da %dp %pkt %byt %flg %in %out %ra %nh %nhb %sas %das %smk %dmk %bps' >> $Temp_Data_Dir/filteredFlowRecords-2017-02-11-00-55.txt
    echo Executing: $cmd
    eval $cmd
    result=$?

    #check for errors
    checkError $result "$cmd"

done < $NfDumpData
