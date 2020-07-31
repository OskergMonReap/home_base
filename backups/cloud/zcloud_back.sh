#!/bin/bash
AMI=`cat /home/oskr_grme/.local/ami_id.txt`
MYIP=`dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'`
aws --profile zfs cloudformation create-stack --stack-name zcloud --template-body file:///home/oskr_grme/.local/zcloud.zfn.yml --parameters ParameterKey=AMI,ParameterValue=$AMI ParameterKey=MYIP,ParameterValue=$MYIP
sleep 300
INSTANCE=`aws --profile zfs cloudformation describe-stack-resource --stack-name zcloud --logical-resource-id ZFSInstance | jq '.StackResourceDetail.PhysicalResourceId' | sed -e 's/^"//' -e 's/"$//'`
IP=`aws --profile zfs ec2 describe-instances --instance-ids $INSTANCE --query "Reservations[*].Instances[*].PublicIpAddress" --output=text`
syncoid --sshkey=/home/oskr_grme/Downloads/new-zfs.pem --sshoption=StrictHostKeyChecking=no zroot ubuntu@$IP:zcloud/zroot
aws --profile zfs ec2 create-image --instance-id $INSTANCE --name "zcloud-$(date -I)" --description "Zcloud syncoid replication target, built on $(date -I'minutes')" | jq '.ImageId' | sed -e 's/^"//' -e 's/"$//'> /home/oskr_grme/.local/ami_id.txt
sleep 60
aws --profile zfs cloudformation delete-stack --stack-name zcloud
echo "ZFS replication to AWS successfully completed on $(date -I'minutes')" >> /home/oskr_grme/.local/logs/zcloud.log
