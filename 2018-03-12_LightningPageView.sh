#!/usr/bin/env sh

# A script that downloads an event log file
# Requires cURL http://curl.haxx.se/

# Event Type: LightningPageView
# Log Date: 2018-03-12
# File Size (in Bytes): 294,125.0
curl --compressed "https://allegisgroup.my.salesforce.com/services/data/v32.0/sobjects/EventLogFile/0AT1p000002C3nIGAS/LogFile" -H "Authorization: Bearer 00DU0000000KEH3!ARwAQFipmkT7QlgX3jucENKx5x9QZnKfoXivViX6KOCv2SlyCngUzT4pG_WjFK2.yis5JS4B7OF9UfU.h.wseI4Y0E4pa2r4" -o "2018-03-12_LightningPageView.csv"
