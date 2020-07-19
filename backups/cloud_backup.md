# Offsite Backups
Local backups galore is nice, but to truly have piece of mind against even a catastrophe that somehow would take out all my devices, remote backups is a must.
AWS provides several storage services, and I will be exploring the best for my use cases. Below is a list of solutions I've come up with that I will be testing.

### Solution 1
Design: 
- Custom AMI with ZFS, sanoid/syncoid installed
- Local script triggered on a timer via cron
  - Use Cloudformation to spin up EC2 instance in us-east-2 based on our custom AMI
  - Verify server is up/reachable, trigger syncoid to replicate ZFS snapshots to the instance
  - Delete Cloudformation stack
