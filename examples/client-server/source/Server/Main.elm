module Server.Main exposing (main)

import Json.Decode as Decode
import Platform
import Server.Request as Request exposing (Request)
import Server.Response as Response exposing (Response)
import Server.Response.Header as Header
import Server.Response.Status as Status
import Shared


type alias Flags =
    { client :
        { script : String
        }
    }


type alias Model =
    { client : String
    }


type Msg
    = NewRequest (Request Decode.Value)
    | BadRequest String


toDocument : String -> String -> String
toDocument title script =
    """
        <!doctype html>
            <html lang="en">
                <head>
                    <meta charset="utf-8">
                    <title>""" ++ title ++ """</title>
                </head>
                <body>
                    <script>""" ++ script ++ """</script>
                </body>
            </html>
    """


init : Flags -> ( Model, Cmd Msg )
init { client } =
    ( { client = toDocument Shared.text client.script }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewRequest request ->
            ( model
            , Response.send (Response.from Status.ok [ Header.htmlContent ] (Just model.client))
            )

        BadRequest reason ->
            ( model
            , Response.send (Response.from Status.badRequest [ Header.textContent ] (Just reason))
            )


onRequest : Result String (Request Decode.Value) -> Msg
onRequest result =
    case result of
        Ok request ->
            NewRequest request

        Err reason ->
            BadRequest reason


subscriptions : Model -> Sub Msg
subscriptions model =
    Request.listen onRequest


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
