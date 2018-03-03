# Workshop overview
Welcome to catsndogs.lol, the fifth most highly rated cat and dog meme sharing website in Australia and New Zealand. Our mission is to serve a wide range quality of cat and dog memes to our customers. Memes come and go quickly, and we are starting to see larger and larger surges in customer demand.
catsndogs.lol uses Docker containers to host our application. Until today we’ve run everything on a spare laptop, but now we’re moving to the Amazon Elastic Container Service (ECS). Our DevOps Shepherd wants to take advantage of the latest and greatest features of the ECS platform. We also have several new initiatives that the developers and data science teams are keen to release.
As the new DevOps team, you will create the ECS environment, deploy the cats and dogs applications, cope with our hoped-for scaling issues, and enable the other teams to release new features to make our customers happier than ever.
**Welcome aboard!**



# Initial environment setup

### Prerequisites
This workshop requires:
- A laptop with Wi-Fi running Microsoft Windows, Mac OS X, or Linux.
- The AWSCLI installed.
- An Internet browser such as Chrome, Firefox, Safari, or Edge.
- An AWS account. You will create AWS resources including IAM roles during the workshop.
- An EC2 key pair created in the AWS region you are working in.

### Initial Setup
1.	Download and extract the workshop materials zip from http://docs.catsndogs.lol/materials.zip This contains the CloudFormation templates and other materials you will need during the workshop.

2.	If you do not already have an EC2 keypair created, sign-in to the AWS EC2 console at https://console.aws.amazon.com/ec2/
a.	Click Key Pairs and then click Create Key Pair.
b.	Give the key pair a name and click Create. The console will generate a new key pair and download the private key. Keep this somewhere safe.

2.	Deploy the initial CloudFormation template. This creates IAM roles, an S3 bucket, and other resources that you will use in later labs. The template is called `Lab0-baseline-setup.yml` If you are sharing an AWS account with someone else doing the workshop, only one of you needs to create this stack. 
In Stack name, enter **catsndogssetup**. Later labs will reference this stack by name, so if you choose a different stack name you will need to change the *LabSetupStackName* parameter in later labs. 

3.	Be sure to tick the *I acknowledge that AWS CloudFormation might create IAM resources with custom names* check box.	



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

6.	Create an Auto Scaling group of on-demand instances to provide long-term core capacity for the ECS cluster. If you have used Auto Scaling groups with ECS before, you can launch a CloudFormation stack to create this automatically. The CloudFormation template is called `Lab1-add-ondemand-asg-to-cluster.yml` If you have not used Auto Scaling groups with ECS, you can follow the steps below to learn how to do this:

7.	You will need a copy of the AMI ID of an instance that was launched when you created the ECS cluster earlier. You can find this from the properties of any of the Spot fleet instances.

8.	Create a new Launch Configuration:
a.	Use the AMI ID you copied in step 7.
b.	Use an m4.large instance type.
c.	Use the IAM Role with EC2InstanceProfile in the name.
d.	Paste in the following User Data:
`
#!/bin/bash
`
`echo ECS_CLUSTER=catsndogsECScluster >> /etc/ecs/ecs.config
`
e.	Use the security group with InstanceSecurityGroup in the name.

9.	Create an Auto Scaling group using the Launch Configuration you just created:
a.	Start with 1 instance.
b.	Launch instances into the VPC named ECSVPC, using the private subnets.
c.	Do not configure any scaling policies or notifications.

You should now have an ECS cluster composed of three instances from the Spot fleet request, and one instance from the on-demand Auto Scaling group.



# Lab 2 - ECS Service deployment and task Auto Scaling
### Overview	
Now you have an ECS cluster running, you need to deploy the catsndogs.lol tasks and services. You also need to test the deployment works, and run a load test against the system to ensure it scales as expected.
You will deploy an ECS service for the homepage, and separate ECS services for cats and dogs. Having separate ECS services allows catsndogs.lol to scale the cats and dogs services separately based on demand.
You will set up Task Auto Scaling with proportional scaling actions. Multiple scaling actions allows ECS to respond by rapidly adding more tasks if the system comes under heavy load quickly.
Once the services and Auto Scaling are set up, you will launch a load generator that targets the cats and dogs pages. This will cause the services to scale up, which will also cause the Spot Fleet instances to scale up.

### High-level Instructions
1.	Deploy a CloudFormation stack called *catsndogsECStasksandservices* to create the ECS tasks and services for catsndogs.lol, as well as the CloudWatch alarms that will be used for Task Auto Scaling. The template for this is called `Lab2-create-ecs-tasks-and-services.yml`

2.	Find the load balancer with **catsn-catsn** in the name. Copy the DNS name into your browser and validate that the site works.

3.	In the ECS Console, select the cats service and enable Task Auto Scaling. Set the minimum number of tasks to 2 and the maximum of 100. Select the role with **ECSAutoScaleRole** in it's name.
a. Create a policy called ScaleUp. Use the alarm with "CatsScaleUp" in the name. Add steps to the scaling policy. The first step should add 10 tasks when the load is between 1000 and 2000. The second should add 20 tasks when the load is between 2000 and 4000. The third should add 25 tasks when the load is over 4000.
b. Create a policy called ScaleDown. Use the alarm with "CatsScaleDown" in the name. Add steps to the scaling policy. The first step should remove 10 tasks when the load is between 1000 and 100. The second should remove 5 tasks when the load is under 100.

4.	Repeat step 3 for the dogs service.

5.	Deploy a second CloudFormation stack to generate load against the website. The template for this is called `Lab2-loadgenerator.yml`

6.	In CloudWatch view the metric RequestCount for the load balancer’s Target Groups. Ensure you set the Statistic to Sum, and the Period to 10 seconds.

7.	Check the CloudWatch alarms for scaling up the cats and dogs services. They should enter ALARM state two to three minutes after the threshold is first breached.

8.	In the ECS console, check that the ECS services are adding more tasks in response to the load. The Events tab for each service will show information about new task launches.

9.	In CloudWatch, check the ScaleUp alarm which is triggered by the cluster’s MemoryReservation metric. This should move into ALARM state as tasks are added to the ECS services, causing the amount of reserved memory to increase.

10.	Once the ScaleUp alarm is triggered, check the Spot fleet Auto Scaling history. Instances should be added to the Spot fleet

11.	Check the cluster’s ECS Instances tab, to see that the new instances have joined the ECS cluster.

12.	Once you have seen the Spot fleet scale up, stop the LoadGenerator EC2 instance.

You should now have ECS Services defined for cats and dogs, and seen how ECS task Auto Scaling and EC2 Auto Scaling help as the system comes under load.



# Lab 3 - Deploying a new version of the cats service with secrets management
### Overview
The development team at catsndogs.lol have been busy working on a new feature! The cats service will soon be able to serve up random unicorn pictures to lucky visitors. During the design process, it was decided that only the cats service should have access to the unicorns, and that the dogs service should not have access.
In order to accomplish this, the location of the unicorn images will be stored in a Systems Manager Parameter Store secure string. The new version of the cats task will run using an IAM role to enable access to the Parameter Store secure string. The dogs task will not use the IAM role, and so will not have access to the Parameter Store secure string.
In this lab, you will configure Parameter Store and deploy a new version of the cats task that can access the Parameter Store secure string.

### High-level Instructions
1.	In Systems Manager Parameter Store (located in the EC2 console), create a new secure string. Name the secure string **UnicornLocation** and use the default KMS key. Enter a value of **catsndogs-assets.s3.amazonaws.com**

2.	In the ECS Task Definition create a new revision of the cats task:
a.	Use the Task Role that start with catsndogssetup
b.	Change the revision of the cats container from :v1 to :v2
c.	Add environment variables of:
key: **PARAMETER_STORE_NAME** with value: **UnicornLocation** 
key: **REGION** with value: **<your_AWS_region>** *for example: us-west-2*
key: **Tag** with value: **v2**

3.	Update the cats service to use the new revision of the cats task definition. Change the Minimum healthy percent to 50 and the Maximum healthy percent to 100. This instructs ECS to deploy the new revision without increasing the total number of running containers for the cats service.

4.	Get the DNS name of the Load Balancer and open it in your browser. Click the “I love cats” link to check that the new containers are deployed.

5.	You should see the cats page change to the *catsndogs.lol new improved v2.0 cats page* with a blue background. There is a one in ten chance that the page will load a unicorn image. Shout out loud when you see one!

**Extension activity:** The new cats pages show the containerID at the bottom of the page. Examine the cats_v2 source code and work out how this information is obtained, and how the v2 cats container obtains the location of the unicorns from Parameter Store.



# Lab 4 - Running ECS tasks based on time and events
### Overview	
catsndogs is growing and becoming more successful, but rapid growth brings its own problems. Someone (probably Buzzy) has uploaded several cat images that haven’t been through our rigorous assessment process.
In response, the development team have created a new automatic image assessment algorithm called ImageAssessor. The initial release selects several images at random, removes them, and then exits. A future release will select identify and remove only non-cat images. The priority now is to get the ImageAssessor container into production.
The cat-image-standards sub-committee has determined that running the ImageAssessor container every two minutes should ensure our quality bar remains high.
You will need to create a new ECS Task for the ImageAssesssor, and create a scheduled ECS task, which runs the container on a regular schedule.
Once the ImageAssessor has removed some images from the cats containers, you will run override the environment variables of the ImageAssessor container to reset the cats images.

### High-level Instructions
1.	Create a new ECS task definition for the ImageAssessor. The image source should be **205094881157.dkr.ecr.us-west-2.amazonaws.com/image-assessor:latest**  The ImageAssessor container needs the URL of the load balancer to send API commands to the cats containers. This is provided by creating an environment variable in the task definition with:
Key: **ALB_URL** with value: **<URL_of_your_load_balancer>** *for example: http://catsn-catsn-123455678-abcdefgh.us-west-2.elb.amazonaws.com*

2.	In the ECS Cluster create a new scheduled ECS task that runs every two minutes, and runs the ImageAssessor task. For the *CloudWatch Events IAM role for this target*, use the IAM role with CloudWatchEventsRole in the name.

3.	In the scheduled task, click *View CloudWatch metrics*. View the Invocations and TriggeredRules metrics for the CloudWatch Event to verify it has run. You may need to wait until the rule has been invoked at least once before the metrics are available in CloudWatch.

4.	Verify which cat pictures remain by querying the cats API. This will return a JSON document listing the pictures that remain in the container. Replace the URL in the example below with the URL of your load balancer:
http://catsn-catsn-123455678-abcdefgh.us-west-2.elb.amazonaws.com/cats/api/list-pictures/
If many cats containers are running, the ImageAssessor may not have removed images from all of them. Refresh your browser to connect to a different container and list the images in that container. You may want to allow the ImageAssessor to run two or three times to remove at some images from every container before continuing.
View the cats pages to confirm that some pages are now displaying a blank image.

5.	Disable the ImageAssessor schedule ECS task.

The ImageAssessor also has the ability to restore all the cat images, just in case it was run too aggressively. It will restore the cats images if an environment variable called RESETPICTURES is set to 1. 

6.	In the cluster, use Run new Task to run two new ImageAssessor tasks. In the Run new Task dialog, override the environment variables to add a new environment variable:
Key: **RESETPICTURES** with value: **1**

7.	These containers will run for 30 seconds and reset the pictures in the cats tasks. Verify the cat pictures have beeen restored by the cats API again. Replace the URL in the example below with the URL of your load balancer:
http://catsn-catsn-123455678-abcdefgh.us-west-2.elb.amazonaws.com/cats/api/list-pictures/



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



# Lab 6 - Automated Deployments
### Overview	
The catsndogs.lol development team are planning to release updates to their applications more frequently. They want to build an automated deployment pipeline, that can be used to deploy updated versions of their applications with minimal manual intervention, to reduce the time it takes to get exciting new capabilities in the hands of their users.
In this lab, you will set up AWS CodePipeline to monitor an S3 bucket for changes to the source code. When new source code is uploaded to the bucket, CodePipeline will coordinate building and deploying the Docker based application. 
You will create an AWS CodeBuild project build the Docker image and push it to a repository. The CodeBuild project will tag the newly built dogs containers with a version number.
You will also integrate AWS CodePipeline with AWS CloudFormation to update the existing ECS tasks and services. The pipeline will use the version number of the dogs containers as a parameter when updating the CloudFormation stack, so that the right version of the container is deployed.

### High-level Instructions
1.	From the Lab-6-Artifacts folder, upload the templates.zip and dogs.zip to the S3 bucket with CodeUploadS3Bucket in the name. Templates.zip contains a copy of the templates from earlier labs, and dogs.zip contains source code for the dogs container.

2.	Create a new CodePipeline pipeline. The Source should be the dogs.zip you uploaded to the S3 bucket. In the Build step, create a new CodeBuild project. For the build environment, use an image managed by AWS CodeBuild. Use the Ubuntu Docker image version 1.12.1.
a.	Use the role with CatsnDogsBuild in the name.
b.	In Advanced settings, add three environment variables:
AWS_DEFAULT_REGION: **<your AWS region>** *for example ap-southeast-2*
AWS_ACCOUNT_ID: **<the account ID of your AWS account>**
REPOSITORY_URI: **<URI of your dogs ECR repository>** *for example: 1234567891011.dkr.ecr.ap-southeast-2.amazonaws.com/dogs*
c.	Do not configure a deployment provider. You will configure a custom deployment provider in a later step with more details than are provided for in the wizard.
d.	Use the IAM role with CatsnDogsPipeline in the name.

Because you have already deployed tasks and services to your cluster using CloudFormation, you will continue to use that as the deployment tool. CloudFormation will perform a stack update to update the running tasks and services. To use CloudFormation as part of the pipeline, the template needs to be defined within the pipeline.

3. Edit the pipeline Source stage and add a new Action. Use the S3 source provider, and specify the location of the templates.zip that you uploaded to the S3 bucket. In Output artifact, enter **template**

4.	You will now configure a customized Deploy state which uses CloudFormation. Add a new Deploy stage to the end of the pipeline. Choose CloudFormation as the deployment provider.
a.	For Action mode, choose Create or update a stack.
b.	Update the stack from lab 2. If you followed the instructions, this should be called *catsndogsECStasksandservices*
c.	In Template file enter: `template::Lab2-create-ecs-tasks-and-services.yml`
This will use the “template” output artifact from the Source step, and the Lab2-create-ecs-tasks-and-services.yml contained within that artifact.
d.	Leave the configuration file blank
e.	For Capabilities, choose CAPABILITY_NAMED_IAM
f.	For the IAM role, choose the role with CatsnDogsCloudFormation in the name. 
g.	In Advanced, enter the following in Parameter Overrides. Replace the accountid and region with your AWS account ID and region:
`
{ "DogTag": { "Fn::GetParam" : [ "MyAppBuild", "build.json", "tag" ] }, "ImageRepo": "<accountid>.dkr.ecr.<region>.amazonaws.com"}
`
For example:
`{ "DogTag": { "Fn::GetParam" : [ "MyAppBuild", "build.json", "tag" ] }, "ImageRepo": "123456789011.dkr.ecr.ap-southeast-2.amazonaws.com"}
`

The parameter override updates the CloudFormation *DogTag* parameter with the Docker image tag created during the build process. *DogTag* will be replaced with the tag associated with the new image created by the Build state, and *ImageRepo* will be replaced with the URL of your repository.  More information about parameter overrides can be found in the CodePipeline documentation: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-parameter-override-functions.html


h.	In Input artifacts, for Input artifact #1 choose **template** and for Input artifact #2 choose **MyAppBuild**

5.	From the Lab-6-Artifacts/v2 folder, upload dogs.zip to the S3 bucket. This version of the container includes a new-style background. Once the upload is complete, verify the pipeline runs successfully. 

6.	While the pipeline is running, open the CodeBuild console and view the Build History of the most recent build. You should be able to see the logs from the build.

7.	It may take a few minutes for the new containers to deploy, after which the new Dogs pages should display with fancy new background color. 

The build process for the dogs Docker image uses the AWS CLI to copy the latest dog memes from an S3 bucket. Although the images are publicly readable, any S3 operation requires AWS credentials. In this case, the credentials from the build environment need to be passed through to the Docker build process, otherwise the build process will fail with “Unable to locate credentials”.
More details can be found here: http://docs.aws.amazon.com/codebuild/latest/userguide/troubleshooting.html#troubleshooting-versions 

**Extension activity:** Examine the buildspec.yml file in the dogs.zip file, to understand the steps the CodeBuild project is taking to build and push the docker image. How is the image tagged? How does the CodePipeline pipeline retrieve the tag, to use as a parameter when updating the CloudFormation stack?



# Lab 7 - Advanced Deployment Techniques 
### Overview
Now you have a working automated deployment pipeline. Management are extremely happy. However, some buggy code which made its way in to the most recent release of cats, took the cats service offline for a while. The cat lovers were not happy.
To address this problem, management have asked you to come up with a safer way to deploy updates, an approach that allows an easy roll back to previous versions, in the event of a problem.
You will setup a blue-green deployment solution, which, because we love cats so much, incorporates some canaries. This solution will allow you to release new versions of the cats application in a staged approach, whilst maintaining a running copy of the previous version for quick roll-back.
The blue-green deployment method will use CloudWatch Events to detect new containers being created. If those containers are part of the a “green” deployment, the CloudWatch Event will trigger a Lambda function. The Lambda function will invoke a Step Functions state machine which performs health checks and gradually moves traffic to the new deployment. The state machine will perform health checks, failing back to the existing stack in the event of a health check failure.
More information about this can be found on the awslabs github repo: 
https://github.com/awslabs/ecs-canary-blue-green-deployment

### High-level Instructions

1.	Deploy a CloudFormation stack using the `Lab7-blue-green-canary.yml` template file. This will create a “green” stack composed of an Application Load Balancer, new ECS tasks and services, and a Route 53 hosted zone. It will also create the AWS Lambada functions, AWS IAM roles and AWS DynamoDB table to support blue/green deployments.

2.	In the Route 53 console, find the catsndogs.lol hosted zone. Note the weighted record set for www.catsndogs.lol is set to return one result 100% of the time.

3.	Find one of the nameserver records for the zone. Because this zone is not registered with the DNS registrar, it is only accessible if you directly query the zone’s nameservers.

4.	Query the nameserver using a command line tool such as *dig* or *nslookup*. Copy the IP address from the response and open this in your browser. This is an IP from the existing Application Load Balancer. You should see the current website with cats v2 from previous labs. This mimics what a real customer would see if the zone was registered.

5.	Create an AWS Step Functions state machine to update the weight of the record www.catsndogs.lol record set. Create a Custom state machine.
a.	A template for the step function can be found in **Lab-7-Artifacts/step-functions.json**
b.	For each of the **change_** steps, update the Resource key with the Lambda function with **CatsnDogsupdateRoute53** in the name. This function updates the Route53 record.
c.	For each of the **check_** steps, update the Resource key with the Lambda function with **CatsnDogscheckHealth** in the name. This function will carry out the health check.

6.	Update the Lambda function with HandleECSEvents in the name. Paste the ARN of the Step Functions state machine you created into the STEP_FUNCTION environment variable. This allows the Lambda function to invoke the correct state machine.

7.	Create a CloudWatch Events rule to trigger when an ECS task changes state. When building the event pattern, match the **EC2 Container Service**, and capture **State Change** events, specifically **ECS Task State Change**. The event should trigger only for changes in the **catsndogsECScluster**.
The rule should trigger the Lambda function with **HandleECSEvents** in the name.

8.	To mimic a Continuous Deployment process deploying the new service, start copies of the cats-green task. In the ECS Console, select the service that uses the cats-green task and change the number of tasks to 3. These tasks starting should trigger the CloudWatch Events rule. As soon as you have updated the service, verify the deployment is causing Route 53 to change the weighting of the record sets.
a.	By monitoring the progress of the Step Function state machines.
b.	Using the Route 53 console to see the weighted record set changing.
It might take several minutes for the state machine and Route 53 changes to complete.

9.	Query the Route 53 nameserver again. Enter the new IP address in your browser. You should see the new deployment with version3 of the cats page. Again, this mimics what customers would see if the zone were registered.

**Extension exercise:** It has come to the attention of the bean-counters that that the CloudWatch Events rule is being triggered more often than the number of times a new service deployment occurs. This is bad because unused events were swapped out for a steady supply of catnip.
For the sake of the cats, please investigate why this is happening, and implement a solution that reduces the number of times the catsndogECSRule triggers. Start by viewing the Lambda logs in CloudWatch. See if anything erroneous stands out. What things could be done to resolve the issue?



# Clean up
Congratulations. You have successfully helped the team at catsndogs.lol build a highly scalable container based application architecture and an automated deployment pipeline. This lab simply cleans up all the resources you have created in previous labs.

### Clean up Instructions
1.	Delete the ECS Cluster. This will also delete all the ECS Tasks and Services within the cluster.
2.	If it exists, delete the Auto Scaling Group ECS-On-Demand-Group
3.	If it exists, delete the Launch Configuration On-Demand-ECS
4.	Verify the cats, dogs, simplehomepage, MXnet, and ImageAssessor tasks are deleted.
5.	Delete the cats, dogs and simplehomepage ECR repositories if they exist.
6.	Delete the Parameter Store secure string named UnicornLocation.
7.	Delete the CloudWatch events ImageAssessor and HandleECSEvents
8.	Delete the CloudWatch alarms ScaleDownSpotFleet and ScaleUpSpotFleet
9.	Delete the CloudWatch Logs log groups for:
a.	aws/codebuild/dogs-build
b.	All log groups beginning with aws/lambda/Lab7
7.	Delete the CodePipeline pipeline.
8.	Delete the CodeBuild project.
9.	Empty and delete the CodeUploads S3 bucket.
10.	Delete the Step Functions state machine.
11.	Delete the Route 53 A-type record sets inside the catsndogs.lol hosted zone.
12.	Delete the CloudFormation stacks you created. Because later labs rely on the stacks from earlier labs, you should delete the Lab0 stack only after the others have reached the DELETE_COMPLETE state:
a.	Lab7: catsndogsECStasksandservices-green 
b.	Lab2: Lab2-create-ecs-tasks-and-services and Lab2-loadgenerator
c.	Lab1: Lab1-add-ondemand-asg-to-cluster
d.	Lab0: catsndogssetup

Feedback? Comments? catsndogs@amazon.com
**Thank you**