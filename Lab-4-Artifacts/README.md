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

# What's Next
[Machine Learning containers and placement constraints](../Lab-5-Artifacts/)

# Detailed Instructions
[Running ECS tasks based on time and events - Detailed Instructions](./lab4-detailed-steps.md)