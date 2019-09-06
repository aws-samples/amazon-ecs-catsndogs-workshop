# Lab 4 - Running ECS tasks based on time and events - Detailed Steps

## 4.1 Create a new ECS Task for the ImageAssessor container

In this task you will create a new Task definition that will run the image assessments.

1. In the AWS Console, in the **Compute** section click **ECS**.

2. Click **Task Definitions**.

3. Click Create new **Task Definition** and for **Select launch type compatibility** choose **EC2**.

4. Click **EC2** and then **Next step**.

5. In **Task Definition Name** enter **ImageAssessor**.

6. Under **Container Defintions** click **Add Container**.

7. In **Container Name** enter **ImageAssessmentContainer**.

8. In **Image** enter **205094881157.dkr.ecr.us-west-2.amazonaws.com/image-assessor:latest**.

9. In **Memory Limits (MiB)** enter **128**.

10. In **Env Variables** you need to enter the URL of the catsndogs load balancer. You can find this in the CloudFormation console - look at the **catsndogssetup** stack, check the **Outputs** tab for the value **LoadBalancerDNSName**. The ImageAssessor container uses this to send API commands to the cats containers:

    1. Key: ALB_URL
    
    2. Value: <URL of the load balancer> for example: http://catsn-catsn-123455678-abcdefgh.us-west-2.elb.amazonaws.com

11.	Click **Add**.

12.	Click **Create**. 

## 4.2 Create a scheduled ECS task.

In this task you will create a scheduled ECS task which executes every two minutes:

1. In the AWS Console, in the **Compute** section click **ECS**.

2. Click the cluster **catsndogsECScluster**.

3. On the **Scheduled Tasks**, click **Create**.

4. In **Create scheduled task**:
    
    1. In **Scheduled rule name**, type **ImageAssessor**.
    
    2. For **Scheduled rule type**, choose **Run at fixed interval**.
    
    3. For **Run at fixed interval**, enter **2**, and from the drop list, select **Minutes**.

5. In Scheduled target:
    
    1. In **Target id**, enter **catsndogsLab** and set **Launch Type** to **EC2**.
    
    2. For **Task Definition**, from the drop list, choose the **ImageAssessor:1** image.
    
    3. Set the **Number of tasks** to **1**.
    
    4. For **CloudWatch Events IAM role for this target**, choose the role with **catsndogssetup** in the name. 

6. Click **Create**.

## 4.3 Verify the Image Assessor is working

1. Once the schedule ECS task is created, click the **ImageAssessor** task, list on the **Scheduled Tasks** tab.

2. Click **View CloudWatch metrics**.

3. Until the task has run at least once you may see the following text. Wait a minute and refresh the page.

    Your search - ImageAssessor - did not match any metrics.
    Tips:
    Tags such as EC2 instance name tags are not supported in metric search.
    Make sure that all words are spelled correctly.
    Try different keywords.
    Try fewer keywords.

4. Select the Invocations and TriggeredRules metrics when they become available. Ensure the Invocations count is 1.

5. In your web browser, open the load balancer URL and click on the “I love cats” link. You should see pages with cat pictures missing as the Image Assessor removes pictures.

6. You can verify which pictures remain by querying the cats API. Replace the URL in the example below with the URL of your load balancer:

http://catsn-catsn-123455678-abcdefgh.us-west-2.elb.amazonaws.com/cats/api/list-pictures/

You should see a JSON document listing the pictures that remain in the container, for example: `{"2.jpg": "true", "10.jpg": "true", "7.jpg": "true}`

If many cats containers are running, the ImageAssessor may not have removed images from all of them. Refresh your browser to connect to a different container and view the list of images in that container. You may want to allow the ImageAssessor to run two or three times to remove at least some images from every container before continuing.

7. In the AWS Console, in the **Compute** section click **ECS**.

8. Click the cluster **catsndogsECScluster**.

9. On the **Scheduled Tasks**, click the **ImageAssessor** task.

10.	Click the **Edit** button in the top right of the screen.

11.	Uncheck the **Schedule rule enable** check box, to disable the rule.

12.	Click **Update**.

## 4.4 Reset the cats images by overriding an environment variable in the ImageAssessor task

The ImageAssessor can also reset all of the cats image if the following environment variable is set for the task definition: RESETPICTURES: 1.

1. In the ECS Console, click the **catsndogsECScluster**.

2. Click the **Tasks** tab and then click **Run new Task**.

3: For **Launch type** select **EC2**.

4. In **Task Definition** select the most recent revision of the **ImageAssessor** task.

5. In **Cluster** select the **catsndogsECScluster**.

6. In **Number of tasks** enter **2**.

7. Leave **Task Group** blank.

8. Expand **Advanced Options**.

9. Under **Container Overrides** expand the **ImageAssessor** container.

10. In **Environment variable overrides** click the + to add a new environment variable.

11. In Key enter **RESETPICTURES** and in Value enter **1**.

12. Click **Run Task**.

13. In the **Tasks** tab the **ImageAssessor** tasks should move appear with a **Last status** of PENDING. In a few seconds this will change from PENDING to RUNNING.

14. The tasks will run for 30 seconds and then exit.

15. Once they have exited, click **Desired task status: Stopped**.

16. Find one of the ImageAssessor tasks in the list and click the **Task** identifier.

17. Under Containers, expand the image-assessor container. You should see the **Exit code0** indicating the container exited successfully.

18. Verify the cats pictures have been reset by querying the cats API. Replace the host in the example below with the URL of your load balancer:
http://catsn-catsn-123455678-abcdefgh.us-west-2.elb.amazonaws.com/cats/api/list-pictures/

# What's Next
[Machine Learning containers and placement constraints](../Lab-5-Artifacts/)
