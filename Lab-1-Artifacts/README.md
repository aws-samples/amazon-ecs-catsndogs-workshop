# Lab 1 - Cost management and EC2 scaling
### Overview
The catsndogs.lol environment has been running on a spare laptop, but today you will move everying to a new AWS ECS cluster.
Because the company is cost-conscious, the majority of our capacity will use EC2 Spot fleet instances. Because elasticity is also important, you will set up Auto Scaling for the Spot fleet to scale up and down as demand increases and decreases.
For long-term stability of core capacity, you will also add a small group of on-demand EC2 instances to the cluster.
At the end of this lab you will have an ECS cluster composed of Spot fleet instances with Auto Scaling enabled, and an on-demand instance from an Auto Scaling group.

### High-level Instructions
1.	In the ECS console, create a new ECS cluster. Use the cluster creation wizard to create a new cluster composed of Spot instances:

	a.	The cluster should be named **catsndogsECScluster**. This name is used in later labs, so if you name the cluster something else you will have to remember this when running later commands.

   	b.	Select several instance types from a range of instance types. It is recommended you use smaller instance sizes rather than large ones. For example: m4.large, c4.large, r4.large, i3.large. You may also use previous-generation families.

   	c.	Set a maximum bid price of $0.25.

   	d.	Set the number of instances to 3.

   	e.	Launch instances into the VPC named ECSVPC, using the private subnets.

   	f.	Use the security group with InstanceSecurityGroup in the name.

   	g.	For the Container Instance role, use the IAM Role with catsndogssetup-EC2Role in the name.

   	h.	For the Spot Fleet request role, use the catsndogssetup-SpotFleetTaggingRole

2.	Open the CloudFormation console and select the stack that has been created. Click the Template tab and look at the User Data for the EcsSpotFleet resource in the template. More information about this script can be found on the AWS Compute blog: https://aws.amazon.com/blogs/compute/powering-your-amazon-ecs-cluster-with-amazon-ec2-spot-instances/

3.	Create a CloudWatch alarm called **ScaleOut** that will be used to scale out the Spot fleet:

   	a.	Use the ECS metric MemoryReservation.

   	b.	The alarm should enter the ALARM state when the value is over 20% for more than two minutes. This will require changing the monitoring period.

   	c.	For the Statistic use the Standard metric Maximum.

   	d.	Delete the pre-created Notification action.

4.	Repeat step 3 to create a new alarm called **ScaleIn**. Have the alarm enter an ALARM state when the metric is below 20%.

5.	Set up Auto Scaling for the Spot fleet. Spot fleet Auto Scaling is a property of the Spot request, so this is located in the EC2 Console Spot Requests.

   	a. Set Auto Scaling to scale between 3 and 10 instances.

   	b. Create two Auto Scaling policies, one called ScaleUp and one called ScaleDown. You may have to click the link that says *Scale Spot fleet using step or simple scaling policies*

   	c. In the ScaleUp policy, use Define Steps to add 2 instances when the MemoryReservation is between 20 and 50, and add 3 instances when the MemoryReservation is over 50.

   	d. In the ScaleDown policy, use Define Steps to remove 1 instance when the MemoryReservation is between 10 and 20, and remove 2 instances when the MemoryReservation is below 10.

6.	Create an Auto Scaling group of on-demand instances to provide long-term core capacity for the ECS cluster. If you have used Auto Scaling groups with ECS before, you can launch a CloudFormation stack to create this automatically. The CloudFormation template is called `cfn-templates/Lab1-add-ondemand-asg-to-cluster.yml` If you have not used Auto Scaling groups with ECS, you can follow the steps below to learn how to do this:

7.	You will need a copy of the AMI ID of an instance that was launched when you created the ECS cluster earlier. You can find this from the properties of any of the Spot fleet instances.

8.	Create a new Launch Configuration:

   	a.	Use the AMI ID you copied in step 7.

   	b.	Use an m4.large instance type.

   	c.	Use the IAM Role with EC2InstanceProfile in the name.

   	d.	Paste in the following User Data:

		#!/bin/bash

		echo ECS_CLUSTER=catsndogsECScluster >> /etc/ecs/ecs.config

	e.	Use the security group with InstanceSecurityGroup in the name.

9.	Create an Auto Scaling group using the Launch Configuration you just created:

   	a.	Start with 1 instance.

   	b.	Launch instances into the VPC named ECSVPC, using the private subnets.

   	c.	Do not configure any scaling policies or notifications.

You should now have an ECS cluster composed of three instances from the Spot fleet request, and one instance from the on-demand Auto Scaling group.

# What's Next
[ECS Service deployment and task Auto Scaling](../Lab-2-Artifacts/)

# Detailed Instructions
[Cost management and EC2 scaling - Detailed Instructions](./lab1-detailed-steps.md)
