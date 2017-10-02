module Server.Main exposing (main)

import Platform
import Server.Html as Html
import Server.Request as Request exposing (Request, Method(..))
import Server.Response as Response exposing (Response)
import Server.Response.Status as Status
import Shared


type alias Flags =
    { client :
        { script : String
        }
    }


type alias Model =
    { client : Html.Document
    }


type Msg
    = BadRequest
    | GetClient String
    | SomeData String
    | OtherData String
    | NotFound String String


init : Flags -> ( Model, Cmd Msg )
init { client } =
    ( { client = Html.document Shared.text client.script }
    , Cmd.none
    )


update : Msg -> Model -> Cmd Msg
update msg model =
    case msg of
        BadRequest ->
            Cmd.none

        NotFound id url ->
            Response.send (Response.text id Status.notFound ("no route found for '" ++ url ++ "'"))

        GetClient id ->
            Response.send (Response.html id Status.ok model.client)

        SomeData id ->
            Response.send (Response.text id Status.ok "some data")

        OtherData id ->
            Response.send (Response.text id Status.ok "other data")


subscriptions : Model -> Sub Msg
subscriptions model =
    Request.listen
        (\result ->
            case result of
                Ok request ->
                    case request.url of
                        "/" ->
                            GetClient request.id

                        "/some" ->
                            SomeData request.id

                        "/other" ->
                            OtherData request.id

                        _ ->
                            NotFound request.id request.url

                Err reason ->
                    BadRequest
        )


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = \msg model -> ( model, update msg model )
        , subscriptions = subscriptions
        }
