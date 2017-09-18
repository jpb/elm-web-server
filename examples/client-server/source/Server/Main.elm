module Server.Main exposing (main)

import Platform
import Server.Request as Request exposing (Request)
import Server.Response as Response exposing (Response)
import Server.Response.Status as Status
import Shared
import Server.Html as Html


type alias Flags =
    { client :
        { script : String
        }
    }


type alias Model =
    { client : Html.Document
    }


type Msg
    = NewRequest Request
    | BadRequest String


init : Flags -> ( Model, Cmd Msg )
init { client } =
    ( { client = Html.document Shared.text client.script }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewRequest request ->
            ( model
            , Response.send (Response.html Status.ok model.client)
            )

        BadRequest reason ->
            ( model
            , Response.send (Response.text Status.badRequest reason)
            )


onRequest : Result String Request -> Msg
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
