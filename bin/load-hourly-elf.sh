#!/bin/bash

echo "************************************************************************"
echo $(date -u "+%Y-%m-%dT%H:%M:%SZ") - Start of loading log files into Wave 
echo "************************************************************************"

# Bash script to download EventLogFiles and load them into Wave
# Pre-requisite: download - http://stedolan.github.io/jq/ to parse JSON
# Pre-requisite: download datasetutil - http://bit.ly/datasetutil

 #/**
 #* Copyright (c) 2012, Salesforce.com, Inc.  All rights reserved.
 #* 
 #* Redistribution and use in source and binary forms, with or without
 #* modification, are permitted provided that the following conditions are
 #* met:
 #* 
 #*   * Redistributions of source code must retain the above copyright
 #*     notice, this list of conditions and the following disclaimer.
 #* 
 #*   * Redistributions in binary form must reproduce the above copyright
 #*     notice, this list of conditions and the following disclaimer in
 #*     the documentation and/or other materials provided with the
 #*     distribution.
 #* 
 #*   * Neither the name of Salesforce.com nor the names of its
 #*     contributors may be used to endorse or promote products derived
 #*     from this software without specific prior written permission.
 #* 
 #* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 #* "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 #* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 #* A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 #* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 #* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 #* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 #* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 #* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 #* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 #* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 #*/

if [ $# -ne 1 ]; then
    echo
    echo $0: usage: load-hourly-elf eventType
    echo
    printf 'Available Event Types:\n'
    printf '> API\n'
    printf '> ApexCallout\n'
    printf '> ApexExecution\n'
    printf '> ApexSoap\n'
    printf '> ApexTrigger\n'
    printf '> AsyncReportRun\n'
    printf '> BulkApi\n'
    printf '> ChangeSetOperation\n'
    printf '> Console\n'
    printf '> ContentDistribution\n'
    printf '> ContentDocumentLink\n'
    printf '> ContentTransfer\n'
    printf '> Dashboard\n'
    printf '> DocumentAttachmentDownloads\n'
    printf '> ExternalCrossOrgCallout\n'
    printf '> ExternalCustomApexCallout\n'
    printf '> ExternalOdataCallout\n'
    printf '> InsecureExternalAssets\n'
    printf '> KnowledgeArticleView\n'
    printf '> LightningError\n'
    printf '> LightningInteraction\n'
    printf '> LightningPageView\n'
    printf '> LightningPerformance\n'
    printf '> Login\n'
    printf '> LoginAs\n'
    printf '> Logout\n'
    printf '> MetadataApiOperation\n'
    printf '> MultiBlockReport\n'
    printf '> PackageInstall\n'
    printf '> PlatformEncryption\n'
    printf '> QueuedExecution\n'
    printf '> Report\n'
    printf '> ReportExport\n'
    printf '> RestApi\n'
    printf '> Sandbox\n'
    printf '> Search\n'
    printf '> SearchClick\n'
    printf '> Sites\n'
    printf '> TimeBasedWorkflow\n'
    printf '> TransactionSecurity\n'
    printf '> URI\n'
    printf '> VisualforceRequest\n'
    printf '> WaveChange\n'
    printf '> WaveInteraction\n'
    printf '> WavePerformance\n'
    exit 1
fi

eventType="$1"
printf 'Event Type selected:\t\t %s\n' ${eventType}

eventInterval="Hourly"
printf 'Event Interval selected:\t %s\n' ${eventInterval}


# Parameters supported for script
# - eventType (one of 45 available types, provide list of available event types in usage text) - REQUIRED
# - eventInterval (hourly -h or daily -d) - REQUIRED
#   optional add numbers to event interval to define interval length
#   e.g.: -h24 or -h12 or -h6 or -d1 -d3 -d7
# - startTimestamp (start timestamp from when to import log files, e.g. 2018-04-30T07:00:00Z ) - OPTIONAL
#   if startTimestamp is used eventInterval does not support optional attribute values
# - endTimestamp (end timestamp for when to stop importing log files, defaults to empty, which means until now) - OPTIONAL
#   only available if startTimestamp is used as well
# - elfApp (target Wave app to write the dataset into, can be empty) - OPTIONAL
# - targetOrgType (PROD or TEST sandboxes, defaults to PROD) - OPTIONAL

#set API version to the proper level to the supported EventTypes listed below
api_version='v42.0'

# Debug parameter - can contain -v for verbose CURL logging
curl_debug='-v'

# Uncomment the environment config file that you are using
source prod.conf
# source load.conf

# Define what APP the ELF datasets are loaded into
elfApp='POC'

#set API version to the proper level to the supported EventTypes listed below
api_version='v42.0'

#prompt user to clean up data and directories
del="Y"

# Default date - current datetime minus 24H and assigned to GMT
day=`date --date='24 hours ago' "+%Y-%m-%dT%H:00:00Z"`
printf 'Event log start TS:\t\t %s\n' ${day}

#set access_token for OAuth flow 
#change client_id and client_secret to your own connected app - bit.ly/sfdcConnApp

login=`curl -v https://${instance}.salesforce.com/services/oauth2/token -d "grant_type=password" -d "client_id=3MVG99OxTyEMCQ3ilfR5dFvVjgTrCbM3xX8HCLLS4GN72CCY6q86tRzvtjzY.0.p5UIoXHN1R4Go3SjVPs0mx" -d "client_secret=7899378653052916471" -d "username=${username}" -d "password=${password}" -H "X-PrettyPrint:1"`
access_token=( $(echo ${login} | jq -r '.access_token') )

echo "Access token: ${access_token}"

if [ $eventInterval == "Hourly" ]; then
    if [ $eventType == "All" ]; then
        #set elfs to the result of ELF query *without* EventType in query
        elfs=`curl -v https://${instance}.salesforce.com/services/data/${api_version}/query?q=Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+Sequence+!=+0+AND+LogDate+%3E=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
    else
        #set elfs to the result of ELF query *with* EventType in query
        elfs=`curl -v https://${instance}.salesforce.com/services/data/${api_version}/query?q=Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+Sequence+!=+0+AND+LogDate+%3E=+${day}+AND+EventType+=+\'${eventType}\' -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
    fi
fi

if [ $eventInterval == "Daily" ]; then
    if [ $eventType == "All" ]; then
        #set elfs to the result of ELF query *without* EventType in query
        elfs=`curl -v https://${instance}.salesforce.com/services/data/${api_version}/query?q=Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+LogDate+%3E=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
    else
        #set elfs to the result of ELF query *with* EventType in query
        elfs=`curl -v https://${instance}.salesforce.com/services/data/${api_version}/query?q=Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+LogDate+%3E=+${day}+AND+EventType+=+\'${eventType}\' -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
    fi
fi 

# Uncomment next line to debug response object from EventLogFile query
echo ${elfs} >&2

#set the variables to the array of Ids, EventTypes, logDates, logHours and LogDates which will be used when downloading the files into your local directory
ids=( $(echo ${elfs} | jq -r ".records[].Id") )
logDates=( $(echo ${elfs} | jq -r ".records[].LogDate" | cut -c 1-10 ) )
logHours=( $(echo ${elfs} | jq -r ".records[].LogDate" | cut -c 12-13 ) )
sequences=( $(echo ${elfs} | jq -r ".records[].Sequence" ) )
eventTypes=( $(echo ${elfs} | jq -r ".records[].EventType" ) )

echo "*********************************************************"
echo "Number of log files selected: ${#ids[@]}"
echo "*********************************************************"

#make directory to store the files by date and separate out raw data from 
#converted timezone data
mkdir "eventlogs"
mkdir "eventlogs/${eventInterval}-raw"
mkdir "eventlogs/${eventInterval}"

#loop through the array of results and download each file with the following naming convention: EventType.csv
for i in "${!ids[@]}"; do
    
    #download files into the ${eventTypes[$i]}-raw directory
    curl --compressed \
        "https://${instance}.salesforce.com/services/data/${api_version}/sobjects/EventLogFile/${ids[$i]}/LogFile" \
        -H "Authorization: Bearer ${access_token}" \
        -H "X-PrettyPrint:1" \
        -o "eventlogs/${eventInterval}-raw/${logDates[$i]}_${logHours[$i]}-${sequences[$i]}_${eventTypes[$i]}.csv" 

    #convert files into the ${eventInterval} directory for Salesforce Analytics
    awk -F ','  '{ if(NR==1) printf("%s\n",$0); else{ for(i=1;i<=NF;i++) { if(i>1&& i<=NF) printf("%s",","); if(i == 2) printf "\"%s-%s-%sT%s:%s:%sZ\"", substr($2,2,4),substr($2,6,2),substr($2,8,2),substr($2,10,2),substr($2,12,2),substr($2,14,2); else printf ("%s",$i);  if(i==NF) printf("\n")}}}' "eventlogs/${eventInterval}-raw/${logDates[$i]}_${logHours[$i]}-${sequences[$i]}_${eventTypes[$i]}.csv" > "eventlogs/${eventInterval}/${logDates[$i]}_${logHours[$i]}-${sequences[$i]}_${eventTypes[$i]}.csv"

done

#variable to count the number of unique event types
uEventTypes=( $(echo ${elfs} | jq -r ".records[].EventType" | uniq) )

if [ $eventInterval == "Hourly" ]; then
    output_file_prefix="Hourly"
else
    output_file_prefix=""
fi

#merge data into single CSV file
for j in "${uEventTypes[@]}"
do
    output_file="${output_file_prefix}$j.csv"
    count=0

    for f in `ls eventlogs/${eventInterval}/*_$j.csv`
    do
        echo "still merging [$f]"
            
            echo "merging file: $f to $output_file."
            if [ $count -eq 0 ]; then

                    awk -F ',' '{print $0}' $f 1>$output_file
            else
                    awk -F ',' 'FNR>1 {print $0}' $f 1>>$output_file
            fi
            count=`expr $count + 1`
            echo "number of input files: $count merged to output file: $output_file"
    done
done

#load CSV files to datasets in Wave
for i in `ls *.csv`; do
    #variables to specify file and dataset name
    eventFile=`echo $i`
    eventName=`echo $i | sed 's/\.csv//g'`

    #comment out next line to test before uploading to Wave
    java -jar datasetutils-39.0.1.jar --action load --endpoint ${endpoint} --u ${tUsername} --p ${tPassword} --inputFile ${eventFile} --dataset ${eventName} --app ${elfApp}
done

if [ $del == Y ] || [ $del == y ] || [ $del == Yes ] || [ $del == yes ]; then
    #clean up data directories
    rm -r "eventlogs"
    for i in "${!uEventTypes[@]}"; do
        rm "${output_file_prefix}${uEventTypes[$i]}.csv"
    done
    rm -r "archive"
    echo "The files were removed."
    #leave data and directories for audit reasons
elif [ $del == N ] || [ $del == n ] || [ $del == No ] || [ $del == no ]; then
    echo "The files will remain."
fi

echo "The script finished successfully."
exit 0
