port module Server.Request exposing (Request, listen)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)


port incoming : (Decode.Value -> msg) -> Sub msg


type alias Request a =
    { method : String
    , headers : Dict String String
    , url : String
    , body : Maybe a
    }


decoder : Decoder a -> Decoder (Request a)
decoder bodyDecoder =
    Decode.map4
        Request
        (Decode.field "method" Decode.string)
        (Decode.field "headers" (Decode.map Dict.fromList (Decode.keyValuePairs Decode.string)))
        (Decode.field "url" Decode.string)
        (Decode.field "body" (Decode.maybe bodyDecoder))


listen : (Result String (Request Decode.Value) -> msg) -> Sub msg
listen msg =
    incoming (msg << Decode.decodeValue (decoder Decode.value))
