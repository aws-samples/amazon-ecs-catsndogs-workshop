# Lab 6 - Automated Deployments
### Overview
The catsndogs.lol development team are planning to release updates to their applications more frequently. They want to build an automated deployment pipeline, that can be used to deploy updated versions of their applications with minimal manual intervention, to reduce the time it takes to get exciting new capabilities in the hands of their users.
In this lab, you will set up AWS CodePipeline to monitor an S3 bucket for changes to the source code. When new source code is uploaded to the bucket, CodePipeline will coordinate building and deploying the Docker based application.
You will create an AWS CodeBuild project build the Docker image and push it to a repository. The CodeBuild project will tag the newly built dogs containers with a version number.
You will also integrate AWS CodePipeline with AWS CloudFormation to update the existing ECS tasks and services. The pipeline will use the version number of the dogs containers as a parameter when updating the CloudFormation stack, so that the right version of the container is deployed.

### High-level Instructions
1.	From the Lab-6-Artifacts folder, upload the templates.zip and dogs.zip to the S3 bucket with CodeUploadS3Bucket in the name. Templates.zip contains a copy of the templates from earlier labs, and dogs.zip contains source code for the dogs container.

2.	Create a new CodePipeline pipeline. The Source should be the dogs.zip you uploaded to the S3 bucket. In the Build step, create a new CodeBuild project. For the build environment, use an image managed by AWS CodeBuild. Use the Ubuntu Docker image version 1.12.1.

    a.	Use the role with CatsnDogsBuild in the name.

    b.	In Advanced settings, add three environment variables:

      AWS_DEFAULT_REGION: **<your AWS region>** *for example ap-southeast-2*

      AWS_ACCOUNT_ID: **<the account ID of your AWS account>**

      REPOSITORY_URI: **<URI of your dogs ECR repository>** *for example: 1234567891011.dkr.ecr.ap-southeast-2.amazonaws.com/dogs*

    c.	Do not configure a deployment provider. You will configure a custom deployment provider in a later step with more details than are provided for in the wizard.

    d.	Use the IAM role with CatsnDogsPipeline in the name.

Because you have already deployed tasks and services to your cluster using CloudFormation, you will continue to use that as the deployment tool. CloudFormation will perform a stack update to update the running tasks and services. To use CloudFormation as part of the pipeline, the template needs to be defined within the pipeline.

3. Edit the pipeline Source stage and add a new Action. Use the S3 source provider, and specify the location of the templates.zip that you uploaded to the S3 bucket. In Output artifact, enter **template**

4.	You will now configure a customized Deploy state which uses CloudFormation. Add a new Deploy stage to the end of the pipeline. Choose CloudFormation as the deployment provider.

    a.	For Action mode, choose Create or update a stack.

    b.	Update the stack from lab 2. If you followed the instructions, this should be called *catsndogsECStasksandservices*

    c.	In Template file enter: `template::Lab2-create-ecs-tasks-and-services.yml`

    This will use the “template” output artifact from the Source step, and the Lab2-create-ecs-tasks-and-services.yml contained within that artifact.

    d.	Leave the configuration file blank

    e.	For Capabilities, choose CAPABILITY_NAMED_IAM

    f.	For the IAM role, choose the role with CatsnDogsCloudFormation in the name.

    g.	In Advanced, enter the following in Parameter Overrides. Replace the accountid and region with your AWS account ID and region:

        { "DogTag": { "Fn::GetParam" : [ "MyAppBuild", "build.json", "tag" ] }, "ImageRepo": "<accountid>.dkr.ecr.<region>.amazonaws.com"}

      For example:

        { "DogTag": { "Fn::GetParam" : [ "MyAppBuild", "build.json", "tag" ] }, "ImageRepo": "123456789011.dkr.ecr.ap-southeast-2.amazonaws.com"}

The parameter override updates the CloudFormation *DogTag* parameter with the Docker image tag created during the build process. *DogTag* will be replaced with the tag associated with the new image created by the Build state, and *ImageRepo* will be replaced with the URL of your repository.  More information about parameter overrides can be found in the CodePipeline documentation: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/continuous-delivery-codepipeline-parameter-override-functions.html

    h.	In Input artifacts, for Input artifact #1 choose **template** and for Input artifact #2 choose **MyAppBuild**

5.	From the [Lab-6-Artifacts/v2](v2/) folder, upload dogs.zip to the S3 bucket. This version of the container includes a new-style background. Once the upload is complete, verify the pipeline runs successfully.

6.	While the pipeline is running, open the CodeBuild console and view the Build History of the most recent build. You should be able to see the logs from the build.

7.	It may take a few minutes for the new containers to deploy, after which the new Dogs pages should display with fancy new background color.

The build process for the dogs Docker image uses the AWS CLI to copy the latest dog memes from an S3 bucket. Although the images are publicly readable, any S3 operation requires AWS credentials. In this case, the credentials from the build environment need to be passed through to the Docker build process, otherwise the build process will fail with “Unable to locate credentials”.
More details can be found here: http://docs.aws.amazon.com/codebuild/latest/userguide/troubleshooting.html#troubleshooting-versions

**Extension activity:** Examine the buildspec.yml file in the dogs.zip file, to understand the steps the CodeBuild project is taking to build and push the docker image. How is the image tagged? How does the CodePipeline pipeline retrieve the tag, to use as a parameter when updating the CloudFormation stack?

# What's Next
[Advanced Deployment Techniques](../Lab-7-Artifacts/)
