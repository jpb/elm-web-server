module Main exposing (main)

import Platform
import Server.Http as Http exposing (Request, Response)
import Server.Id as Id exposing (Id)
import Server.WebSocket as WebSocket


type Msg
    = NoOp
    | NewRequest Id
    | NewMessage Id


init =
    ( (), Cmd.none )


helloResponse id =
    Http.textResponse Http.okStatus "Hello World" id


update msg _ =
    case msg of
        NewRequest id ->
            ( (), Http.send (helloResponse id) )

        NewMessage id ->
            ( ()
            , WebSocket.send "Hello World" id
            )

        NoOp ->
            ( (), Cmd.none )


subscriptions _ =
    Sub.batch
        [ Http.listen
            (\incoming ->
                case incoming of
                    Ok request ->
                        NewRequest request.id

                    _ ->
                        NoOp
            )
        , WebSocket.listen
            (\incoming ->
                case incoming of
                    Ok (WebSocket.Message id message) ->
                        Debug.log (toString message) (NewMessage id)

                    event ->
                        Debug.log (toString event) NoOp
            )
        ]


main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
