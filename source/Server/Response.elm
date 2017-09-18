port module Server.Response exposing (Response, from, send)

import Dict exposing (Dict)
import Json.Encode as E
import Server.Response.Header exposing (Header)
import Server.Response.Status exposing (Status)


port outgoing : E.Value -> Cmd msg


type alias Response =
    { status : Status
    , headers : Dict String String
    , body : Maybe String
    }


from : Status -> List Header -> Maybe String -> Response
from status headers body =
    Response status (Dict.fromList headers) body


encode : Response -> E.Value
encode { status, headers, body } =
    E.object
        [ ( "status"
          , E.object
                [ ( "code", E.int status.code )
                , ( "message", E.string status.message )
                ]
          )
        , ( "headers", (E.object << (List.map << Tuple.mapSecond) E.string << Dict.toList) headers )
        , ( "body", (Maybe.withDefault E.null << Maybe.map E.string) body )
        ]


send : Response -> Cmd msg
send response =
    (outgoing << encode) response
