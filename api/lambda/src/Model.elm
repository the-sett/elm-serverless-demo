module Model exposing
    ( Article
    , Comment
    , LoginUser
    , LoginUserRequest
    , MultipleArticlesResponse
    , MultipleCommentsResponse
    , NewArticle
    , NewArticleRequest
    , NewComment
    , NewCommentRequest
    , NewUser
    , NewUserRequest
    , Profile
    , ProfileResponse
    , SingleArticleResponse
    , SingleCommentResponse
    , TagsResponse
    , UpdateArticle
    , UpdateArticleRequest
    , UpdateUser
    , UpdateUserRequest
    , User
    , UserResponse
    , articleCodec
    , commentCodec
    , loginUserCodec
    , loginUserRequestCodec
    , multipleArticlesResponseCodec
    , multipleCommentsResponseCodec
    , newArticleCodec
    , newArticleRequestCodec
    , newCommentCodec
    , newCommentRequestCodec
    , newUserCodec
    , newUserRequestCodec
    , profileCodec
    , profileResponseCodec
    , singleArticleResponseCodec
    , singleCommentResponseCodec
    , tagsResponseCodec
    , updateArticleCodec
    , updateArticleRequestCodec
    , updateUserCodec
    , updateUserRequestCodec
    , userCodec
    , userResponseCodec
    )

import Codec
import Dict exposing (Dict)
import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing (andMap, withDefault)
import Json.Encode as Encode exposing (..)
import Maybe.Extra
import Set exposing (Set)


type alias NewUser =
    { username : String
    , email : String
    , password : String
    }


newUserCodec =
    Codec.object NewUser
        |> Codec.field "username" .username Codec.string
        |> Codec.field "email" .email Codec.string
        |> Codec.field "password" .password Codec.string
        |> Codec.buildObject


type alias NewUserRequest =
    { user : NewUser }


newUserRequestCodec =
    Codec.object NewUserRequest
        |> Codec.field "user" .user newUserCodec
        |> Codec.buildObject


type alias UserResponse =
    { user : User }


userResponseCodec =
    Codec.object UserResponse
        |> Codec.field "user" .user userCodec
        |> Codec.buildObject


type alias User =
    { email : String
    , token : String
    , username : String
    , bio : String
    , image : String
    }


userCodec =
    Codec.object User
        |> Codec.field "email" .email Codec.string
        |> Codec.field "token" .token Codec.string
        |> Codec.field "username" .username Codec.string
        |> Codec.field "bio" .bio Codec.string
        |> Codec.field "image" .image Codec.string
        |> Codec.buildObject


type alias LoginUserRequest =
    { user : LoginUser
    }


loginUserRequestCodec =
    Codec.object LoginUserRequest
        |> Codec.field "user" .user loginUserCodec
        |> Codec.buildObject


type alias LoginUser =
    { email : String
    , password : String
    }


loginUserCodec =
    Codec.object LoginUser
        |> Codec.field "email" .email Codec.string
        |> Codec.field "password" .password Codec.string
        |> Codec.buildObject


type alias UpdateUser =
    { email : Maybe String
    , token : Maybe String
    , username : Maybe String
    , bio : Maybe String
    , image : Maybe String
    }


updateUserCodec =
    Codec.object UpdateUser
        |> Codec.optionalField "email" .email Codec.string
        |> Codec.optionalField "token" .token Codec.string
        |> Codec.optionalField "username" .username Codec.string
        |> Codec.optionalField "bio" .bio Codec.string
        |> Codec.optionalField "image" .image Codec.string
        |> Codec.buildObject


type alias UpdateUserRequest =
    { user : UpdateUser }


updateUserRequestCodec =
    Codec.object UpdateUserRequest
        |> Codec.field "user" .user updateUserCodec
        |> Codec.buildObject


type alias MultipleArticlesResponse =
    { articles : List Article
    , articlesCount : Int
    }


multipleArticlesResponseCodec =
    Codec.object MultipleArticlesResponse
        |> Codec.field "articles" .articles (Codec.list articleCodec)
        |> Codec.field "articlesCount" .articlesCount Codec.int
        |> Codec.buildObject


type alias Article =
    { slug : String
    , title : String
    , description : String
    , body : String
    , tagList : List String
    , createdAt : String
    , updatedAt : String
    , favorited : Bool
    , favoritesCount : Int
    , author : Profile
    }


articleCodec =
    Codec.object Article
        |> Codec.field "slug" .slug Codec.string
        |> Codec.field "title" .title Codec.string
        |> Codec.field "description" .description Codec.string
        |> Codec.field "body" .body Codec.string
        |> Codec.field "tagList" .tagList (Codec.list Codec.string)
        |> Codec.field "createdAt" .createdAt Codec.string
        |> Codec.field "updatedAt" .updatedAt Codec.string
        |> Codec.field "favorited" .favorited Codec.bool
        |> Codec.field "favoritesCount" .favoritesCount Codec.int
        |> Codec.field "author" .author profileCodec
        |> Codec.buildObject


type alias Profile =
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }


profileCodec =
    Codec.object Profile
        |> Codec.field "username" .username Codec.string
        |> Codec.field "bio" .bio Codec.string
        |> Codec.field "image" .image Codec.string
        |> Codec.field "following" .following Codec.bool
        |> Codec.buildObject


type alias ProfileResponse =
    { profile : Profile }


profileResponseCodec =
    Codec.object ProfileResponse
        |> Codec.field "profile" .profile profileCodec
        |> Codec.buildObject


type alias NewArticleRequest =
    { article : NewArticle }


newArticleRequestCodec =
    Codec.object NewArticleRequest
        |> Codec.field "article" .article newArticleCodec
        |> Codec.buildObject


type alias NewArticle =
    { title : String
    , description : String
    , body : String
    , tagList : List String
    }


newArticleCodec =
    Codec.object NewArticle
        |> Codec.field "title" .title Codec.string
        |> Codec.field "description" .description Codec.string
        |> Codec.field "body" .body Codec.string
        |> Codec.field "tagList" .tagList (Codec.list Codec.string)
        |> Codec.buildObject


type alias UpdateArticleRequest =
    { article : UpdateArticle }


updateArticleRequestCodec =
    Codec.object UpdateArticleRequest
        |> Codec.field "article" .article updateArticleCodec
        |> Codec.buildObject


type alias UpdateArticle =
    { title : Maybe String
    , description : Maybe String
    , body : Maybe String
    }


updateArticleCodec =
    Codec.object UpdateArticle
        |> Codec.optionalField "title" .title Codec.string
        |> Codec.optionalField "description" .description Codec.string
        |> Codec.optionalField "body" .body Codec.string
        |> Codec.buildObject


type alias SingleArticleResponse =
    { article : Article }


singleArticleResponseCodec =
    Codec.object SingleArticleResponse
        |> Codec.field "article" .article articleCodec
        |> Codec.buildObject


type alias Comment =
    { id : String
    , createdAt : String
    , updatedAt : String
    , body : String
    , author : Profile
    }


commentCodec =
    Codec.object Comment
        |> Codec.field "id" .id Codec.string
        |> Codec.field "createdAt" .createdAt Codec.string
        |> Codec.field "updatedAt" .updatedAt Codec.string
        |> Codec.field "body" .body Codec.string
        |> Codec.field "author" .author profileCodec
        |> Codec.buildObject


type alias MultipleCommentsResponse =
    { comments : List Comment }


multipleCommentsResponseCodec =
    Codec.object MultipleCommentsResponse
        |> Codec.field "comments" .comments (Codec.list commentCodec)
        |> Codec.buildObject


type alias SingleCommentResponse =
    { comment : Comment }


singleCommentResponseCodec =
    Codec.object SingleCommentResponse
        |> Codec.field "comment" .comment commentCodec
        |> Codec.buildObject


type alias NewCommentRequest =
    { comment : NewComment }


newCommentRequestCodec =
    Codec.object NewCommentRequest
        |> Codec.field "comment" .comment newCommentCodec
        |> Codec.buildObject


type alias NewComment =
    { body : String }


newCommentCodec =
    Codec.object NewComment
        |> Codec.field "body" .body Codec.string
        |> Codec.buildObject


type alias TagsResponse =
    { tags : List String }


tagsResponseCodec =
    Codec.object TagsResponse
        |> Codec.field "tags" .tags (Codec.list Codec.string)
        |> Codec.buildObject
