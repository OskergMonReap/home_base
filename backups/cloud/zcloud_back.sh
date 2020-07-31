#!/bin/bash
LOGFILE='/home/oskr_grme/.local/logs/zcloud.log'
AMI=`cat /home/oskr_grme/.local/ami_id.txt`
MYIP=`dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'`
if [ -n $AMI ]
then
    echo "Valid AMI ID collected: $AMI" >> $LOGFILE
else
    echo "Invalid AMI ID, please check ami_id.txt: $AMI" >> $LOGFILE
    exit 1
fi
if [ $MYIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]
then
    echo "Valid IP address for $HOSTNAME: $MYIP" >> $LOGFILE
else
    echo "Invalid IP address for $HOSTNAME: $MYIP" >> $LOGFILE
    exit 1
fi
echo "Starting ZFS replication to AWS: $(date -I'minutes')"
aws --profile zfs cloudformation create-stack --stack-name $HOSTNAME-zcloud --template-body file:///home/oskr_grme/.local/zcloud.zfn.yml --parameters ParameterKey=AMI,ParameterValue=$AMI ParameterKey=MYIP,ParameterValue=$MYIP > $LOGFILE 2>&1
sleep 300
INSTANCE=`aws --profile zfs cloudformation describe-stack-resource --stack-name $HOSTNAME-zcloud --logical-resource-id ZFSInstance | jq '.StackResourceDetail.PhysicalResourceId' | sed -e 's/^"//' -e 's/"$//'`
IP=`aws --profile zfs ec2 describe-instances --instance-ids $INSTANCE --query "Reservations[*].Instances[*].PublicIpAddress" --output=text`
if [ -n $INSTANCE ]
then
    echo "Valid ID from ec2 instance found: $INSTANCE" >> $LOGFILE
else
    echo "Invalid ID for ec2 instance: $INSTANCE" >> $LOGFILE
    exit 1
fi
if [ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]
then
    syncoid --sshkey=/home/oskr_grme/Downloads/new-zfs.pem --sshoption=StrictHostKeyChecking=no zroot ubuntu@$IP:zcloud/zroot > $LOGFILE 2>&1
else
    echo "Invalid IP address for EC2 instance: $IP" >> $LOGFILE
    exit 1
fi
aws --profile zfs ec2 create-image --instance-id $INSTANCE --name "zcloud-$HOSTNAME-$(date -I)" --description "Zcloud syncoid replication target, built on $(date -I'minutes') for $HOSTNAME" | jq '.ImageId' | sed -e 's/^"//' -e 's/"$//'> /home/oskr_grme/.local/ami_id.txt
sleep 60
aws --profile zfs cloudformation delete-stack --stack-name $HOSTNAME-zcloud > $LOGFILE 2>&1
echo "ZFS replication to AWS successfully completed on $(date -I'minutes')" >> $LOGFILE
