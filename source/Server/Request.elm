port module Server.Request exposing (Request, listen)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)


port incoming : (Decode.Value -> msg) -> Sub msg


type alias Request =
    { method : String
    , headers : Dict String String
    , url : String
    , body : Maybe String
    }


decoder : Decoder Request
decoder =
    Decode.map4
        Request
        (Decode.field "method" Decode.string)
        (Decode.field "headers" (Decode.map Dict.fromList (Decode.keyValuePairs Decode.string)))
        (Decode.field "url" Decode.string)
        (Decode.field "body" (Decode.maybe Decode.string))


listen : (Result String Request -> msg) -> Sub msg
listen msg =
    incoming (msg << Decode.decodeValue decoder)
