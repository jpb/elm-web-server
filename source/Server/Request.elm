port module Server.Request exposing (Request, listen)

import Dict exposing (Dict)
import Json.Decode as D exposing (Decoder)


port incoming : (D.Value -> msg) -> Sub msg


type alias Request =
    { method : String
    , headers : Dict String String
    , url : String
    , body : Maybe String
    }


decoder : Decoder Request
decoder =
    D.map4
        Request
        (D.field "method" D.string)
        (D.field "headers" (D.map Dict.fromList (D.keyValuePairs D.string)))
        (D.field "url" D.string)
        (D.field "body" (D.maybe D.string))


listen : (Result String Request -> msg) -> Sub msg
listen msg =
    incoming (msg << D.decodeValue decoder)
