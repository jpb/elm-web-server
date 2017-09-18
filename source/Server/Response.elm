port module Server.Response exposing (Response, json, html, text, nothing, send)

import Dict exposing (Dict)
import Json.Encode as E
import Server.Response.Header as Header exposing (Header)
import Server.Response.Status as Status exposing (Status)
import Server.Html as Html


port outgoing : E.Value -> Cmd msg


type Response
    = Response
        { status : Status
        , headers : Dict String String
        , body : Maybe String
        }


html : Status -> Html.Document -> Response
html status html =
    Response
        { status = status
        , headers = Dict.fromList [ Header.htmlContent ]
        , body = Just (Html.toString html)
        }


text : Status -> String -> Response
text status text =
    Response
        { status = status
        , headers = Dict.fromList [ Header.textContent ]
        , body = Just text
        }


json : Status -> E.Value -> Response
json status json =
    Response
        { status = status
        , headers = Dict.fromList [ Header.jsonContent ]
        , body = Just (E.encode 0 json)
        }


nothing : Status -> Response
nothing status =
    Response
        { status = status
        , headers = Dict.empty
        , body = Nothing
        }


encode : Response -> E.Value
encode (Response { status, headers, body }) =
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
