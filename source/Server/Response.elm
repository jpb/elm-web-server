port module Server.Response exposing (Response, html, json, empty, send, text)

import Dict exposing (Dict)
import Json.Encode as E
import Server.Html as Html
import Server.Response.Header as Header exposing (Header)
import Server.Response.Status as Status exposing (Status)
import Server.Request as Request


port outgoing : E.Value -> Cmd msg


type Response
    = Response
        { id : Request.Id
        , status : Status
        , headers : Dict String String
        , body : Maybe String
        }


html : Request.Id -> Status -> Html.Document -> Response
html id status html =
    Response
        { id = id
        , status = status
        , headers = Dict.fromList [ Header.htmlContent ]
        , body = Just (Html.toString html)
        }


text : Request.Id -> Status -> String -> Response
text id status text =
    Response
        { id = id
        , status = status
        , headers = Dict.fromList [ Header.textContent ]
        , body = Just text
        }


json : Request.Id -> Status -> E.Value -> Response
json id status json =
    Response
        { id = id
        , status = status
        , headers = Dict.fromList [ Header.jsonContent ]
        , body = Just (E.encode 0 json)
        }


empty : Request.Id -> Status -> Response
empty id status =
    Response
        { id = id
        , status = status
        , headers = Dict.empty
        , body = Nothing
        }


encode : Response -> E.Value
encode (Response { id, status, headers, body }) =
    E.object
        [ ( "id", Request.encodeId id )
        , ( "status"
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
