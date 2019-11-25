port module RealWorld.API exposing (main)

import Array exposing (Array)
import Codec
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Model
import RealWorld.Dynamo
import Serverless
import Serverless.Conn exposing (jsonBody, method, request, respond, route, textBody)
import Serverless.Conn.Request exposing (Method(..), Request, asJson, body)
import Url
import Url.Parser exposing ((</>), (<?>), int, map, oneOf, s, top)
import Url.Parser.Query as Query



-- Dummy data for mocking the API.


userResponse : Model.UserResponse
userResponse =
    { user =
        { email = "jake@jake.jake"
        , token = "jwt.token.here"
        , username = "jake"
        , bio = "I work at statefarm"
        , image = ""
        }
    }


profileResponse : Model.ProfileResponse
profileResponse =
    { profile =
        { username = "jake"
        , bio = "I work at statefarm"
        , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
        , following = False
        }
    }


followProfileResponse : Model.ProfileResponse
followProfileResponse =
    { profile =
        { username = "jake"
        , bio = "I work at statefarm"
        , image = "https://static.productionready.io/images/smiley-cyrus.jpg"
        , following = True
        }
    }


singleArticle : Model.SingleArticleResponse
singleArticle =
    { article =
        { slug = "how-to-train-your-dragon"
        , title = "How to train your dragon"
        , description = "Ever wonder how?"
        , body = "It takes a Jacobian"
        , tagList = [ "dragons", "training" ]
        , createdAt = "2016-02-18T03:22:56.637Z"
        , updatedAt = "2016-02-18T03:48:35.824Z"
        , favorited = False
        , favoritesCount = 0
        , author =
            { username = "jake"
            , bio = "I work at statefarm"
            , image = "https=//i.stack.imgur.com/xHWG8.jpg"
            , following = False
            }
        }
    }


favoriteArticle : Model.SingleArticleResponse
favoriteArticle =
    { article =
        { slug = "how-to-train-your-dragon"
        , title = "How to train your dragon"
        , description = "Ever wonder how?"
        , body = "It takes a Jacobian"
        , tagList = [ "dragons", "training" ]
        , createdAt = "2016-02-18T03:22:56.637Z"
        , updatedAt = "2016-02-18T03:48:35.824Z"
        , favorited = True
        , favoritesCount = 1
        , author =
            { username = "jake"
            , bio = "I work at statefarm"
            , image = "https=//i.stack.imgur.com/xHWG8.jpg"
            , following = False
            }
        }
    }


multipleArticles : Model.MultipleArticlesResponse
multipleArticles =
    { articles =
        [ { slug = "how-to-train-your-dragon"
          , title = "How to train your dragon"
          , description = "Ever wonder how?"
          , body = "It takes a Jacobian"
          , tagList = [ "dragons", "training" ]
          , createdAt = "2016-02-18T03:22:56.637Z"
          , updatedAt = "2016-02-18T03:48:35.824Z"
          , favorited = False
          , favoritesCount = 0
          , author =
                { username = "jake"
                , bio = "I work at statefarm"
                , image = "https=//i.stack.imgur.com/xHWG8.jpg"
                , following = False
                }
          }
        , { slug = "how-to-train-your-dragon-2"
          , title = "How to train your dragon 2"
          , description = "So toothless"
          , body = "It a dragon"
          , tagList = [ "dragons", "training" ]
          , createdAt = "2016-02-18T03:22:56.637Z"
          , updatedAt = "2016-02-18T03:48:35.824Z"
          , favorited = False
          , favoritesCount = 0
          , author =
                { username = "jake"
                , bio = "I work at statefarm"
                , image = "https=//i.stack.imgur.com/xHWG8.jpg"
                , following = False
                }
          }
        ]
    , articlesCount = 2
    }


singleComment : Model.SingleCommentResponse
singleComment =
    { comment =
        { id = "1"
        , createdAt = "2016-02-18T03:22:56.637Z"
        , updatedAt = "2016-02-18T03:22:56.637Z"
        , body = "It takes a Jacobian"
        , author =
            { username = "jake"
            , bio = "I work at statefarm"
            , image = "https://i.stack.imgur.com/xHWG8.jpg"
            , following = False
            }
        }
    }


multipleComments : Model.MultipleCommentsResponse
multipleComments =
    { comments =
        [ { id = "1"
          , createdAt = "2016-02-18T03:22:56.637Z"
          , updatedAt = "2016-02-18T03:22:56.637Z"
          , body = "It takes a Jacobian"
          , author =
                { username = "jake"
                , bio = "I work at statefarm"
                , image = "https://i.stack.imgur.com/xHWG8.jpg"
                , following = False
                }
          }
        ]
    }


tagsResponse : Model.TagsResponse
tagsResponse =
    { tags =
        [ "reactjs"
        , "angularjs"
        ]
    }



-- Servlerless program.


port requestPort : Serverless.RequestPort msg


port responsePort : Serverless.ResponsePort msg


type alias Conn =
    Serverless.Conn.Conn () () Route


type alias Msg =
    ()


main : Serverless.Program () () Route Msg
main =
    Serverless.httpApi
        { configDecoder = Serverless.noConfig
        , initialModel = ()
        , parseRoute = routeParser
        , endpoint = router
        , update = update
        , requestPort = requestPort
        , responsePort = responsePort
        , interopPorts = Serverless.noPorts
        }



-- Route and query parsing.


type Route
    = Users
    | UsersLogin
    | ProfilesId String
    | ProfilesIdFollow String
    | Articles ArticleQuery
    | ArticlesSlug String
    | ArticlesFeed PaginationQuery
    | ArticlesSlugFavorite String
    | ArticlesSlugComments String
    | ArticlesSlugCommentsId String String
    | Tags
    | Ping


type alias ArticleQuery =
    { tag : Maybe String
    , author : Maybe String
    , favorited : Maybe String
    , limit : Maybe Int
    , offset : Maybe Int
    }


type alias PaginationQuery =
    { limit : Maybe Int
    , offset : Maybe Int
    }


routeParser : Url.Url -> Maybe Route
routeParser =
    let
        articleQuery =
            Query.map5 ArticleQuery
                (Query.string "tag")
                (Query.string "author")
                (Query.string "favorited")
                (Query.int "limit")
                (Query.int "offset")

        paginationQuery =
            Query.map2 PaginationQuery
                (Query.int "limit")
                (Query.int "offset")
    in
    oneOf
        [ map Users (s "users")
        , map Users (s "user")
        , map UsersLogin (s "users" </> s "login")
        , map ProfilesId (s "profiles" </> Url.Parser.string)
        , map ProfilesIdFollow (s "profiles" </> Url.Parser.string </> s "follow")
        , map Articles (s "articles" <?> articleQuery)
        , map ArticlesFeed (s "articles" </> s "feed" <?> paginationQuery)
        , map ArticlesSlug (s "articles" </> Url.Parser.string)
        , map ArticlesSlugFavorite (s "articles" </> Url.Parser.string </> s "favorite")
        , map ArticlesSlugComments (s "articles" </> Url.Parser.string </> s "comments")
        , map ArticlesSlugCommentsId (s "articles" </> Url.Parser.string </> s "comments" </> Url.Parser.string)
        , map Tags (s "tags")
        , map Ping (s "ping")
        ]
        |> Url.Parser.parse



-- Route processing.


router : Conn -> ( Conn, Cmd Msg )
router conn =
    case ( method conn, Debug.log "route" <| route conn ) of
        ( POST, Users ) ->
            newUserRoute conn

        ( GET, Users ) ->
            getCurrentUserRoute conn

        ( PUT, Users ) ->
            updateUserRoute conn

        ( POST, UsersLogin ) ->
            loginRoute conn

        ( GET, ProfilesId id ) ->
            fetchProfileRoute id conn

        ( POST, ProfilesIdFollow id ) ->
            followProfileRoute id conn

        ( DELETE, ProfilesIdFollow id ) ->
            unfollowProfileRoute id conn

        ( GET, Articles query ) ->
            fetchArticlesRoute query conn

        ( POST, Articles _ ) ->
            newArticleRoute conn

        ( GET, ArticlesSlug slug ) ->
            fetchArticleRoute slug conn

        ( PUT, ArticlesSlug slug ) ->
            updateArticleRoute slug conn

        ( GET, ArticlesFeed query ) ->
            fetchFeedRoute query conn

        ( POST, ArticlesSlugFavorite slug ) ->
            favoriteArticleRoute slug conn

        ( DELETE, ArticlesSlugFavorite slug ) ->
            unfavoriteArticleRoute slug conn

        ( POST, ArticlesSlugComments slug ) ->
            postCommentRoute slug conn

        ( GET, ArticlesSlugComments slug ) ->
            fetchCommentsRoute slug conn

        ( DELETE, ArticlesSlugCommentsId slug id ) ->
            removeCommentRoute slug id conn

        ( GET, Tags ) ->
            fetchTagsRoute conn

        ( _, Ping ) ->
            pingRoute conn

        ( _, _ ) ->
            respond ( 405, textBody "Method not allowed" ) conn


newUserRoute : Conn -> ( Conn, Cmd Msg )
newUserRoute conn =
    let
        decodeResult =
            bodyDecoder Model.newUserRequestCodec conn
    in
    case decodeResult of
        Ok { user } ->
            let
                response =
                    userResponse
            in
            respond ( 201, response |> Codec.encodeToValue Model.userResponseCodec |> jsonBody ) conn

        Err errMsg ->
            respond ( 422, textBody errMsg ) conn


getCurrentUserRoute : Conn -> ( Conn, Cmd Msg )
getCurrentUserRoute conn =
    let
        response =
            userResponse
    in
    respond ( 200, response |> Codec.encodeToValue Model.userResponseCodec |> jsonBody ) conn


updateUserRoute : Conn -> ( Conn, Cmd Msg )
updateUserRoute conn =
    let
        decodeResult =
            bodyDecoder Model.updateUserRequestCodec conn
    in
    case decodeResult of
        Ok { user } ->
            let
                response =
                    userResponse
            in
            respond ( 200, response |> Codec.encodeToValue Model.userResponseCodec |> jsonBody ) conn

        Err errMsg ->
            respond ( 422, textBody errMsg ) conn


loginRoute : Conn -> ( Conn, Cmd Msg )
loginRoute conn =
    let
        decodeResult =
            bodyDecoder Model.loginUserRequestCodec conn
    in
    case decodeResult of
        Ok { user } ->
            let
                response =
                    userResponse
            in
            respond ( 200, response |> Codec.encodeToValue Model.userResponseCodec |> jsonBody ) conn

        Err errMsg ->
            respond ( 422, textBody errMsg ) conn


fetchProfileRoute : String -> Conn -> ( Conn, Cmd Msg )
fetchProfileRoute id conn =
    let
        response =
            profileResponse
    in
    respond ( 200, response |> Codec.encodeToValue Model.profileResponseCodec |> jsonBody ) conn


followProfileRoute : String -> Conn -> ( Conn, Cmd Msg )
followProfileRoute id conn =
    let
        response =
            followProfileResponse
    in
    respond ( 200, response |> Codec.encodeToValue Model.profileResponseCodec |> jsonBody ) conn


unfollowProfileRoute : String -> Conn -> ( Conn, Cmd Msg )
unfollowProfileRoute id conn =
    let
        response =
            profileResponse
    in
    respond ( 200, response |> Codec.encodeToValue Model.profileResponseCodec |> jsonBody ) conn


fetchArticlesRoute : ArticleQuery -> Conn -> ( Conn, Cmd Msg )
fetchArticlesRoute query conn =
    let
        response =
            multipleArticles
    in
    respond ( 200, response |> Codec.encodeToValue Model.multipleArticlesResponseCodec |> jsonBody ) conn


newArticleRoute : Conn -> ( Conn, Cmd Msg )
newArticleRoute conn =
    let
        decodeResult =
            bodyDecoder Model.newArticleRequestCodec conn
    in
    case decodeResult of
        Ok { article } ->
            let
                response =
                    singleArticle
            in
            respond ( 201, response |> Codec.encodeToValue Model.singleArticleResponseCodec |> jsonBody ) conn

        Err errMsg ->
            respond ( 422, textBody errMsg ) conn


fetchArticleRoute : String -> Conn -> ( Conn, Cmd Msg )
fetchArticleRoute slug conn =
    let
        response =
            singleArticle
    in
    respond ( 201, response |> Codec.encodeToValue Model.singleArticleResponseCodec |> jsonBody ) conn


updateArticleRoute : String -> Conn -> ( Conn, Cmd Msg )
updateArticleRoute slug conn =
    let
        decodeResult =
            bodyDecoder Model.updateArticleRequestCodec conn
    in
    case decodeResult of
        Ok { article } ->
            let
                response =
                    singleArticle
            in
            respond ( 201, response |> Codec.encodeToValue Model.singleArticleResponseCodec |> jsonBody ) conn

        Err errMsg ->
            respond ( 422, textBody errMsg ) conn


fetchFeedRoute : PaginationQuery -> Conn -> ( Conn, Cmd Msg )
fetchFeedRoute query conn =
    let
        response =
            multipleArticles
    in
    respond ( 200, response |> Codec.encodeToValue Model.multipleArticlesResponseCodec |> jsonBody ) conn


favoriteArticleRoute : String -> Conn -> ( Conn, Cmd Msg )
favoriteArticleRoute slug conn =
    let
        response =
            favoriteArticle
    in
    respond ( 200, response |> Codec.encodeToValue Model.singleArticleResponseCodec |> jsonBody ) conn


unfavoriteArticleRoute : String -> Conn -> ( Conn, Cmd Msg )
unfavoriteArticleRoute slug conn =
    let
        response =
            singleArticle
    in
    respond ( 200, response |> Codec.encodeToValue Model.singleArticleResponseCodec |> jsonBody ) conn


postCommentRoute : String -> Conn -> ( Conn, Cmd Msg )
postCommentRoute slug conn =
    let
        decodeResult =
            bodyDecoder Model.newCommentRequestCodec conn
    in
    case decodeResult of
        Ok { comment } ->
            let
                response =
                    singleComment
            in
            respond ( 200, response |> Codec.encodeToValue Model.singleCommentResponseCodec |> jsonBody ) conn

        Err errMsg ->
            respond ( 422, textBody errMsg ) conn


fetchCommentsRoute : String -> Conn -> ( Conn, Cmd Msg )
fetchCommentsRoute slug conn =
    let
        response =
            multipleComments
    in
    respond ( 200, response |> Codec.encodeToValue Model.multipleCommentsResponseCodec |> jsonBody ) conn


removeCommentRoute : String -> String -> Conn -> ( Conn, Cmd Msg )
removeCommentRoute slug id conn =
    let
        response =
            singleComment
    in
    respond ( 200, response |> Codec.encodeToValue Model.singleCommentResponseCodec |> jsonBody ) conn


fetchTagsRoute : Conn -> ( Conn, Cmd Msg )
fetchTagsRoute conn =
    let
        response =
            tagsResponse
    in
    respond ( 200, response |> Codec.encodeToValue Model.tagsResponseCodec |> jsonBody ) conn


pingRoute : Conn -> ( Conn, Cmd Msg )
pingRoute conn =
    respond ( 200, textBody "pong" ) conn



-- Side effects.


update : Msg -> Conn -> ( Conn, Cmd Msg )
update seed conn =
    ( conn, Cmd.none )



-- Helper functions


bodyDecoder : Codec.Codec a -> Conn -> Result String a
bodyDecoder codec conn =
    conn
        |> request
        |> body
        |> asJson
        |> Result.andThen
            (Codec.decodeValue codec
                >> Result.mapError Decode.errorToString
            )
