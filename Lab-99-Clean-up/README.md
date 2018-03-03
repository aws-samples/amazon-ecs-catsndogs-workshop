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
