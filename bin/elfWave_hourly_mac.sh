#!/bin/bash
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

# Uncomment the environment config file that you are using
source config/prod.conf
# source config/load.conf

# Define what APP the ELF datasets are loaded into
elfApp='POC'

#prompt the user to enter the date for the logs they want to download for the source (Event Monitoring) org

# Default date - current datetime minus 24H and assigned to GMT
default_day=`date -v-24H "+%Y-%m-%dT%H:00:00Z"`

read -p "Use default log date: $default_day (Y/N)" default
if [ $default == Y ] || [ $default == y ] || [ $default == Yes ] || [ $default == yes ]; then
    day=$default_day
elif [ $default == N ] || [ $default == n ] || [ $default == No ] || [ $default == no ]; then
    read -p "Please enter log date value (e.g. ${default_day} or YESTERDAY, TODAY): " day
fi
echo "\nLog data from ${day} onwards.\n"

#set API version to the proper level to the supported EventTypes listed below
api_version='v42.0'

#eventType=''
#eventInterval=''

#prompt the user to enter the eventType they want to download for the source (Event Monitoring) org
printf 'What EventType do you want to download?\n'
printf '1. All 45 event types\n'
printf '2. API\n'
printf '3. ApexCallout\n'
printf '4. ApexExecution\n'
printf '5. ApexSoap\n'
printf '6. ApexTrigger\n'
printf '7. AsyncReportRun\n'
printf '8. BulkApi\n'
printf '9. ChangeSetOperation\n'
printf '10. Console\n'
printf '11. ContentDistribution\n'
printf '12. ContentDocumentLink\n'
printf '13. ContentTransfer\n'
printf '14. Dashboard\n'
printf '15. DocumentAttachmentDownloads\n'
printf '16. ExternalCrossOrgCallout\n'
printf '17. ExternalCustomApexCallout\n'
printf '18. ExternalOdataCallout\n'
printf '19. InsecureExternalAssets\n'
printf '20. KnowledgeArticleView\n'
printf '21. LightningError\n'
printf '22. LightningInteraction\n'
printf '23. LightningPageView\n'
printf '24. LightningPerformance\n'
printf '25. Login\n'
printf '26. LoginAs\n'
printf '27. Logout\n'
printf '28. MetadataApiOperation\n'
printf '29. MultiBlockReport\n'
printf '30. PackageInstall\n'
printf '31. PlatformEncryption\n'
printf '32. QueuedExecution\n'
printf '33. Report\n'
printf '34. ReportExport\n'
printf '35. RestApi\n'
printf '36. Sandbox\n'
printf '37. Search\n'
printf '38. SearchClick\n'
printf '39. Sites\n'
printf '40. TimeBasedWorkflow\n'
printf '41. TransactionSecurity\n'
printf '42. URI\n'
printf '43. VisualforceRequest\n'
printf '44. WaveChange\n'
printf '45. WaveInteraction\n'
printf '46. WavePerformance\n'

read eventMenu

case $eventMenu in 
     1)
          eventType=${eventType:-All}
          ;;
     2)
          eventType=${eventType:-API}
          ;;
     3)
          eventType=${eventType:-ApexCallout}
          ;; 
     4)
          eventType=${eventType:-ApexExecution}
          ;; 
     5)
          eventType=${eventType:-ApexSoap}
          ;;      
     6)
          eventType=${eventType:-ApexTrigger}
          ;; 
     7)
          eventType=${eventType:-AsyncReportRun}
          ;; 
     8)
          eventType=${eventType:-BulkApi}
          ;; 
     9)
          eventType=${eventType:-ChangeSetOperation}
          ;; 
     10)
          eventType=${eventType:-Console}
          ;;
     11)
          eventType=${eventType:-ContentDistribution}
          ;; 
     12)
          eventType=${eventType:-ContentDocumentLink}
          ;; 
     13)
          eventType=${eventType:-ContentTransfer}
          ;; 
     14)
          eventType=${eventType:-Dashboard}
          ;; 
     15)
          eventType=${eventType:-DocumentAttachmentDownloads}
          ;; 
     16)
          eventType=${eventType:-ExternalCrossOrgCallout}
          ;;
     17)
          eventType=${eventType:-ExternalCustomApexCallout}
          ;;
     18)
          eventType=${eventType:-ExternalOdataCallout}
          ;;
     19)
          eventType=${eventType:-InsecureExternalAssets}
          ;;
     20)
          eventType=${eventType:-KnowledgeArticleView}
          ;;
     21)
          eventType=${eventType:-LightningError}
          ;;
     22)
          eventType=${eventType:-LightningInteraction}
          ;;
      23)
           eventType=${eventType:-LightningPageView}
           ;;
     24)
          eventType=${eventType:-LightningPerformance}
          ;;          
     25)
          eventType=${eventType:-Login}
          ;; 
     26)
          eventType=${eventType:-LoginAs}
          ;; 
     27)
          eventType=${eventType:-Logout}
          ;; 
     28)
          eventType=${eventType:-MetadataApiOperation}
          ;; 
     29)
          eventType=${eventType:-MultiBlockReport}
          ;; 
     30)
          eventType=${eventType:-PackageInstall}
          ;; 
     31)
          eventType=${eventType:-PlatformEncryption}
          ;;
     32)
          eventType=${eventType:-QueuedExecution}
          ;;
     33)
          eventType=${eventType:-Report}
          ;; 
     34)
          eventType=${eventType:-ReportExport}
          ;; 
     35)
          eventType=${eventType:-RestApi}
          ;; 
     36)
          eventType=${eventType:-Sandbox}
          ;; 
     37)
          eventType=${eventType:-Search}
          ;;
     38)
          eventType=${eventType:-SearchClick}
          ;;
     39)
          eventType=${eventType:-Sites}
          ;; 
     40)
          eventType=${eventType:-TimeBasedWorkflow}
          ;; 
     41)
          eventType=${eventType:-TransactionSecurity}
          ;;
     42)
          eventType=${eventType:-URI}
          ;; 
     43)
          eventType=${eventType:-VisualforceRequest}
          ;; 
     44)  
          eventType=${eventType:-WaveChange} 
          ;;
     45)  
          eventType=${eventType:-WaveInteraction} 
          ;;
     46)  
          eventType=${eventType:-WavePerformance} 
          ;;
      *)  
          echo "$eventMenu is not a valid option"
          ;;
esac

echo ${eventType}

#prompt the user to choose daily or hourly files they want to download for the source (Event Monitoring) org
printf 'What EventInterval do you choose?\n'
printf '1. Daily\n'
printf '2. Hourly\n'

read intervalChoice

case $intervalChoice in 
     1)
          eventInterval=${eventInterval:-Daily};;
     2)
          eventInterval=${eventInterval:-Hourly};;
     *)  
          echo "$intervalChoice is not a valid option";;
esac

echo ${eventInterval}

#set access_token for OAuth flow 
#change client_id and client_secret to your own connected app - bit.ly/sfdcConnApp
access_token=`curl https://${instance}.salesforce.com/services/oauth2/token -d "grant_type=password" -d "client_id=3MVG99OxTyEMCQ3ilfR5dFvVjgTrCbM3xX8HCLLS4GN72CCY6q86tRzvtjzY.0.p5UIoXHN1R4Go3SjVPs0mx" -d "client_secret=7899378653052916471" -d "username=${username}" -d "password=${password}" -H "X-PrettyPrint:1" | jq -r '.access_token'`

#uncomment next line if you want to check your access token
#echo "Access token: ${access_token}"

if [ $eventInterval == "Hourly" ]; then
    if [ $eventType == "All" ]; then
        #set elfs to the result of ELF query *without* EventType in query
        elfs=`curl https://${instance}.salesforce.com/services/data/${api_version}/query?q=Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+Sequence+!=+0+AND+LogDate+%3E=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
    else
        #set elfs to the result of ELF query *with* EventType in query
        elfs=`curl https://${instance}.salesforce.com/services/data/${api_version}/query?q=Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+Sequence+!=+0+AND+LogDate+%3E=+${day}+AND+EventType+=+\'${eventType}\' -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
    fi
fi

if [ $eventInterval == "Daily" ]; then
    if [ $eventType == "All" ]; then
        #set elfs to the result of ELF query *without* EventType in query
        elfs=`curl https://${instance}.salesforce.com/services/data/${api_version}/query?q=Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+LogDate+%3E=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
    else
        #set elfs to the result of ELF query *with* EventType in query
        elfs=`curl https://${instance}.salesforce.com/services/data/${api_version}/query?q=Select+Id+,+EventType+,+LogDate,+Sequence+From+EventLogFile+Where+LogDate+%3E=+${day}+AND+EventType+=+\'${eventType}\' -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
    fi
fi 

# Uncomment next line to debug response object from EventLogFile query
# echo ${elfs}

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

#prompt user to clean up data and directories
read -p "Do you want to delete data directories and files? (Y/N)" del

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
