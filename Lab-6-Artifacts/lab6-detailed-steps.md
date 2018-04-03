# Lab 6 - Automated Deployments - Detailed Steps

## 6.1	Deploy the lab prerequisites

This step will use CloudFormation to prerequisite resources for this lab, which include:
•	An instance of the Amazon Cloud9 IDE.

1.	In the AWS console ensure you have the correct region selected.

2.	In the **Management Tools** section, click **CloudFormation**.

3.	Click Create Stack

4.	Select **Upload a template to Amazon S3**, then click **Choose file** and choose the file name **cfn-templates/Lab6-create-ide.yml**.

5.	For **Stack name**, enter **catsndogs-ide**.

6.	Click **Next**, and **Next** again.

7.	Click **Create**.

8.	Wait until the stack status is **CREATE_COMPLETE**.

9.	Click the **catsndogs-ide** stack name.

10.	Expand **Outputs**, locate the **Cloud9IDE** output. Click on the associated link to launch the Cloud9 IDE.

During the initial start-up of the Cloud9 IDE a number of steps will automatically run to prepare the environment for first use. The steps include cloning an AWS CodeCommit repository in to the Cloud9 IDE workspace.

11.	At the command prompt run the following command to download and execute the IDE build and configuration script.

```
wget https://raw.githubusercontent.com/aws-samples/amazon-ecs-catsndogs-workshop/master/scripts/ide-build-script.sh -O ~/environment/ide-build-script.sh && \
chmod +x ~/environment/ide-build-script.sh && \
~/environment/ide-build-script.sh
```

12.	When prompted, enter your **name**, and an **email address** to complete the configuration of the git client.

13.	The Cloud9 IDE is now configured.

## 6.2	Create an AWS CodePipeline pipeline

In this step, you will create a new AWS CodePipeline pipeline that you will use to orchestrate the deployment the new version of the Dogs application to your Amazon ECS cluster.

1.	Sign-in to the AWS management console and open the AWS CodePipeline console at https://console.aws.amazon.com/codepipeline/.

2.	If you see the introductory page, choose **Get started**, otherwise, choose **Create pipeline**.

3.	In **Step 1: Name**, in **Pipeline name**, type CatsnDogsPipeline, and then click **Next step**.

4.	In **Step 2: Source**, in **Service provider**, choose **AWS CodeCommit**. In **AWS CodeCommit**, for **Repository name**, type the name of the repository with **Dogs** in the name. For **Branch name**, type **master**. This CodeCommit repository was created by the CloudFormation stack you deployed at the start of the workshop.

5.	Expand, **Change detection options**, and choose **Use Amazon CloudWatch Events to automatically start my pipeline when a change occurs**.

**Note:** Using CloudWatch Events to start the pipeline is preferred to having CodePipeline periodically check the repository for changes. When choosing this method, an Amazon CloudWatch Events rule and associated IAM role are created automatically. More details can be found here: https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-about-starting.html

6.	In **Step 3: Build**, choose **AWS CodeBuild**.

7.	Under **Configure your project** choose **Create a new build project**.

8.	Name your project **CatsnDogsBuild**.

9.	Under **Environment: How to build**:

    1.	In **Environment image**, choose **Use an image managed by AWS CodeBuild**.

    2.	In **Operating system**, choose **Ubuntu**.

    3.	In **Runtime**, choose **Docker**.

    4.	In **Version**, choose **aws/codebuild/docker:17.09.0**.

    5.	In **Build specification**, choose **Use the buildspec.yml in the source code root directory**.

**Note:** The buildspec.yml is one of the files that have been placed in the CodeCommit repository.

10.	For **AWS CodeBuild Service Role**, select **Choose an existing service role from your account**, use IAM the role with **CatsnDogsBuild** in the name.

11.	In **VPC**, for **VPC ID**, choose **No VPC**.

12.	Expand **Advanced**:

    1.	In **Environment variables** add the following:

        1.	**AWS_DEFAULT_REGION:** <your AWS region>

        2.	**AWS_ACCOUNT_ID:** <the account ID of your AWS account>

        3.	**REPOSITORY_URI:** <URI of your dogs ECR repository> for example: 12345567891011.dkr.ecr.ap-southeast-2.amazonaws.com/dogs

**Note:** The URI of your dogs repository is listed in the ECS Console. Click on Repositories, then on the dogs repository.

13.	Click **Save build project**.

14.	Click **Next step**.

15.	In **Step 4: Deploy**, in **Deploy**:

    1.	 For **Deployment provider**, choose **Amazon ECS**.

    2.	In **Amazon ECS**:

        1.	For **Cluster name**, choose the cluster with **catsndogs** in the name.

        2.	For **Service name**, choose the service with **Dogs** in the name.

        3.	For **Image filename**, enter **imagedefinitions.json**. This JSON file describes the service container name, image and tag.

        4.	Click **Next**.

16.	In **Step 5: Service Role**, in **Role name** choose the IAM role with **CatsnDogsPipeline** in the name and click **Next step**.

17.	Review the settings and click **Create pipeline**.

## 6.3	Deploy a new version of the Dogs application

The development team at catsndogs.lol would like you to deploy a new revision of the Dogs application, to test the pipeline. You will do this by making a small change to the index.html file of the Dogs application.

1.	Sign in to the AWS management console, click on **Services**.

2.	In the **Management Tools** section, click **CloudFormation**.

3.	Click on the stack **catsndog-ide**.

4.	Expand **Outputs**, locate the **Cloud9IDE** output. Click on the associated link to launch the Cloud9 IDE.

5.	At the command prompt run `cd ~/environment/dogs` to switch to the local clone of the Dogs application repository.

6.	Run the command `nano index.html` to edit the index.html file.

7.	Locate the `background` property, within the ``<style>`` tags, and change the value to another color. For example, ``“background: blue;”``

8.	Within the nano editor press `ctrl + x` to exit the editor. When prompted type `Y` to confirm that the changes should be saved.

9.	Commit the changes that have just been made t and push them to the remote repository by running the following commands:

    1.	`git add index.html`

    2.	`git command -m ‘changing background color’`

    3.	`git push`

10.	Open the AWS management console, and open the **AWS CodePipeline** console at https://console.aws.amazon.com/codepipeline/.

11.	To verify your pipeline ran successfully:

    1.	From the **All Pipelines** table, click the **CatsnDogsPipeline**, to monitor the progress of your pipeline.

    2.	The status of each stage should change from No executions yet to **In progress**, and then **Succeeded** or **Failed**. The pipeline should complete the first run within a few minutes.

12.	Copy the value of the **LoadBalancerDNSName**, created by the **catsndogssetup** CloudFormation stack that was deployed at the start of the workshop, in to you address bar of your web browser.

The Dogs application page should appear with fancy new background color.

The build process for the dogs container image uses the AWS CLI to copy the latest dog memes from an S3 bucket. Although the images are publicly readable, any S3 operation requires AWS credentials. In this case, the credentials from the build environment need to be passed through to the container image build process, otherwise the build process will fail with “Unable to locate credentials”. More details can be found here: http://docs.aws.amazon.com/codebuild/latest/userguide/troubleshooting.html#troubleshooting-versions

### Extension activity:

Examine the buildspec.yml file in the CodeCommit repository, to understand the steps the CodeBuild project is taking to build and push the container image. How is the image tagged? How does the CodePipeline pipeline retrieve the tag, to use as a parameter when updating the ECS service?

# What's Next
[Advanced Deployment Techniques](../Lab-7-Artifacts/)
