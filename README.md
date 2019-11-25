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

To close the node process that is running serverless offline:

    gulp kill

## Deployment to AWS

In order to deploy as an AWS Lambda functions you need the following:

1. An AWS account.
2. An AWS user configured with sufficient permissions to be able to deploy a Lambda function.
3. To be logged into AWS as that user.

A policy has been created that yields sufficient permission to deploy these demos.
This can be found in the 'deploy-policy.json' file.

    npm install
    npm run deploy

Note: At the moment the AWS deployment is hard-coded to the 'default' profile and the 'eu-west-2' region.

## Other FaaS platforms

The serverless framework supports many more function as a service platforms - too many
to cover here. Consult the serverless documentation for more information.
