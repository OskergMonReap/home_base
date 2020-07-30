#!/bin/bash
AMI=`cat /home/oskr_grme/.local/ami_id.txt`
aws cloudformation create-stack --stack-name zcloud --template-body file://home/oskr_grme/.local/zcloud.cfn --parameters ParameterKey=AMI,ParameterValue=$AMI
sleep 500
INSTANCE=`aws cloudformation describe-stack-resource --stack-name zcloud --logical-resource-id ZFSInstance | jq '.StackResourceDetail.PhysicalResourceId'`
IP=`aws ec2 describe-instances --instances $INSTANCE --query "Reservations[*].Instances[*].PublicIpAddress" --output=text`
syncoid zroot ubuntu@$IP:zcloud/zroot
aws ec2 create-image --instance-id $INSTANCE --name "zcloud-$(date -I)" --description "Zcloud syncoid replication target, built on $(date -I'minutes')" | jq '.ImageId' > /home/oskr_grme/.local/ami_id.txt
sleep 60
aws cloudformation delete-stack --stack-name zcloud
echo "ZFS replication to AWS successfully completed on $(date -I'minutes')" >> /home/oskr_grme/.local/logs/zcloud.log
