ec2-describe-snapshots | sort -k5M -k5dr | sed 1,10d |  awk '{print $2}' | xargs -n 1 -t ec2-delete-snapshot
