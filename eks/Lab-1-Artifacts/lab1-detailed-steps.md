# Lab 1 - Cost management and EC2 scaling - Detailed Steps

## 1.1	Create a new Kubernetes cluster using Spot Fleet

1.	Sign-in to the AWS management console and open the Amazon EKS console at https://console.aws.amazon.com/eks/.

2.	In the AWS Console, ensure you have the correct region selected. The instructor will tell you which region to use.

3.	In the EKS console click **Clusters**. Notice that a Kubernetes cluster control plane has already been deployed for you. 

4.	Click on the cluster container the term **catsndogssetup**. Here you can see some of the properties of your Kubernetes cluster.

**Note:** The cluster creation process will take approxi

## 1.2	Deploy Kubernetes worker nodes using Spoot Fleet

1.	Return to the AWS console home. In **Compute**, click **EC2**.

2.	Click **Spot Requests**.

3.  Click **Request Spot Instances**

4.  Click


7.	In **EC2 instance types** add several different instance types and sizes. We recommend you pick smaller instances sizes, such as:

    1. m4.large
    
    2. c4.large
    
    3. r4.large
    
    4. i3.large
    
**Note:** You can also pick older generation families such as m3.large..

8.	In **Maximum bid price (per instance/hour)** you can click the **Spot prices** link to view the current spot prices for the instance types and sizes you have selected. More information on how EC2 Spot instance pricing works is available on the Amazon EC2 Spot Instances Pricing page: https://aws.amazon.com/ec2/spot/pricing/

9.	Enter a maximum bid price. For the purposes of the workshop, $0.25 should offer an excellent chance of your Spot bid being fulfilled. It does not matter if your spot bid is not fulfilled. In a later step you will add an on-demand instance to the cluster.

10.	In **Number of instances** enter **3**.

11.	In **Key pair** select an existing EC2 Key pair for which you have the private key.

12.	In **VPC** select **ECSVPC**.

13.	In **Subnets** select all subnets containing the word **Private**.

14.	In **Security group**, select the Security Group containing the term **InstanceSecurityGroup**.

15.	In **Container Instance IAM role** select the IAM role containing the term **catsndogssetup-EC2Role**.

16.	In **IAM role for a Spot Fleet request** select the role with a name containing **catsndogssetup-SpotFleetTaggingRole**.

17.	Click **Create**.

18.	You will see the cluster creation steps appear. The final step is the creation of a CloudFormation stack. Note the name of this stack.

19.	Open the AWS console in a new browser tab and under **Management Tools**, click **CloudFormation**.

20.	Select the checkbox for the CloudFormation stack, and click the **Template** tab.

21.	The ECSSpotFleet resource has a Property named **LaunchSpecifications**, which contains **UserData**. This is about half way down the template. This UserData creates a termination watcher script described below. You will not be able to see the contents directly from the CloudFormation console.

**Note:** This script creates a Spot instance termination notice watcher script on each EC2 instance. That watcher script runs on each instance every two minutes. It polls the EC2 instance metadata service for a Spot termination notice. If the instance is scheduled for termination (because you have been outbid) the script sends a command to the ECS service to put itself into a DRAINING state. This prevents new tasks being scheduled on the instance, and if capacity is available in the cluster, ECS will start replacement tasks on other instances within the cluster.

More information about this script can be found on the AWS Compute blog: https://aws.amazon.com/blogs/compute/powering-your-amazon-ecs-cluster-with-amazon-ec2-spot-instances/

More information about the ECS DRAINING state can be found in the ECS documentation: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/container-instance-draining.html

## 1.2	Set up Auto Scaling for the Spot fleet

In this task we will set up Auto Scaling for the Spot fleet, to provide cost-effective elasticity for the ECS Container Instances. Auto Scaling will use the ECS cluster MemoryReservation CloudWatch metric to scale the number of EC2 instances in the Spot fleet.

1.	In the AWS Console **Management Tools** section click **CloudWatch**.

2.	Click **Alarms**, then click **Create Alarm** to create an alarm for scaling out.

3.	Click **ClusterName** under ECS Metrics.

4.	Select the **MemoryReservation** metric for the cluster you created earlier, then click **Next**. It might take a minute or two for this new metric to appear in the CloudWatch console. If the metric is not yet listed, refresh the page and try again.

5.	Give the alarm a name, for example **ScaleUpSpotFleet**.

6.	Fill in the following under **Whenever: MemoryReservation**:

    1. Is: **>= 20**
    
    2. For: **2** out of 2 datapoints

7.	For the **Period** select **1 minute**.

8.	For the **statistic** select **Standard, Maximum**.

9.	In **Actions**, delete the pre-created Notification action.

10.	Click **Create Alarm**.

11.	Click **Create Alarm** to create the alarm for scaling in.

12.	Click **ClusterName** under ECS Metrics.

13.	Select the **MemoryReservation** metric for the cluster you created earlier, then click **Next**.

14.	Give the alarm a name, for example **ScaleDownSpotFleet**.

15.	Fill in the following under **Whenever: MemoryReservation**:

    1. Is: **<= 20**
    
    2. For: **2** out of 2 datapoints
    
16.	For the **Period** select **1 minute**.

17.	For the **statistic** select **Standard, Maximum**.

18.	In **Actions**, delete the pre-created Notification action.

19.	Click **Create Alarm**.

20.	Return to the AWS console home. In **Compute**, click **EC2**.

21.	Click **Spot Requests**.

22.	Select the checkbox by the Spot request.

23.	Click the Auto Scaling tab in the lower pane, then click **Configure**.

24.	In **Scale capacity** between, set **3 and 10** instances.

25.	Under **Scaling policies**, click the **Scale Spot Fleet using step or simple scaling policies** option

26.	In Scaling policies first update the ScaleUp policy:

    1. In **Policy Trigger** select the **ScaleUpSpotFleet** alarm you created earlier.
    
    2. Click **Define steps**.
    
    3. Click **Add step**.
    
    4. In **Modify Capacity**:
        
        1. Add 2 instances when 20 <= MemoryReservation <= 50
        
        2. Add 3 instances when 50 <= MemoryReservation <= infinity

27.	Then update the ScaleDown policy:
    
    1. In **Policy Trigger** select the **ScaleDownSpotFleet** alarm you created earlier.
    
    2. Click **Define steps**.
    
    3. Click **Add step**.
    
    4. In **Modify Capacity**:
    
        1. Remove 1 instances when 20 >= MemoryReservation > 10
        
        2. Remove 2 instances when 10 >= MemoryReservation > -infinity

28.	Click **Save**

More details on Auto Scaling for Spot fleet is available in the Spot Instances documentation: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-fleet-automatic-scaling.html

## 1.3	Add an On-Demand Auto Scaling group to the cluster

In this task you will create an Auto Scaling group composed of two EC2 instances. If the Spot price goes above the maximum bid price, some or all of the Spot instances could be terminated. By using on-demand instances as well as Spot instances, you ensure the cluster will have capacity even if the Spot instances are terminated.

**Note:** For ECS clusters that will operate for a year or more, EC2 Reserved Instances provide both a capacity reservation and lower price per hour. We will not use Reserved Instances in this workshop but you should consider them for long-lived clusters.

If you have used Auto Scaling groups with ECS before, you can launch a CloudFormation stack that creates the resources below automatically. The CloudFormation template is called **Lab1-add-ondemand-asg-to-cluster.yml**. If you have not used Auto Scaling groups with ECS, you can follow the steps below to learn how to do this.

1.	In the AWS Console **Compute** section click **EC2**, then click **Instances**.

2.	Right click on an instance and click **Launch more like this**.

3.	At the top of the console click **Choose Instance Type**.

4.	Select the **m4.large** instance type.

5.	Click **Configure Instance**. If you receive a pop-up dialog, select “Yes, I want to continue with this instance type (m4.large)” and click **Next**.

6.	Beside **Number of instances** click **Launch into Auto Scaling Group**.

7.	In the pop-up dialog click **Create Launch Configuration**. This launches the Auto Scaling Launch Configuration wizard and preserves the AMI and instance type and size.

8.	In the **Configure Details** step enter **On-Demand-ECS** as the name.

9.	In IAM role select the IAM role containing the term **EC2InstanceProfile**.

10.	Expand Advanced Details. Copy the following text and paste it into the User data dialog box. This controls which ECS cluster the instance will join:

```
#!/bin/bash
echo ECS_CLUSTER=catsndogsECScluster >> /etc/ecs/ecs.config
```

11.	Click **Next: Add storage**.

12.	Click **Next: Configure Security Group**.

13.	Click **Select an existing security group** and choose the Security Group containing the term **InstanceSecurityGroup**.

14.	Click **Review** then click **Create launch configuration**.

15.	In the pop-up dialog, select **Choose an existing key pair**, then select an EC2 key pair that you have the private key for. Click the checkbox and then click **Create launch configuration**.

16.	The completes the Launch Configuration wizard and starts the Auto Scaling Group wizard. In Group name, enter **ECS-On-Demand-Group**.

17.	In **Network**, select the **ECSVPC**.

18.	In **Subnet** select all subnets containing the word **Private**. Click **Next: Configure scaling policies**.

19.	Click **Review**.

20.	Click **Create Auto Scaling group**, then click **Close**.

21.	Return to the AWS Console and in the **Compute** section, click **EC2 Container Service**.

22.	Click the ECS cluster **catsndogsECScluster**.

23.	Click the **ECS Instances** tab and wait until the On-Demand instance appears in the list. You can continue the next task once the instance appears. If the instance does not appear within a few minutes, check the configuration of the Launch Configuration, specifically the **User data** script and the **VPC and subnet** selections.

You should now have an ECS cluster composed of three instances from the Spot fleet request, and one instance from the on-demand Auto Scaling group.

# What's Next
[ECS Service deployment and task Auto Scaling](../Lab-2-Artifacts/)
