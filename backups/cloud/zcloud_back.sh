#!/bin/bash
while getopts p:l:a: option
do
case "${option}"
in
p) POOL=${OPTARG};;
l) LOGFILE=${OPTARG};;
a) AMI=${OPTARG};;
esac
done


if [[ -n $LOGFILE ]]
then
    echo "INFO: Logfile set to: $LOGFILE" >> $LOGFILE
else
    LOGFILE='/home/oskr_grme/.local/logs/zcloud.log'
    echo "INFO: Logfile set to: $LOGFILE" >> $LOGFILE
fi

echo "ZCloud Backup script is starting at $(date -I'minutes' | sed 's/......$//')" >> $LOGFILE

if [[ -n $POOL ]]
then
    echo "INFO: Replication source set to pool: $POOL"
else
    POOL=zroot
    echo "INFO: Replication source set to pool: $POOL"
fi

if [[ -n $AMI ]]
then
    echo "INFO: EC2 instance AMI ID set to: $AMI"
else
    AMI=`cat /home/oskr_grme/.local/ami_id.txt`
    echo "INFO: EC2 instance AMI ID set to: $AMI"
fi

MYIP=`dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'`

if [[ $AMI =~ ^(ami)-[a-zA-Z0-9]*$ ]]
then
    echo "INFO: Valid AMI ID collected: $AMI" >> $LOGFILE
else
    echo "ERROR: Invalid AMI ID, please check ami_id.txt: $AMI" >> $LOGFILE
    exit 1
fi

if [[ $MYIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
    echo "INFO: Valid IP address for $HOSTNAME: $MYIP" >> $LOGFILE
else
    echo "ERROR: Invalid IP address for $HOSTNAME: $MYIP" >> $LOGFILE
    exit 1
fi

echo "INFO: Starting ZFS replication to AWS: $(date -I'minutes' | sed 's/......$//')" >> $LOGFILE

aws --profile zfs cloudformation create-stack --stack-name $HOSTNAME-zcloud --template-body file:///home/oskr_grme/.local/zcloud.cfn.yml --parameters ParameterKey=AMI,ParameterValue=$AMI ParameterKey=MYIP,ParameterValue=$MYIP >> $LOGFILE 2>&1

sleep 300

INSTANCE=`aws --profile zfs cloudformation describe-stack-resource --stack-name $HOSTNAME-zcloud --logical-resource-id ZFSInstance | jq '.StackResourceDetail.PhysicalResourceId' | sed -e 's/^"//' -e 's/"$//'`

IP=`aws --profile zfs ec2 describe-instances --instance-ids $INSTANCE --query "Reservations[*].Instances[*].PublicIpAddress" --output=text`

if [[ $INSTANCE =~ ^i-[a-zA-Z0-9]*$ ]]
then
    echo "INFO: Valid ID from ec2 instance found: $INSTANCE" >> $LOGFILE
else
    echo "ERROR: Invalid ID for ec2 instance: $INSTANCE" >> $LOGFILE
    exit 1
fi

if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
    syncoid -R --sshkey=/home/oskr_grme/.ssh/zfsbackup.pem --sshoption=LogLevel=ERROR --sshoption=UserKnownHostsFile=/dev/null --sshoption=StrictHostKeyChecking=no $POOL ubuntu@$IP:zcloud/$POOL >> $LOGFILE 2>&1
else
    echo "ERROR: Invalid IP address for EC2 instance: $IP" >> $LOGFILE
    exit 1
fi

aws --profile zfs ec2 create-image --instance-id $INSTANCE --name "zcloud-$HOSTNAME-$(date -I'minutes' | sed 's/......$//')" --description "Zcloud syncoid replication target, built on $(date -I'minutes' | sed 's/......$//') for $HOSTNAME" | jq '.ImageId' | sed -e 's/^"//' -e 's/"$//'> /home/oskr_grme/.local/ami_id.txt

NEW_AMI=`cat /home/oskr_grme/.local/ami_id.txt`

if [[ $NEW_AMI =~ ^(ami)-[a-zA-Z0-9]*$ ]]
then
    echo "INFO: New AMI creation has started! At $(date -I'minutes' | sed 's/......$//') $NEW_AMI was triggered" >> $LOGFILE
    aws --profile zfs ec2 create-tags --resources $NEW_AMI --tags Key=\"Name\",Value=\"$HOSTNAME\ $POOL\ $(date -I'minutes' | sed 's/......$//')\" >> $LOGFILE 2>&1
else
    echo "ERROR: Invalid AMI ID, please check ami_id.txt: $AMI" >> $LOGFILE
    exit 1
fi

echo "INFO: New AMI, $NEW_AMI, is in progress.. succesfully started process" >> $LOGFILE 2>&1

sleep 60

aws --profile zfs cloudformation delete-stack --stack-name $HOSTNAME-zcloud >> $LOGFILE 2>&1

echo "INFO: ZFS replication to AWS successfully completed on $(date -I'minutes' | sed 's/......$//')" >> $LOGFILE

echo "-------------------------------------------" >> $LOGFILE
