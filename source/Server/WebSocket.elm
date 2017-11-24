port module Server.WebSocket exposing (Event(..), Id, compareId, listen, send)

import Json.Decode as D exposing (Decoder)
import Json.Encode as E


port incomingEvent : (D.Value -> msg) -> Sub msg


port outgoingEvent : E.Value -> Cmd msg


compareId : Id -> Id -> Bool
compareId (Id a) (Id b) =
    a == b


type Id
    = Id String


type Event
    = Message Id String
    | Connection Id
    | Disconnection Id


eventDecoder : Decoder Event
eventDecoder =
    D.oneOf
        [ D.map2
            Message
            (D.field "from" (D.map Id D.string))
            (D.field "message" D.string)
        , D.map
            Connection
            (D.field "connected" (D.map Id D.string))
        , D.map
            Disconnection
            (D.field "disconnected" (D.map Id D.string))
        ]


encodeMessage : String -> Id -> E.Value
encodeMessage message (Id id) =
    E.object
        [ ( "to", E.string id )
        , ( "message", E.string message )
        ]


listen : (Result String Event -> msg) -> Sub msg
listen msg =
    incomingEvent (msg << D.decodeValue eventDecoder)


send : String -> Id -> Cmd msg
send message id =
    (outgoingEvent << encodeMessage message) id
