port module RealWorld.Dynamo exposing
    ( dynamoCreateSetRequest
    , dynamoCreateSetResponse
    , dynamoDeleteRequest
    , dynamoDeleteResponse
    , dynamoGetRequest
    , dynamoGetResponse
    , dynamoPutRequest
    , dynamoPutResponse
    , dynamoQueryRequest
    , dynamoQueryResponse
    , dynamoScanRequest
    , dynamoScanResponse
    )

import Serverless


port dynamoPutRequest : Serverless.InteropRequestPort () msg


port dynamoPutResponse : Serverless.InteropResponsePort msg


port dynamoGetRequest : Serverless.InteropRequestPort () msg


port dynamoGetResponse : Serverless.InteropResponsePort msg


port dynamoScanRequest : Serverless.InteropRequestPort () msg


port dynamoScanResponse : Serverless.InteropResponsePort msg


port dynamoQueryRequest : Serverless.InteropRequestPort () msg


port dynamoQueryResponse : Serverless.InteropResponsePort msg


port dynamoCreateSetRequest : Serverless.InteropRequestPort () msg


port dynamoCreateSetResponse : Serverless.InteropResponsePort msg


port dynamoDeleteRequest : Serverless.InteropRequestPort () msg


port dynamoDeleteResponse : Serverless.InteropResponsePort msg
