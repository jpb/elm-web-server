port module Server.Request exposing (Method, Request, listen)

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)


port incoming : (D.Value -> msg) -> Sub msg


type Method
    = Get
    | Put
    | Post
    | Delete
    | Other String


toMethod : String -> Method
toMethod text =
    case String.toLower text of
        "get" ->
            Get

        "put" ->
            Put

        "post" ->
            Post

        "delete" ->
            Delete

        _ ->
            Other text


type alias Request route =
    { method : Method
    , headers : Dict String String
    , route : route
    , body : Maybe String
    }


decoder : (String -> route) -> Decoder (Request route)
decoder toRoute =
    D.map4
        Request
        (D.field "method" (D.map toMethod D.string))
        (D.field "headers" (D.map Dict.fromList (D.keyValuePairs D.string)))
        (D.field "url" (D.map toRoute D.string))
        (D.field "body" (D.maybe D.string))


listen : (String -> route) -> (Result String (Request route) -> msg) -> Sub msg
listen toRoute msg =
    incoming (msg << D.decodeValue (decoder toRoute))
