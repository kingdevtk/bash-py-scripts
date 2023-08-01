#!/bin/bash
<<comment
    This script prints out the status of the target groups associated with a specific VPC accociated with an AWS account. It takes in
    the following arguements.
        - vpc_id (required)
        - profile (optional)

    Examples:
        bash target_group_status.sh VPC_ID
        bash target_group_status.sh VPC_ID PROFILE
comment

vpc=$1

if [[ -z $2 ]] 
then
    profile=""
else
    profile="--profile $2"
fi


TARGET_GROUPS=$(aws elbv2 describe-target-groups --query "TargetGroups[?VpcId=='"$vpc"'].TargetGroupArn" $profile| tr -d '"' | tr -d "," | tr -d ']' | tr -d '[')

for group in $TARGET_GROUPS; do
    STATUS=$(aws elbv2 describe-target-health --target-group-arn $group --query "TargetHealthDescriptions[].TargetHealth" --output yaml $profile)
    echo $group
    echo $STATUS
    echo "-----------------------------"
done
