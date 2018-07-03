# Lab 2 - ECS Service deployment and task Auto Scaling
### Overview
Now you have an ECS cluster running, you need to deploy the catsndogs.lol tasks and services. You also need to test the deployment works, and run a load test against the system to ensure it scales as expected.
You will deploy an ECS service for the homepage, and separate ECS services for cats and dogs. Having separate ECS services allows catsndogs.lol to scale the cats and dogs services separately based on demand.
You will set up Task Auto Scaling with proportional scaling actions. Multiple scaling actions allows ECS to respond by rapidly adding more tasks if the system comes under heavy load quickly.
Once the services and Auto Scaling are set up, you will launch a load generator that targets the cats and dogs pages. This will cause the services to scale up, which will also cause the Spot Fleet instances to scale up.

### High-level Instructions
1.	Deploy a CloudFormation stack called *catsndogsECStasksandservices* to create the ECS tasks and services for catsndogs.lol, as well as the CloudWatch alarms that will be used for Task Auto Scaling. The template for this is called `cfn-templates/Lab2-create-ecs-tasks-and-services.yml`

2.	Find the load balancer with **catsn-catsn** in the name. Copy the DNS name into your browser and validate that the site works.

3.	In the ECS Console, select the cats service and enable Task Auto Scaling. Set the minimum number of tasks to 2 and the maximum of 100. Select the role with **ECSAutoScaleRole** in it's name.

    a. Create a policy called ScaleUp. Use the alarm with "CatsScaleUp" in the name. Add steps to the scaling policy. The first step should add 10 tasks when the load is between 1000 and 2000. The second should add 20 tasks when the load is between 2000 and 4000. The third should add 25 tasks when the load is over 4000.

    b. Create a policy called ScaleDown. Use the alarm with "CatsScaleDown" in the name. Add steps to the scaling policy. The first step should remove 10 tasks when the load is between 1000 and 100. The second should remove 5 tasks when the load is under 100.

4.	Repeat step 3 for the dogs service.

5.	Deploy a second CloudFormation stack to generate load against the website. The template for this is called `cfn-templates/Lab2-loadgenerator.yml`

6.	In CloudWatch view the metric RequestCount for the load balancer’s Target Groups. Ensure you set the Statistic to Sum, and the Period to 10 seconds.

7.	Check the CloudWatch alarms for scaling up the cats and dogs services. They should enter ALARM state two to three minutes after the threshold is first breached.

8.	In the ECS console, check that the ECS services are adding more tasks in response to the load. The Events tab for each service will show information about new task launches.

9.	In CloudWatch, check the ScaleUp alarm which is triggered by the cluster’s MemoryReservation metric. This should move into ALARM state as tasks are added to the ECS services, causing the amount of reserved memory to increase.

10.	Once the ScaleUp alarm is triggered, check the Spot fleet Auto Scaling history. Instances should be added to the Spot fleet

11.	Check the cluster’s ECS Instances tab, to see that the new instances have joined the ECS cluster.

12.	Once you have seen the Spot fleet scale up, stop the LoadGenerator EC2 instance.

You should now have ECS Services defined for cats and dogs, and seen how ECS task Auto Scaling and EC2 Auto Scaling help as the system comes under load.

# What's Next
[Deploying a new version of the cats service with secrets management](../Lab-3-Artifacts/)

# Detailed Instructions
[ECS Service deployment and task Auto Scaling - Detailed Instructions](./lab2-detailed-steps.md)
