port module Server.Response exposing (Response, from, send)

import Dict exposing (Dict)
import Json.Encode as Encode
import Server.Response.Header exposing (Header)
import Server.Response.Status exposing (Status)


port outgoing : Encode.Value -> Cmd msg


type alias Response =
    { status : Status
    , headers : Dict String String
    , body : Maybe String
    }


from : Status -> List Header -> Maybe String -> Response
from status headers body =
    Response status (Dict.fromList headers) body


encode : Response -> Encode.Value
encode { status, headers, body } =
    Encode.object
        [ ( "status"
          , Encode.object
                [ ( "code", Encode.int status.code )
                , ( "message", Encode.string status.message )
                ]
          )
        , ( "headers", (Encode.object << (List.map << Tuple.mapSecond) Encode.string << Dict.toList) headers )
        , ( "body", (Maybe.withDefault Encode.null << Maybe.map Encode.string) body )
        ]


send : Response -> Cmd msg
send response =
    (outgoing << encode) response
