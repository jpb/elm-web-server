module Main exposing (main)

import Platform
import Server.Http as Http exposing (Request, Response)
import Server.WebSocket as WebSocket


type Msg
    = NoOp
    | NewRequest Http.Id
    | NewMessage WebSocket.Id


init =
    ( (), Cmd.none )


update msg _ =
    case msg of
        NewRequest id ->
            ( (), Http.send (Http.textResponse Http.okStatus "Hello World" id) )

        NewMessage id ->
            ( ()
            , WebSocket.send "Hello World" id
            )

        NoOp ->
            ( (), Cmd.none )


routeRequest incoming =
    case incoming of
        Ok request ->
            NewRequest request.id

        _ ->
            NoOp


routeMessage incoming =
    case incoming of
        Ok (WebSocket.Message id message) ->
            NewMessage id

        event ->
            NoOp


subscriptions _ =
    Sub.batch
        [ Http.listen routeRequest
        , WebSocket.listen (Debug.log "Message Received" >> routeMessage)
        ]


main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
