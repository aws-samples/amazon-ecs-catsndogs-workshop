# Lab 1 - Cost management and EC2 scaling - Detailed Steps

## 1.1	Create a new ECS cluster using Spot filename

1.	Sign-in to the AWS management console and open the Amazon ECS console at https://console.aws.amazon.com/ecs/.

2.	In the AWS Console, ensure you have the correct region selected. The instructor will tell you which region to use.

3.	In the ECS console click Clusters, then click Create Cluster.

4.	In Cluster name, type catsndogsECScluster as the cluster name. This name is used in later labs. If you name the cluster something else you will have to remember this when running later commands.

5.	In Provisioning Model select Spot. 

6.	Leave Spot Instance allocation strategy as Diversified.

7.	In EC2 instance types add several different instance types and sizes. We recommend you pick smaller instances sizes, such as:

    1. m4.large
    
    2. c4.large
    
    3. r4.large
    
    4. i3.large
    
**Note:** You can also pick older generation families such as m3.large..

8.	In Maximum big price (per instance/hour) you can click the Spot prices link to view the current spot prices for the instance types and sizes you have selected. More information on how EC2 Spot instance pricing works is available on the Amazon EC2 Spot Instances Pricing page: https://aws.amazon.com/ec2/spot/pricing/

9.	Enter a maximum bid price. For the purposes of the workshop, $0.25 should offer an excellent chance of your Spot bid being fulfilled. It does not matter if your spot bid is not fulfilled. In a later step you will add an on-demand instance to the cluster.

10.	In Number of instances enter 3.

11.	In Key pair select an existing EC2 Key pair for which you have the private key.

12.	In VPC select ECSVPC.

13.	In Subnets select all subnets containing the word Private.

14.	In Security group, select the Security Group containing the term InstanceSecurityGroup.

15.	In Container Instance IAM role select the IAM role containing the term catsndogssetup-EC2Role.

16.	In IAM role for a Spot Fleet request select the role with a name containing catsndogssetup-SpotFleetTaggingRole.

17.	Click Create.

18.	You will see the cluster creation steps appear. The final step is the creation of a CloudFormation stack. Note the name of this stack.

19.	Open the AWS console in a new browser tab and under Management Tools, click CloudFormation.

20.	Select the checkbox for the CloudFormation stack, and click the Template tab.

21.	The ECSSpotFleet resource has a Property named LaunchSpecifications, which contains UserData. This is about half way down the template.

**Note:** This script creates a Spot instance termination notice watcher script on each EC2 instance. That watcher script runs on each instance every two minutes. It polls the EC2 instance metadata service for a Spot termination notice. If the instance is scheduled for termination (because you have been outbid) the script sends a command to the ECS service to put itself into a DRAINING state. This prevents new tasks being scheduled on the instance, and if capacity is available in the cluster, ECS will start replacement tasks on other instances within the cluster.

More information about this script can be found on the AWS Compute blog: https://aws.amazon.com/blogs/compute/powering-your-amazon-ecs-cluster-with-amazon-ec2-spot-instances/

More information about the ECS DRAINING state can be found in the ECS documentation: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-draining.html

## 1.2	Set up Auto Scaling for the Spot fleet

In this task we will set up Auto Scaling for the Spot fleet, to provide cost-effective elasticity for the ECS Container Instances. Auto Scaling will use the ECS cluster MemoryReservation CloudWatch metric to scale the number of EC2 instances in the Spot fleet.

1.	In the AWS Console Management Tools section click CloudWatch.

2.	Click Alarms, then click Create Alarm to create an alarm for scaling out.

3.	Click ClusterName under ECS Metrics.

4.	Select the MemoryReservation metric for the cluster you created earlier, then click Next. It might take a minute or two for this new metric to appear in the CloudWatch console. If the metric is not yet listed, refresh the page and try again.

5.	Give the alarm a name, for example ScaleUpSpotFleet.

6.	Fill in the following under Whenever: MemoryReservation:

    1. Is: >= 20
    
    2. For: 2 consecutive period(s)

7.	For the Period select 1 minute.

8.	For the statistic select Standard, Maximum.

9.	In Actions, delete the pre-created Notification action.

10.	Click Create Alarm.

11.	Click Create Alarm to create the alarm for scaling in.

12.	Click ClusterName under ECS Metrics.

13.	Select the MemoryReservation metric for the cluster you created earlier, then click Next.

14.	Give the alarm a name, for example ScaleDownSpotFleet.

15.	Fill in the following under Whenever: MemoryReservation:

    1. Is: <= 20
    
    2. For: 2 consecutive period(s)
    
16.	For the Period select 1 minute.

17.	For the statistic select Standard, Maximum.

18.	In Actions, delete the pre-created Notification action.

19.	Click Create Alarm.

20.	Return to the AWS console home. In Compute, click EC2.

21.	Click Spot Requests.

22.	Select the checkbox by the Spot request.

23.	Click the Auto Scaling tab in the lower pane, then click Configure.

24.	In Scale capacity between, set 3 and 10 instances.

25.	Under Scaling policies, click the Scale Spot Fleet using step or simple scaling policies option

26.	In Scaling policies first update the ScaleUp policy:

    1. In Policy Trigger select the ScaleUpSpotFleet alarm you created earlier.
    
    2. Click Define steps.
    
    3. Click Add step.
    
    4. In Modify Capacity:
        
        1. Add 2 instances when 20 <= MemoryReservation <= 50
        
        2. Add 3 instances when 50 <= MemoryReservation <= infinity



https://github.com/aws-samples/amazon-ecs-catsndogs-workshop/issues/7 