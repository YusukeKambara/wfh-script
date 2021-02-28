#!/bin/bash

# Get current global IP
GIP=`curl inet-ip.info`

# Get current security group info
TEMP_SG_ID=`aws ec2 describe-security-groups --filter Name=group-name,Values=$1 --output text --query SecurityGroups[0].GroupId`
TEMP_SG_IP_PERMISSIONS=`aws ec2 describe-security-groups --filter Name=group-name,Values=ykamba-temporary --query SecurityGroups[0].IpPermissions[0]`

# Remove current IP permissions into the security group
aws ec2 revoke-security-group-ingress --group-id ${TEMP_SG_ID} --ip-permissions "${TEMP_SG_IP_PERMISSIONS}"

# Register new IP permissions into the security group
IP_PERMISSIONS='{"IpProtocol": "tcp", "FromPort": 0, "ToPort": 65535, "IpRanges": [{"CidrIp": "'${GIP}'/32", "Description": "allow temporary access"}]}'
aws ec2 authorize-security-group-ingress --group-id ${TEMP_SG_ID} --ip-permissions "$IP_PERMISSIONS"
