module Client.Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import WebSocket


type Msg
    = InputMessage String
    | SendMessage
    | ReceiveMessage String


wsUrl =
    "ws://localhost:3000"


init =
    ( { message = ""
      , messages = []
      }
    , Cmd.none
    )


update msg model =
    case msg of
        InputMessage message ->
            ( { model | message = message }, Cmd.none )

        SendMessage ->
            ( { model | message = "", messages = model.message :: model.messages }, WebSocket.send wsUrl model.message )

        ReceiveMessage message ->
            ( { model | messages = message :: model.messages }, Cmd.none )


subscriptions model =
    WebSocket.listen wsUrl ReceiveMessage


viewMessage message =
    Html.li [] [ Html.text message ]


view model =
    Html.div []
        [ Html.input
            [ Attributes.value model.message
            , Events.onInput InputMessage
            ]
            []
        , Html.button
            [ Events.onClick SendMessage
            ]
            [ Html.text "Send" ]
        , Html.ul [] (List.map viewMessage model.messages)
        ]


main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
