# Lab 3 - Deploying a new version of the cats service with secrets management
### Overview
The development team at catsndogs.lol have been busy working on a new feature! The cats service will soon be able to serve up random unicorn pictures to lucky visitors. During the design process, it was decided that only the cats service should have access to the unicorns, and that the dogs service should not have access.
In order to accomplish this, the location of the unicorn images will be stored in a Systems Manager Parameter Store secure string. The new version of the cats task will run using an IAM role to enable access to the Parameter Store secure string. The dogs task will not use the IAM role, and so will not have access to the Parameter Store secure string.
In this lab, you will configure Parameter Store and deploy a new version of the cats task that can access the Parameter Store secure string.

### High-level Instructions
1.	In Systems Manager Parameter Store (located in the EC2 console), create a new secure string. Name the secure string **UnicornLocation** and use the default KMS key. Enter a value of **catsndogs-assets.s3.amazonaws.com**. Add a tag with the key "Classification" and value "Mythical" (no quotes).

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

# What's Next
[Running ECS tasks based on time and events](../Lab-4-Artifacts/)

# Detailed Instructions
[Deploying a new version of the cats service with secrets management - Detailed Instructions](./lab3-detailed-steps.md)
