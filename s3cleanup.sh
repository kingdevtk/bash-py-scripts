#!/bin/bash

<<COMMENT
    This script goes through all S3 buckets associated with an AWS account and gets the date of the last updated file in each bucket.
    S3 buckets are sorted based on the date of the last updated file and outputted to s3buckets.txt in the current directory.

    This script assumes that the aws cli is installed and the appropriate permissions are granted.
    If you are running the script on your local machine, export the following environment variables:
        - AWS_ACCESS_KEY_ID
        - AWS_SECRET_ACCESS_KEY
COMMENT

BUCKETS=$(aws s3api list-buckets --query "Buckets[].Name" | tr -d '"' | tr -d "," | tr -d ']' | tr -d '[')

for bucket in $BUCKETS; do
    ## The 'aws s3api get-bucket-location' command returns the value 'None' for buckets loacted in us-east-1
    region=$(aws s3api get-bucket-location --output text --bucket $bucket)

    ## If the value of region equals 'None', make region equal us-east-1
    if [[ $region == "None" ]] 
    then
        region="us-east-1"
    fi
    
    latest=$(aws s3 ls $bucket --recursive --region $region | sort| tail -n 1 | cut  -d " " -f1)
    printf "%-65s %-100s\n" "$bucket" "$latest" >> bucketinfo.txt
done

printf "%-65s %-100s\n" "BUCKET NAME" "LATEST UPATE" > s3buckets.txt
printf "%-65s %-100s\n" "---------------" "---------------" >> s3buckets.txt

sort -k2 -n bucketinfo.txt >> s3buckets.txt
rm buckets.txt
rm bucketinfo.txt
