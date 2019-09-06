# Lab 2 - ECS Service deployment and task Auto Scaling - Detailed Steps

## 2.1	Create ECS Tasks and ECS Services for the homepage, cats, and dogs

This step will use CloudFormation to create the cats, dogs, and simplehomepage tasks and services within ECS, and associate the services with an Elastic Load Balancing Application Load Balancer. It will also create CloudWatch alarms for the cats and dogs services, which you will use to set up Task Auto Scaling.

1.	In the AWS Console, ensure you have the correct region selected. The instructor will tell you which region to use.

2.	In the **Management Tools** section click **CloudFormation**.

3.	Click **Create Stack**.

4.	Select **Upload a template to Amazon S3**, then click **Choose** File and choose the file named **Lab2-create-ecs-tasks-and-services.yml**

5.	In Stack name, enter **catsndogsECStasksandservices**

6.	Leave the ECSCluster and LabSetupStackName parameters at their default, unless you changed the name of the CloudFormation stack from the Lab 
setup, or named the ECS cluster something other than catsndogsECScluster.

7.	Click **Next**, then click **Next** again, then click **Create**.

8.	Wait until the stack status is **CREATE_COMPLETE**.

9.	Verify the catsndogs application works by loading the website:
    
    1. In the AWS Console, under **Compute** click **EC2**.
    
    2. Click **Load Balancers**.
    
    3. Copy the **DNS Name** of the load balancer with **catsn-catsn** in the name.
    
    4. Paste this into a new browser tab. You should see the catsndogs.lol homepage, and should be able to click the “I love cats” and “I love dogs” links to see pages served by the cats and dogs containers, respectively.
    
## 2.2	Set up Task Auto Scaling for the cats and dogs services

In this task you will set up Task Auto Scaling for the cats and dogs services

1. In the **Compute** section of the AWS Console click **EC2 Container Service**.

2. In the ECS console click **catsndogsECScluster** then the service with Cats in the name.

3. Click the **Update** button at the top right of the console.

4. On the **Configure Service** page click **Next Step**.

5. On the **Network configuration** page click **Next Step**.

6. On the Auto Scaling page select **Configure Service Auto Scaling to adjust your service’s desired count**.

    1. Set **Minimum number** of tasks to 2.

    2. Set **Desired number** of tasks to 2.

    3. Set **Maximum number** of tasks to 100.

7. In **IAM role for Service Auto Scaling** select the role with **ECSAutoScaleRole** in the name.

8.	Click **Add scaling policy** button. Select **Step scaling** radio button for **Scaling policy type**

9.	In **Policy name** enter **CatsScaleUpPolicy**.

10.	In **Execute policy when** select **Use an existing alarm** and choose the alarm with **CatsScaleUpAlarm** in the name.

11.	In **Scaling action** click the **Add** button twice.

    1. Enter: **Add 10 tasks** when **1000** <= RequestCount < **2000**

    2. Enter: **Add 20 tasks** when **2000** <= RequestCount < **4000**

    3. Enter: **Add 25 tasks** when **4000** <= RequestCount < +infinity

12.	Click **Save**.

13.	Click **Add scaling policy** button. Select **Step scaling** radio button for **Scaling policy type**

14.	In **Policy name** enter **CatsScaleDownPolicy**.

15.	In **Execute policy when** select **Use an existing alarm** and choose the alarm with **CatsScaleDownAlarm** in the name.

16.	In **Scaling action** click the **Add** button.

    1. Enter: **Remove 10 tasks** when **1000** >= RequestCount > **100**

    2. Enter: **Remove 5 tasks** when **100** >= RequestCount > -infinity

17.	Click **Save**.

18.	Click **Next step**.

19.	Click **Update Service**.

20.	Click **View Service**, then click the cluster name **catsndogsECScluster**.

21.	Click the service with **Dogs** in the name.

22.	Click the **Update** button at the top right of the console.

23.	On the **Configure Service** page click **Next Step**.

24.	On the **Network configuration** page click **Next Step**.

25.	On the Auto Scaling page select **Configure Service Auto Scaling to adjust your service’s desired count**.

    1. Set **Minimum number of tasks** to 2.

    2. Set **Desired number of tasks** to 2.

    3. Set **Maximum number of tasks** to 100.

26.	In **IAM role for Service Auto Scaling** select the role with **ECSAutoScaleRole** in the name.

27.	Click **Add scaling policy** button.

28.	In **Policy name** enter **DogsScaleUpPolicy**. Select **Step scaling** radio button for **Scaling policy type**

29.	In **Execute policy when** select Use an existing alarm and choose the **DogsScaleUpAlarm**.

30.	In **Scaling action** click **Add** twice.

    1. Enter: **Add 10 tasks** when **1000** <= RequestCount < **2000**

    2. Enter: **Add 20 tasks** when **2000** <= RequestCount < **4000**

    3. Enter: **Add 25 tasks** when **4000** <= RequestCount < +infinity

31.	Click **Save**.

32.	Click **Add scaling policy** button.

33.	In **Policy name** enter **DogsScaleDownPolicy**. Select **Step scaling** radio button for **Scaling policy type**

34.	In **Execute policy when** select **Use an existing alarm** and choose the alarm with **DogsScaleDownAlarm** in the name.

35.	In **Scaling action** click the **Add** button.

    1. Enter: **Remove 10 tasks** when **1000** >= RequestCount > **100**

    2. Enter: **Remove 5 tasks** when **100** >= RequestCount > -infinity

36.	Click **Save**.

37.	Click **Next step**.

38.	Click **Update Service**.

39.	Click **View Service**, then click the cluster name **catsndogsECScluster**.

## 2.3	Generate load and validate Task Auto Scaling works as expected

In this task, you will generate load to cause the cats and dogs services scale. As more cats and dogs tasks are added to the cluster, the MemoryReservation metric for the cluster will increase. Because the EC2 Spot fleet Auto Scaling is set up to scale based on MemoryReservation, this will cause the underlying EC2 Spot fleet to scale. 

You will create a CloudFormation stack containing a load generator that sends load to the cats and dogs containers, and then verify the tasks scale as expected.

1. In the **Management Tools** section click **CloudFormation**.

2. Click **Create Stack**.

3. Select **Upload a template to Amazon S3**, then click Choose File and choose the file named **Lab2-loadgenerator.yml**.

4. In **Stack name**, enter **catsndogslab2loadgenerator**.

5. Leave the LabSetupStackName parameter at its default, unless you changed the name of the CloudFormation stack from the Lab setup.

6. Click **Next**, then click **Next** again, then click **Create**.

7. Wait until the stack status is **CREATE_COMPLETE**.

**Note:** the LoadGenerator instance uses the Vegeta load generator. More information about this is available at: https://github.com/tsenart/vegeta . The CloudFormation template injects the URL of your load balancer so Vegeta sends requests to the correct endpoint

8. In the AWS Console, under **Management Tools** click **CloudWatch**.

9. Click **Metrics**.

10.	On the **All metrics** tab, click **ApplicationELB**, then **Per AppELB, per AZ, per TG Metrics**.

11.	Find the LoadBalancer where the name starts with **catsn-catsn** and select the **RequestCount** metrics.

12.	On the **Graphed metrics** tab, change the **Statistic** to **Sum**, and the **Period to 10 seconds**.

13.	After a minute or two you should start to see an increase in request counts, to around 1500 each for the cats and dogs target groups. Note that the simpleHomepage target group is not accessed by the load generator.

14.	Click **Alarms**.

15.	After the load has been sustained for two minutes, the **Lab2-CatsScaleUpAlarm** and **Lab2-DogsScaleUpAlarm** should enter the ALARM state.

16.	In the AWS Console, under **Compute** click **EC2 Container Service**.

17.	In the ECS console click **Clusters**, then click the cluster **catsndogsECScluster**.

18.	Click Services and click either the cats or dogs service.

19.	Click the Events tab. You should see events as ECS adds more tasks to the Service

## 2.4	Validate the Spot fleet scales out

As more tasks are added to the cluster, the MemoryReservation metric will increase. Because the EC2 Spot fleet Auto Scaling is set up to scale based on MemoryReservation, this will cause the underlying EC2 Spot fleet to scale. In this task you will verify that Spot fleet Auto Scaling adds more EC2 instances to the cluster:


1. In the AWS Console, under **Management Tools** click **CloudWatch**.

2. Click **Alarms**.

3. Once sufficient copies of the cats and dogs tasks have started, the ScaleOut alarm you created in Lab 1 should change to ALARM state. Click this alarm and view the metric graph to see whether it has reached the alarm threshold.

4. Once it has reached the threshold and moved to ALARM state, move to the next step.

5. In the AWS Console, under **Compute** click **EC2**.

6. Click **Spot Requests** then select the Spot fleet request.

7. Click the **History** tab. You may see an **Event Type** of **autoScaling** with a **Status** of **pending**, otherwise you should see **Event Type** entries of **instanceChange** with a **Status** of **launched**.

8. In the AWS Console under the Compute section click EC2 Container Service.

9. In the ECS console click **catsndogsECScluster**.

10.	Click the **ECS Instances** tab.

11.	Verify that the new instances are added to the cluster.

## 2.5	Clean up

In this task, you will stop the load generator. As the load stops, the number of ECS tasks and number of instances in the Spot fleet will return to their default levels.

1. In the AWS Console, under **Compute** click **EC2**.

2. Click **Instances**.

3. Select the instance with **LoadGenerator** in the name.

4. Click **Actions** and select **Instance State**, then click **Stop**.

# What's Next
[Deploying a new version of the cats service with secrets management](../Lab-3-Artifacts/)
