module Client.Main exposing (main)

import Html exposing (Html)
import Shared
import Http


type alias Model =
    String


type Msg
    = Data (Result Http.Error String)


someDataRequest : Http.Request String
someDataRequest =
    Http.getString "/some"


otherDataRequest : Http.Request String
otherDataRequest =
    Http.getString "/other"


init : ( Model, Cmd Msg )
init =
    ( "loading"
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
                    ( data, Cmd.none )

                Err error ->
                    ( toString error, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.div [] [ Html.text Shared.text ]
        , Html.div [] [ Html.text model ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
