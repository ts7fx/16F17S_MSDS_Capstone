#Set directory
Data_Dir_nfcapd="/home/jwc3f/netflow" # Location of raw nfcapd data files
Prog_Dir="/home/jwc3f/scripts" # Location of this script
Work_Dir="/home/jwc3f/flowFiles" # Output directory after filtering of IP from DNS.csv and concatenation
Temp_Dir="/home/jwc3f/flowData" # Folder for scratch work

NfDumpData=$1
Date_time=$2 #Day and hour
recordFile=$3

Temp_Data_Dir="$Temp_Dir/$Date_time"

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
Filter_StaticIP=$Prog_Dir/FilterStaticIP.filt

while read filename
do

    cmd="time /home/sm8kk/stats4995/persistent-flow/nfdump-1.6.13/bin/nfdump -f $Filter_StaticIP -N -q -r $Data_Dir_nfcapd/$filename -o 'fmt:%ts %te %td %pr %sa %sp -> %da %dp %pkt %byt %flg %in %out %ra %nh %nhb %sas %das %smk %dmk %bps' >> $Temp_Data_Dir/$recordFile"
    echo Executing: $cmd
    eval $cmd
    result=$?

    #check for errors
    checkError $result "$cmd"

done < $NfDumpData

#signal that it is over
touch $1-complete

