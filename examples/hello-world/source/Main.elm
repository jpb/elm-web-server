module Main exposing (main)

import Platform
import Server.Http.Request as Request exposing (Request)
import Server.Http.Response as Response exposing (Response)
import Server.Http.Response.Status as Status
import Server.WebSocket as WebSocket


type Msg
    = NoOp
    | NewRequest Request.Id
    | NewEvent WebSocket.Id


init =
    ( (), Cmd.none )


helloResponse id =
    Response.text id Status.ok "Hello World"


update msg _ =
    case msg of
        NewRequest id ->
            ( (), Response.send (helloResponse id) )

        NewEvent id ->
            ( ()
            , WebSocket.send "Hello World" id
            )

        NoOp ->
            ( (), Cmd.none )


subscriptions _ =
    Sub.batch
        [ Request.listen
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
                        Debug.log (toString message) (NewEvent id)

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
