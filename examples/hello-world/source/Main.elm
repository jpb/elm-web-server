module Main exposing (main)

import Platform
import Server.Request as Request exposing (Request)
import Server.Response as Response exposing (Response)
import Server.Response.Status as Status


type Msg
    = BadRequest
    | GoodRequest String


init =
    ( (), Cmd.none )


helloResponse id =
    Response.text id Status.ok "Hello World"


update msg _ =
    case msg of
        GoodRequest id ->
            ( (), Response.send (helloResponse id) )

        BadRequest ->
            ( (), Cmd.none )


subscriptions _ =
    Request.listen
        (\incoming ->
            case incoming of
                Ok request ->
                    GoodRequest request.id

                _ ->
                    BadRequest
        )


main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
