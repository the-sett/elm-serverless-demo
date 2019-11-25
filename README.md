=== Demo of elm-serverless

=== Running Locally

To run the API locally:

    npm install
    gulp offline

=== Deployment to AWS

To create the infrastructure using CloudFoundry a number of permissions are required. A policy has been created that yields sufficient permission to deploy this application. This can be found in the 'deploy-policy.json' file.

    npm install
    gulp deploy

Note: At the moment the AWS deployment is hard-coded to the 'default' profile and the 'eu-west-2' region.
