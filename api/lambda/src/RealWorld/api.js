const elmServerless = require('@the-sett/serverless-elm-bridge');
const aws = require('./aws-port.js');

const {
  Elm
} = require('./API.elm');

if (!process.env.AWS_REGION) {
  process.env.AWS_REGION = 'us-east-1';
}

if (!process.env.DYNAMODB_NAMESPACE) {
  process.env.DYNAMODB_NAMESPACE = 'dev';
}

function ping() {
  return {
    pong: new Date(),
    AWS_REGION: process.env.AWS_REGION,
    DYNAMODB_NAMESPACE: process.env.DYNAMODB_NAMESPACE,
  };
}

const app = Elm.RealWorld.API.init();

if (app.ports != null && app.ports.dynamoGetRequest != null) {
  app.ports.dynamoGetRequest.subscribe(args => {
    const connectionId = args[0];

    app.ports.dynamoGetResponse.send([connectionId, ""]);
  });
}

// Create the serverless handler with the ports.
module.exports.handler = elmServerless.httpApi({
  app
});
