# AWS scheduled snapshot with retention period.

This can help you create your own backups of all AWS instances for free.

## First create scheduled snapshot.

Procedure: 
* Login to your ***AWS account***
* Open ***CloudWatch*** service
* Go to ***Rules*** section
* Create new Rule
* Under Event Source select ***Schedule*** option
* Then ***Cron expression***

Enter schedule:
```
To create snapshot hourly enter: 0 /1 * * ? *
```
```
To create snapshot daily enter: 0 0 * * ? *
```
```
To create snapshot monthly enter:  0 0 1 * ? *
```
```
To create snapshot yearly enter:  0 0 1 1 ? *
```

The sintaks is little bit different then on all contab generators.
Below the **Cron expression** should appear **Next 10 Trigger Date(s)**

On the right section **Targets** form drop down menu select: **EC2 CreateSnapshot API call**

**VolumeID**: Enter the Volume ID you want to backup.

To find Volume ID go to **Service** then **EC2** and on left side go to section **Elastic Block Store** and click on **Volumes**. 
Copy VolumeID you want to backup.

Then click on **Configure details**

On the next page you have to specify the name of this Rule.

If you receive the error the you probably haven't enter correct Cron expression

When you create scheduled backups it will continue creating new snapshots infinitely.

## Create snapshot retention period.

Login to one of your running instances.

First install: 
```
#sudo apt install ec2-api-tools
```
Run: 
```
#ec2-describe-snapshots
```
If you receive this message **"Client.UnauthorizedOperation: You are not authorized to perform this operation.”** then you have to create new policy and attach it to rule that is use by the instance you are running this command.

Rule:
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumeStatus",
                "ec2:DeleteSnapshot",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeTags",
                "ec2:DescribeSnapshotAttribute",
                "ec2:CreateTags",
                "ec2:DescribeVolumes",
                "ec2:CreateSnapshot",
                "ec2:DescribeSnapshots",
                "ec2:DescribeVolumeAttribute",
                "ec2:DescribeImportSnapshotTasks"
            ],
            "Resource": "*"
        }
    ]
}
```

By running this command you will get the list of all existing snapshots:
```
#ec2-describe-snapshots
```
Example:
```
SNAPSHOT        snap-0595e0c759881e88d  vol-000665368b5d22a3d   completed       2018-06-17T23:00:30+0000        100%    181423627383    30              Not Encrypted
```
## Delete snapshots 
If you have 50 snapshots and you want to keep last 10 snapshots or last 30 days then:

``
For 10 days **| sed 1,10d |**

For 30 days **| sed 1,30d |**
``

For 30 days:
```
#ec2-describe-snapshots | sort -k5M -k5dr | sed 1,30d |  awk '{print $2}' | xargs -n 1 -t ec2-delete-snapshot
```

If you have 50 snapshots and you want to keep first five (oldest five) including last 30 days:
```
#ec2-describe-snapshots | sort -k5M -k5dr | sed 1,30d | sort -k5M -k5d | sed 1,5d | awk '{print $2}' | xargs -n 1 -t ec2-delete-snapshot
```
## Create cron job:

```
crontab -e
```
example
```
55 1 * * * ec2-describe-snapshots | sort -k5M -k5dr | sed 1,30d | sort -k5M -k5d | sed 1,5d | awk '{print $2}' | xargs -n 1 -t ec2-delete-snapshot
```

## Restore:

To restore snapshot first you have to create volume from snapshot, then Detach volume form instace and attach new one.
