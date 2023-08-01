#!/bin/bash

<<COMMENT
    This script deletes all snapshots that are not linked to an AMI in the configured region. You have the option to delete 'n'
    number of snapshots at a time by uncommenting lines 27 to 30 and changing the number to the desired amount. 
    At the end of this script, two files will be generated.
        - A file with the snapshot ids of the deleted snapshots (deletedsnapshots.txt)
        - A file with the snapshot ids of snapshots currently linked to an AMI
COMMENT

if  [ -f 'deletedsnapshots.txt' ]
then
    echo  "Removing deletedsnapshots.txt"
    rm deletedsnapshots.txt
fi

if [ -f inusesnapshots.txt ]
then
    echo "Removing inusesnapshots.txt"
    rm inusesnapshots.txt
fi

ACCOUNT=$(aws sts get-caller-identity --output yaml | grep Account | cut -d "'" -f2)
SNAPSHOTS=$(aws ec2 describe-snapshots --owner-ids $ACCOUNT --query "Snapshots[*].SnapshotId"| tr -d '"' | tr -d "," | tr -d ']' | tr -d '[')
AMIS=$(aws ec2 describe-images --owners $ACCOUNT --query 'Images[*].{ID:ImageId}')

count=0

for snapshot in $SNAPSHOTS;  do
    # if [[ "$count" == 5 ]]
    # then
    #     break
    # fi

    ami=$(aws ec2 describe-snapshots --snapshot-ids $snapshot --query "Snapshots[].Description" --output text| sed 's/^.*ami-/ami-/' | cut -d " " -f1)

    if [[ ${#ami} > 0 ]]
    then
        active=$(echo $AMIS | grep $ami  | wc  -l)

        if [[ "$active" -ne "0" ]]
        then
            echo "Can't delete snapshot --- $snapshot" >> inusesnapshots.txt
        else
            echo "Deleting snapshot --- $snapshot" >> deletedsnapshots.txt
            temp=$(aws ec2 delete-snapshot --snapshot-id $snapshot)        
        fi
    else
        echo "Deleting snapshot --- $snapshot" >> deletedsnapshots.txt
        temp=$(aws ec2 delete-snapshot --snapshot-id $snapshot)
    fi
   ((count=count+1))
done
