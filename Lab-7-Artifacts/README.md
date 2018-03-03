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
