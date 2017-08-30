module Main exposing (main)

import Platform
import Server.Request as Request exposing (Request)
import Server.Response as Response exposing (Response)
import Server.Response.Header as Header
import Server.Response.Status as Status


init =
    ( (), Cmd.none )


helloResponse =
    Response.from
        Status.ok
        [ Header.textContent ]
        (Just "Hello World")


update _ _ =
    ( (), Response.send helloResponse )


subscriptions _ =
    Request.listen (always ())


main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
