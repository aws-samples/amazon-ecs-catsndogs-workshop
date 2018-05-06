# Lab 3 - Deploying a new version of the cats service with secrets management - Detailed Steps

## 3.1	Create secrets for the new version of the cats task

In this step, you will use EC2 Systems Manager Parameter Store to create a secure string for use with the new version of the cats container.

1.	In the AWS Console, ensure you have the correct region selected. The instructor will tell you which region to use.

2.	In the **Compute** section click **EC2**.

3.	At the bottom left of the page, click **Parameter Store**.

4.	If you see the introductory page, choose **Get started**, otherwise click **Create Parameter**.

5.	In **Name** enter **UnicornLocation**.

6.	In **Description** enter **Location of Unicorns for catsndogs ECS lab**.

7.	In **Type** select **Secure String**.

8.	In **KMS Key ID**, select **alias/keyForUnicorns (custom)**.

9.	In **Value**, enter **catsndogs-assets.s3.amazonaws.com**

10.	Click **Create parameter**.

11.	Click **Tags** tab and then click **Add Tags**.

12.	For **Tag Key** enter **Classification**.

13.	For **Tag Value** enter **Mythical**. 

The tag information will be used to restrict access to the UnicornLocation parameter, more information can be found here: 

http://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-access.html 

## 3.2	Deploy a new version of the cats task

In this step you will deploy the new version of the cats container, and pass in parameters so it can read the Parameter Store secure string you created.

1. In the AWS Console, ensure you have the correct region selected. The instructor will tell you which region to use.

2. In the **Compute** section click **ECS**.

3. Click **Task Definitions**.

4. Select the cats task and click **Create new revision**.

5. In Task Role, select the task role starting with **catsndogssetup-catsContainerTaskRole**.

6. Under **Container Definitions**, click the cats container name. This opens the container configuration window.

7. In **Image**, edit the container registry tag. Remove “:v1” and replace it with “:v2”.

8. Under ENVIRONMENT add two new Env Variables. The updated code in the new cats container will read these variables when starting.

    1. Key: **PARAMETER_STORE_NAME** Value: **UnicornLocation**
    
    2. Key: **REGION** Value: your region identifier, for example eu-west-1
    
    3. Key: **Tag** Value: **v2**

9. Click **Update**.

10.	Click **Create**.

11.	**Note the revision number of the cats service that you just created**. This will likely be cats:2 but may vary if you have done this lab before.

12.	Click **Clusters** and then click **catsndogsECScluster**.

13.	Select the **cats** service and click **Update**.

14.	In **Task Definition** select the revision of the cats task that you noted in the earlier step.

    1. In **Minimum healthy** percent enter **50**.

    2. In **Maximum healthy** percent enter **100**.

**Note:** The update to the cats Service will replace the containers that make up the service. ECS offers you control over how the replacement process works. Because the cats containers are serving production traffic, you should not stop all the containers before starting new ones. By specifying a Minimum health percent of 50 and a Maximum healthy percent of 100, ECS will terminate up to 50 percent of the active cats containers, then start new containers. Once the new containers are healthy, ECS will terminate the remaining 50 percent of and replace those. 
  
This way, the cats service does not exceed its current footprint.
  
The default values, a Minimum healthy percent of 100 and Maximum healthy percent of 200, would briefly double the number of cats containers during deployment. That may be acceptable in many situations, however our deployment strategy is not to exceed the current container count.

15.	Click **Next step** until you reach the end of the wizard, then click Update service.

16.	Click **View service**. The Deployments tab should show the PRIMARY deployment as well as the ACTIVE deployment.

17.	Click the Events tab. Depending on the number of cats tasks that were running at the time you updated the service, ECS will show events terminating groups of cats tasks, and starting groups of the new revision.

18.	Click the **Tasks** tab. You should see tasks with the **Last status** of RUNNING and the Task Definition of the revision number you noted in the earlier step.

19.	In the AWS Console, under **Compute** click **EC2**.

20.	Click Load Balancers.

21.	Copy the **DNS Name** of the load balancer with **catsndogssetup** in the name.

22.	Paste this into a new browser tab. You should see the catsndogs.lol homepage

23.	Click the “I love cats” link.

24.	You should see the cats page change to the “new and improved v2 release” page with a blue background. There is a one in ten chance that the page will load a unicorn image. Shout out loud when you see one!

**Extension activity:** The new cats pages show the containerID at the bottom of the page. Examine the cats_v2 source code and work out how this information is obtained, and how the v2 cats container obtains the location of the unicorns from Parameter Store.

# What's Next
[Running ECS tasks based on time and events](../Lab-4-Artifacts/)

