# Lab 6 - Automated Deployments
### Overview
The catsndogs.lol development team are planning to release updates to their applications more frequently. They want to build an automated deployment pipeline, that can be used to deploy updated versions of their applications with minimal manual intervention, to reduce the time it takes to get exciting new capabilities in the hands of their users.
In this lab, you will set up an AWS CodePipeline that is triggered when changes are made to application source code hosted in an AWS CodeCommit repository. CodePipeline will coordinate building and deploying the container based application.
You will create an AWS CodeBuild project that builds the container image and pushes it to an Amazon ECR repository. The CodeBuild project will tag the newly built dogs container image with a version number.
You will use AWS CodePipeline to deploy the updates the existing ECS tasks and services. The pipeline update the task definition for the Dogs application to reflect the newly created container image.


### High-level Instructions

1.	Deploy a CloudFormation stack using the `Lab6-create-ide.yml` template file from the cfn-templates folder. This will create an instance of AWS Cloud9, a cloud-based integrated development environment (IDE) that will let you write, run, and debug software using just a web browser.

2.  Launch the Cloud9 IDE and run the following command to complete the setup of the Cloud9 IDE environment. The launch URL for the Cloud9 IDE is an output of the stack which was just created. The output key is: `Cloud9IDE`

    ```
    aws s3 cp s3://catsndogs-artifacts/lab-ide-build.sh . && \
    chmod +x lab-ide-build.sh && \
    . ./lab-ide-build.sh
    ```

During the initial start-up of the Cloud9 IDE a number of steps will automatically run to prepare the environment for first use. The steps include cloning an AWS CodeCommit repository in to the AWS Cloud9 IDE workspace.

3.	Create a new CodePipeline pipeline. The Source should be the AWS CodeCommit repository that was automatically created as part of the initial workshop setup. In the Build step, create a new CodeBuild project. For the build environment, use an image managed by AWS CodeBuild. Use the Ubuntu Docker image version *17.09.0*.

    1.	Use the role with CatsnDogsBuild in the name.

    2.	In Advanced settings, add three environment variables:

        1. **AWS_DEFAULT_REGION**: *<your AWS region>* for example `US-EAST-1`

        2. **AWS_ACCOUNT_ID**: *<the account ID of your AWS account>*

        3. **REPOSITORY_URI**: *<URI of your dogs ECR repository>* for example: `1234567891011.dkr.ecr.us-east-1.amazonaws.com/dogs`

    3.	Choose Amazon ECS for the Deployment provider, and configured the following values:

        1. **Cluster name**: choose the cluster with **catsndogs** in the name.

        2. **Service name**: choose the service with **Dogs** in the name

        3. **Image filename**: enter **imagedefinitions.json**. This JSON file describes the service container name, image and tag

    4.	Use the IAM role with **CatsnDogsPipeline** in the name.

4. Using the Cloud9 IDE, edit the background color of the Dogs application, commit the changes and push them to the CodeCommit repository. This will tigger the CodePipeline pipeline and deploy the changes to production.

5.	Copy the value of the LoadBalancerDNSName, created by the **catsndogssetup** CloudFormation stack that was deployed at the start of the workshop, in to you address bar of your web browser. The Dogs application page should appear with fancy new background color.

The build process for the dogs container image uses the AWS CLI to copy the latest dog memes from an S3 bucket. Although the images are publicly readable, any S3 operation requires AWS credentials. In this case, the credentials from the build environment need to be passed through to the container image build process, otherwise the build process will fail with “Unable to locate credentials”.
More details can be found here: http://docs.aws.amazon.com/codebuild/latest/userguide/troubleshooting.html#troubleshooting-versions

**Extension activity:** Examine the buildspec.yml file in the CodeCommit repository, to understand the steps the CodeBuild project is taking to build and push the container image. How is the image tagged? How does the CodePipeline pipeline retrieve the tag, to use as a parameter when updating the CloudFormation stack?

# What's Next
[Advanced Deployment Techniques](../Lab-7-Artifacts/)

# Detailed Instructions
[Advanced Deployment Techniques - Detailed Instructions](./lab6-detailed-steps.md)
