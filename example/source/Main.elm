module Main exposing (main)

import Dict exposing (Dict)
import Json.Decode as Decode
import Platform
import Server.Http exposing (Request)


type Msg
    = NewRequest (Request Decode.Value)
    | FailedRequest String


init =
    (,) () Cmd.none


update msg model =
    case msg of
        NewRequest request ->
            ( model
            , Server.Http.respond
                { body = Just "<h1>Served by yours truely @elm-http-server</h1>"
                , headers = Dict.fromList [ ( "content-type", "text/html" ) ]
                , status = { code = 200, message = "ok" }
                }
            )

        FailedRequest message ->
            ( model
            , Server.Http.respond
                { body = Nothing
                , headers = Dict.empty
                , status = { code = 500, message = message }
                }
            )


onRequest result =
    case result of
        Ok request ->
            NewRequest request

        Err message ->
            FailedRequest message


subscriptions model =
    Server.Http.listen onRequest


main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
