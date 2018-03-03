# Lab 5 - Machine Learning containers and placement constraints
### Overview
After the quite simplistic image filtering using the ImageAssessor container, the catsndogs.lol Data Scientists want to deploy a machine learning container. This should be much better at identifying cats (and dogs!) in the images.
However, they only want to run it on EC2 instances with a large number of CPUs so it doesn’t interfere with the website.
In this lab, you will create a new task and configure an ECS custom constraint that uses built-in attributes. You will then create a new service with a custom placement strategy for the tasks within the service. This ensures the tasks are scheduled on container instances that meet the data science team’s requirements.
After completing this lab, you will understand how to use ECS placement constraints to schedule tasks on specific container instance types, and attach custom attributes to container instances, then use those attributes to constrain the placement of tasks.

### High-level Instructions
1.	Create a new task definition for MXNet. Add a container that uses the MXNet image from the catsndogs central ECR repository **205094881157.dkr.ecr.us-west-2.amazonaws.com/mxnet:latest** and set the container memory limit to 2048Mb.
a.	In the task definition, add a constraint that forces the MXNet tasks to run on a specific EC2 instance type. Pick an instance type and size that is currently running in your cluster. If the cluster contained a c4.large the expression would be:
`
attribute:ecs.instance-type == c4.large
`

2.	Create a new ECS service. Use the MXNet task, and run two copies of the task. Use the Task Placement **Placement templates** to create a custom placement strategy. This should first spread the tasks across Availability Zones, then spreads tasks across Instance Types, and finally BinPack tasks using Memory.
Do not use any load balancing.

3.	In the ECS console, find running MXNet tasks. Check the properties of the tasks and find the EC2 instances the tasks are running on. Verify the tasks are all running on the instances of the type you specified.

In addition to the built-in attributes of instance type, AMI, availability zone and operating system type, you can also constrain the placement of tasks using custom attributes. A custom attribute is metadata added to container instances. Each attribute has a name, and an optional string value. Management have asked that we enforce strict segregation between the cats and the dogs to stop the fighting with each other, which we can do with custom attributes.

4.	Add a custom attribute to one of the container instances in your cluster. You will then use that to constrain the cats tasks to run only on that instance. Container instance custom attributes are set in the properties of the container instance in the ECS cluster, or using the AWS CLI:
`
aws ecs put-attributes --cluster catsndogsECScluster --attributes "name=catslike,value=catnip,targetType=container-instance,targetId=<container_instance_id>" --region <your-region-name>
`

5.	Create a new revision of the cats task definition to include a new custom constraint that uses the custom attribute:
`
attribute:catslike == catnip
`

6.	Update the cats service to use the new task definition.

7.	Check that the new cats tasks are all scheduled on the container instance with the custom attribute.

You should now have the MXNet service running two containers on the specific instance type(s) and size(s) you constrained the task to.
One of the container instances should now have a custom attribute, and the cats tasks should have a custom constraint that forces them all to run on that container instance.
