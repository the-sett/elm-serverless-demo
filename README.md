# Demo of elm-serverless

Demos of the elm-serverless API.

**Contacts for Support**
- @rupertlssmith on https://elmlang.slack.com
- @rupert on https://discourse.elm-lang.org

## Running Locally

To run the API locally:

    npm install
    npm start

Open the localhost demo endpoints in your browser. For example, the hello world is
running at : http://localhost:3000/

To close the process that is running serverless:

    npm stop

## Deployment to AWS

In order to deploy as an AWS Lambda functions you need the following:

1. An AWS account.
2. An AWS user configured with sufficient permissions to be able to deploy a Lambda function.
3. To be logged into AWS as that user.

### 1 Create an AWS account.

You can find a link to create a new AWS account here:

https://aws.amazon.com/console/

It is normal to set up a root user for the account, but not to use that root user for
day-to-day development work on the account. Instead another user should be set up for
this, and only given the permissions that it needs.

If you are not familiar with AWS you should consult some of the getting started
documentation. The following link provides some information on setting up beyond the root
user:

https://docs.aws.amazon.com/IAM/latest/UserGuide/id_root-user.html

### 2 Configure a deployment user.

As noted above, you should create a user with sufficient permission to deploy these demos.

Permissions in AWS are described by a 'policy'. A policy has been created that yields sufficient permission to deploy these demos and this can be found in the 'deploy-policy.json' file. Use the IAM console to create this policy.

Using the IAM console, create a role with a suitable name such as 'deployment', and assign
the policy to that role.

Again using the IAM console, create a user for your development work, and assign the 'deployment' role to that user.

### 3 Deploy the Demos as the deployment user.

To deploy as the AWS user created above, you need to create a configuration for the AWS cli tool, with the access keys for the user. Once this is done, the configured user will be picked up by the serverless framework as the one to use for deployment. The following link
shows how to do this:

https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html

To deploy the demos to AWS:

    npm install
    npm run deploy

If the deployment is successful serverless will print the URLs to access the lambda functions
on the console.

```
[gulp-chug] (api/lambda/gulpfile.tmp.1574775778046.js) endpoints:
  ANY - https://037tw7dhw6.execute-api.us-east-1.amazonaws.com/dev/
  ... More but only showing the hello world one above.
```

You can also look at the CloudFormation service on the AWS console to check that the complete
serverless stack has deploy successfully.

To shut down and remove the demos from AWS:

    npm run undeploy

## Other FaaS platforms

The serverless framework supports many more function as a service platforms - too many
to cover here. Consult the serverless documentation for more information.
