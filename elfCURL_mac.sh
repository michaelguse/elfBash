#!/bin/bash
# Mac OSX Bash script to download EventLogFiles
# Pre-requisite: download - http://stedolan.github.io/jq/ to parse JSON

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

#prompt the user to enter their username
read -p "Please enter username (and press ENTER): " username

#prompt the user to enter their password 
read -s -p "Please enter password (and press ENTER): " password

#prompt the user to enter their instance end-point 
echo 
read -p "Please enter instance (e.g. na1) for the loginURL (and press ENTER): " instance

#prompt the user to enter the date for the logs they want to download
read -p "Please enter logdate (e.g. Yesterday, Last_Week, Last_n_Days:5) (and press ENTER): " day

#set access_token for OAuth flow 
#change client_id and client_secret to your own connected app - bit.ly/sfdcConnApp
access_token=`curl https://${instance}.salesforce.com/services/oauth2/token -d "grant_type=password" -d "client_id=3MVG99OxTyEMCQ3ilfR5dFvVjgTrCbM3xX8HCLLS4GN72CCY6q86tRzvtjzY.0.p5UIoXHN1R4Go3SjVPs0mx" -d "client_secret=7899378653052916471" -d "username=${username}" -d "password=${password}" -H "X-PrettyPrint:1" | jq -r '.access_token'`
echo ${access_token}

#set elfs to the result of ELF query
elfs=`curl https://${instance}.salesforce.com/services/data/v41.0/query?q=Select+Id+,+EventType+,+LogDate+From+EventLogFile+Where+LogDate+=+${day} -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1"`
echo ${elfs}

#set the three variables to the array of Ids, EventTypes, and LogDates which will be used when downloading the files into your directory
ids=( $(echo ${elfs} | jq -r ".records[].Id") )
echo ${ids}
eventTypes=( $(echo ${elfs} | jq -r ".records[].EventType") )
echo ${eventTypes}
logDates=( $(echo ${elfs} | jq -r ".records[].LogDate" | sed 's/'T.*'//' ) )
echo ${logDates}

#loop through the array of results and download each file with the following naming convention: EventType-LogDate.csv
for i in "${!ids[@]}"; do

    #make directory to store the files by date
    mkdir "${logDates[$i]}"

    #download files into the logDate directory
    curl --compressed "https://${instance}.salesforce.com/services/data/v41.0/sobjects/EventLogFile/${ids[$i]}/LogFile" -H "Authorization: Bearer ${access_token}" -H "X-PrettyPrint:1" -o "${logDates[$i]}/${eventTypes[$i]}-${logDates[$i]}.csv"
done