module Main exposing (main)

import Platform
import Server.Request as Request exposing (Request)
import Server.Response as Response exposing (Response)
import Server.Response.Header as Header
import Server.Response.Status as Status


type Msg a
    = ValidRequest (Request a)
    | InvalidRequest String


init =
    (,) 0 Cmd.none


countResponse : Int -> Response
countResponse count =
    Response.from
        Status.ok
        [ Header.htmlContent ]
        (Just ("<pre>" ++ toString count ++ " requests before you :)</pre>"))


errorResponse : String -> Response
errorResponse message =
    Response.from
        Status.badRequest
        [ Header.htmlContent ]
        (Just ("<pre>" ++ message ++ "</pre>"))


update msg model =
    case msg of
        ValidRequest request ->
            ( model + 1, (Response.send << countResponse) model )

        InvalidRequest message ->
            ( model, (Response.send << errorResponse) message )


onRequest result =
    case result of
        Ok request ->
            ValidRequest request

        Err message ->
            InvalidRequest message


subscriptions model =
    Request.listen onRequest


main =
    Platform.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
