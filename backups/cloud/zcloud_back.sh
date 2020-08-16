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
    LOGFILE=$LOGFILE
    echo "INFO: Parameter for logfile passed to script, succesfully set." >> $LOGFILE
else
    LOGFILE='/home/oskr_grme/.local/logs/zcloud.log'
fi
echo "INFO: Logfile set to: $LOGFILE" >> $LOGFILE

echo "ZCloud Backup script is starting at $(date -I'minutes' | sed 's/......$//')" >> $LOGFILE

if [[ -n $POOL ]]
then
    POOL=$POOL
    echo "INFO: Parameter for ZFS pool passed to script, succesfully set." >> $LOGFILE
else
    POOL=zroot
fi
echo "INFO: Replication source set to pool: $POOL" >> $LOGFILE

if [[ -n $AMI ]]
then
    AMI=$AMI
    echo "INFO: Parameter for ZFS pool passed to script, succesfully set." >> $LOGFILE
else
    AMI=`cat /home/oskr_grme/.local/ami_id.txt`
fi
echo "INFO: EC2 instance AMI ID set to: $AMI" >> $LOGFILE

MYIP=`dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'`

if [[ $AMI =~ ^(ami)-[a-zA-Z0-9]*$ ]]
then
    echo "INFO: Valid AMI ID collected: $AMI" >> $LOGFILE
else
    echo "ERROR: Invalid AMI ID, please check ami_id.txt: $AMI" >> $LOGFILE
    echo "Script failed due to invalid or malformed AMI ID. Exiting..." >> $LOGFILE
    exit 1
fi

if [[ $MYIP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
    echo "INFO: Valid IP address for $HOSTNAME: $MYIP" >> $LOGFILE
else
    echo "ERROR: Invalid IP address for $HOSTNAME: $MYIP" >> $LOGFILE
    echo "Script failed due to invalid or malformed IP Address. Exiting..." >> $LOGFILE
    exit 1
fi

echo "INFO: Starting creation of CloudFormation stack..." >> $LOGFILE
aws --profile zfs cloudformation create-stack --stack-name $HOSTNAME-zcloud --template-body file:///home/oskr_grme/.local/zcloud.cfn.yml --parameters ParameterKey=AMI,ParameterValue=$AMI ParameterKey=MYIP,ParameterValue=$MYIP >> $LOGFILE 2>&1
echo "INFO: CloudFormation stack succesfully launched" >> $LOGFILE
echo "INFO: Cooldown reached, allowing resources time to bootstrap. Sleeping for 300 seconds..." >> $LOGFILE

sleep 300

echo "INFO: Starting ZFS replication to AWS: $(date -I'minutes' | sed 's/......$//')" >> $LOGFILE

INSTANCE=`aws --profile zfs cloudformation describe-stack-resource --stack-name $HOSTNAME-zcloud --logical-resource-id ZFSInstance | jq '.StackResourceDetail.PhysicalResourceId' | sed -e 's/^"//' -e 's/"$//'`

IP=`aws --profile zfs ec2 describe-instances --instance-ids $INSTANCE --query "Reservations[*].Instances[*].PublicIpAddress" --output=text`

if [[ $INSTANCE =~ ^i-[a-zA-Z0-9]*$ ]]
then
    echo "INFO: Valid ID from ec2 instance found: $INSTANCE" >> $LOGFILE
else
    echo "ERROR: Invalid ID for ec2 instance: $INSTANCE" >> $LOGFILE
    echo "Script failed due to invalid or malformed Instance ID. Exiting..." >> $LOGFILE
    exit 1
fi

if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
then
    syncoid -- quiet --sshkey=/home/oskr_grme/.ssh/zfsbackup.pem --sshoption=UserKnownHostsFile=/dev/null --sshoption=StrictHostKeyChecking=no $POOL ubuntu@$IP:zcloud/$POOL >> $LOGFILE 2>&1
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

echo "INFO: New AMI, $NEW_AMI, is in progress.. succesfully started process" >> $LOGFILE

sleep 60

aws --profile zfs cloudformation delete-stack --stack-name $HOSTNAME-zcloud >> $LOGFILE 2>&1

echo "INFO: ZFS replication to AWS successfully completed on $(date -I'minutes' | sed 's/......$//')" >> $LOGFILE

echo "-------------------------------------------" >> $LOGFILE
