# Lab 5 - Machine Learning containers and placement constraints - Detailed Steps

## 5.1	Create a new task definition for the MXNet container

In this step, you will create a new task definition for a deep learning container running the MXNet framework, with a placement constraint to ensure tasks run only on certain instance types.

1. Sign-in to the AWS management console and open the Amazon ECS console at https://console.aws.amazon.com/ecs/.

2. Select **Task Definitions** from the left-hand menu.

3. Click **Create new Task Definition**.

4. In **Task Definition Name**, enter **mxnet**.

5. Click **Add Container**.

6. In the **Add container** dialog, under Standard:

    1. In **Container name**, enter mxnet

    2. In **Image**, paste the repository URI and add the latest tag.
        
        205094881157.dkr.ecr.us-west-2.amazonaws.com/mxnet:latest

    3. In **Memory Limits (MiB)**, set **Hard Limit** to **2048**.

    4. Click **Add**.

7. In **Constraint**, click **Add constraint**.

8. Set the **Expression** to use an instance type that is currently running in the cluster. For example if one of the instance types was an c4.large, you would enter:

`attribute:ecs.instance-type == c4.large`

To check the instance types running, open the Clusters view in a new tab, click catsndogsECScluster and select the ECS Instances tab. 

From the pop-up window, click the cog button,  , and select ecs.instance-type.

Scroll along the list of instances to see the ecs.instance-type value.

9. Click **Create**.

## 5.2	Create a new service for MXNet with a custom placement strategy

In this step, you will create a new ECS Service that will ensure two instances of the MXNet container run at all times.

1. In the navigation pane click **Clusters**.

2. Click the cluster **catsndogsECScluster**.

3. On the Services tab, click **Create**.

4. In **Configure service**:

    1. In **Task definition**, choose **mxnet:1**.

    2. In **Cluster**, choose **catsndogsECScluster**.

    3. In **Service name**, enter **mxnetservice**.

    4. In **Number of tasks**, enter **2**.

    5. Leave **Minimum healthy percent** and **Maximum percent** at their defaults.

You will now use a custom placement template to force the MXNet tasks to spread across Availability Zones, then across different instance types, and then BinPack based on Memory:

5. In **Placement Templates** select **Custom**.

6. In **Type** choose **Spread**, and in **Field** choose **attribute:ecs.availability-zone**.

7. Click **Add Strategy**.

8. In **Type** choose **Spread**, and in **Field** choose **attribute:ecs.instance-type**.

9. Click **Add Strategy**.

10. In **Type** choose **BinPack**, and in **Field** choose **Memory**.

11. Click **Next step**.

12. In **Network configuration**, for **Load Balancing**, choose **ELB Type** of **None**.

13. Click **Next step**.

14. In **Auto Scaling (optional)**, for **Service Auto Scaling**, choose **Do not adjust the service’s desired count**.

15. Click **Next step**.

16. Review the settings, and click **Create Service**.

17. Click **View Service**.

## 5.3	Ensure the placement constraints are being honored

In this step, you will ensure that the constraint you configured for the mxnet task is being honored by the ECS service scheduler.

1. In the navigation pane click **Clusters**.

2. Click the **catsndogsECScluster**.

3. Click the **Tasks** tab and locate one of the mxnet tasks from the list of running tasks.

4. Click on the **Task** ID.

5. In the **Details** view, locate and click on the **EC2 instance id**.

6. The EC2 console will open and display the container instance.

7. Check the **Instance Type**, it should be the type and size you selected in the earlier steps.

## 5.4	Add a container instance custom attribute using the AWS CLI, to control task placement for the cats service

In addition to the built-in attributes of instance type, AMI, availability zone and operating system type, you can also constrain the placement of tasks using custom attributes. A custom attribute is metadata added to container instances. Each attribute has a name, and an optional string value.

Management have asked that we enforce strict segregation between the cats and the dogs to stop the fighting with each other. In this task, you will use the AWS Management console to add a custom attribute to a container instance. The custom attribute will then be used to constrain the cats containers to a specific container instance.

In this step, you will use the AWS CLI to add a custom attribute to a container instance. You will then update the cats task to add a constraint using the custom attribute you created. 

1. Open to the AWS management console and open the Amazon ECS console at https://console.aws.amazon.com/ecs/.

2. In the navigation pane click Clusters.

3. Click the cluster catsndogsECScluster.

4. Click the ECS Instances tab and copy a container instance ID from the Container Instance column.

5. This step can be completed from your laptop. From the command prompt, run the following AWS CLI command. Replace <region> with your region, and <container_instance_id> with the instance ID you copied in the previous step:


```
aws ecs put-attributes --cluster catsndogsECScluster --attributes "name=catslike,value=catnip,targetType=container-instance,targetId=<container_instance_id>" --region <your-region-name>
```

6. You should see a response containing details of the attribute.

7. In the navigation pane choose **Task Definitions**.

8. Select **cats** from the list of task definitions.

9. Click **Create new revision**.

10. In **Constraint**, click **Add constraint**.

11. Set the **Expression** to: `attribute:catslike == catnip`.

12. Click **Create**.

**Note:** You can also try experimenting with some of the built-in attributes like **instance type, AMI, availability zone** and **operating system type**. 

Verify that the custom attribute you created is visible in the console:

1. Open to the AWS management console and open the Amazon ECS console at https://console.aws.amazon.com/ecs/.

2. In the navigation pane click **Clusters**.

3. Click the cluster **catsndogsECScluster**.

4. Click the **ECS Instances** tab and select the check box for the container instance you added the custom attribute to.

5. Click **Actions** and **View/Edit Attributes**.

6. Verify the **Catslike** key exists and the value is **Catnip**.

7. Click **Close** to return to the ECS Instances tab.

## 5.5	Update the cats service to use the custom attribute

In this step, you will update the cats service to use the new task definition you created in the previous step. 

1. In the navigation pane choose **Clusters**.

2. Click the cluster **catsndogsECScluster**.

3. Click the **Services** tab then click the cats service.

4. Click **Update**.

5. In Configure service:

    1. In **Task definition**, choose the task definition you created in the earlier step.

    2. In **Cluster**, choose the cluster **catsndogsECScluster**.

6. Click **Next step**.

7. In **Load Balancing**, choose **Next step**.

8. In **Service Auto Scaling (optional)**, click **Next step**.

9. Review the settings, and click **Update service**.

10. Click **View Service**.

## 5.6	Ensure the placement constraints are being honored

In this step, you will use the AWS management console to ensure that the constraint you configured for the cats task, is being honored by the ECS service scheduler.

1. In the navigation pane choose **Clusters**.

2. Click the cluster **catsndogsECScluster**.

3. Click the **ECS Instances** tab and locate the instance with the Container Instance you added the custom attribute to in the earlier step.

4. You should see that all **cats** tasks are now running on the container instance with the **catslike** attribute.

# What's Next
[Automated Deployments](../Lab-6-Artifacts/)
