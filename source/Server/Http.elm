port module Server.Http exposing (Request, Response, ResponseStatus, listen, respond)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Tuple


port incoming : (Decode.Value -> msg) -> Sub msg


port outgoing : Encode.Value -> Cmd msg


type alias Request a =
    { method : String
    , headers : Dict String String
    , url : String
    , body : Maybe a
    }


type alias ResponseStatus =
    { code : Int
    , message : String
    }


type alias Response =
    { status : ResponseStatus
    , headers : Dict String String
    , body : Maybe String
    }


headersDecoder : Decoder (Dict String String)
headersDecoder =
    Decode.map Dict.fromList (Decode.keyValuePairs Decode.string)


requestDecoder : Decoder a -> Decoder (Request a)
requestDecoder bodyDecoder =
    Decode.map4
        Request
        (Decode.field "method" Decode.string)
        (Decode.field "headers" headersDecoder)
        (Decode.field "url" Decode.string)
        (Decode.field "body" (Decode.maybe bodyDecoder))


encodeHeaders : Dict String String -> Encode.Value
encodeHeaders =
    Encode.object << (List.map << Tuple.mapSecond) Encode.string << Dict.toList


encodeResponse : Response -> Encode.Value
encodeResponse { status, headers, body } =
    Encode.object
        [ ( "status"
          , Encode.object
                [ ( "code", Encode.int status.code )
                , ( "message", Encode.string status.message )
                ]
          )
        , ( "headers", encodeHeaders headers )
        , ( "body", (Maybe.withDefault Encode.null << Maybe.map Encode.string) body )
        ]


respond : Response -> Cmd msg
respond response =
    (outgoing << encodeResponse) response


listen : (Result String (Request Decode.Value) -> msg) -> Sub msg
listen msg =
    incoming (msg << Decode.decodeValue (requestDecoder Decode.value))
