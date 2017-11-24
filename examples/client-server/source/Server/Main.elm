module Server.Main exposing (main)

import Platform
import Server.Html as Html
import Server.Http.Request as Request exposing (Method(..), Request)
import Server.Http.Response as Response exposing (Response)
import Server.Http.Response.Status as Status
import Server.WebSocket as WebSocket exposing (Event(..))
import Shared
import Time


type alias Flags =
    { client :
        { script : String
        }
    }


type alias Model =
    { client : Html.Document
    , connections : List WebSocket.Id
    }


type Msg
    = NoOp
    | GetClient Request.Id
    | SomeData Request.Id
    | OtherData Request.Id
    | NotFound Request.Id String
    | GotConnection WebSocket.Id
    | LostConnection WebSocket.Id
    | SendMessage


init : Flags -> ( Model, Cmd Msg )
init { client } =
    ( { client = Html.document Shared.text client.script
      , connections = []
      }
    , Cmd.none
    )


routeEvent : Result String Event -> Msg
routeEvent result =
    case result of
        Ok event ->
            case event of
                Connection id ->
                    GotConnection id

                Disconnection id ->
                    LostConnection id

                Message id message ->
                    NoOp

        Err reason ->
            NoOp


routeRequest : Result String Request -> Msg
routeRequest result =
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
            NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NotFound id url ->
            ( model, Response.send (Response.text id Status.notFound ("no route found for '" ++ url ++ "'")) )

        GetClient id ->
            ( model, Response.send (Response.html id Status.ok model.client) )

        SomeData id ->
            ( model, Response.send (Response.text id Status.ok "some data") )

        OtherData id ->
            ( model, Response.send (Response.text id Status.ok "other data") )

        GotConnection id ->
            ( { model | connections = id :: model.connections }, Cmd.none )

        LostConnection id ->
            ( { model | connections = List.filter (not << WebSocket.compareId id) model.connections }, Cmd.none )

        SendMessage ->
            ( model, Cmd.batch (List.map (WebSocket.send "some data") model.connections) )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Request.listen routeRequest
        , WebSocket.listen routeEvent
        , Time.every 1000 (\_ -> SendMessage)
        ]


main : Program Flags Model Msg
main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
