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

=== Deployment to AWS

To create the infrastructure using CloudFoundry a number of permissions are required. A policy has been created that yields sufficient permission to deploy this application. This can be found in the 'deploy-policy.json' file.

    npm install
    gulp deploy

Note: At the moment the AWS deployment is hard-coded to the 'default' profile and the 'eu-west-2' region.
