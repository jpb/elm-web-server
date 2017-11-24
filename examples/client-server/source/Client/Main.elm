module Client.Main exposing (main)

import Html exposing (Html)
import Http
import Shared
import WebSocket


type alias Model =
    { data : String
    , messages : List String
    }


type Msg
    = Data (Result Http.Error String)
    | NewMessage String


someDataRequest : Http.Request String
someDataRequest =
    Http.getString "/some"


otherDataRequest : Http.Request String
otherDataRequest =
    Http.getString "/other"


init : ( Model, Cmd Msg )
init =
    ( { data = "loading"
      , messages = []
      }
    , Cmd.batch
        [ Http.send Data someDataRequest
        , Http.send Data otherDataRequest
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Data result ->
            case result of
                Ok data ->
                    ( { model | data = data }, Cmd.none )

                Err error ->
                    ( { model | data = toString error }, Cmd.none )

        NewMessage message ->
            ( { model | messages = message :: model.messages }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:3000" NewMessage


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div [] [ Html.text Shared.text ]
        , Html.div [] [ Html.text model.data ]
        , Html.div [] (List.map (\data -> Html.div [] [ Html.text data ]) model.messages)
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
