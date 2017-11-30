module Server.Main exposing (main)

import Platform exposing (Program)
import Server.Html as Html
import Server.Http as Http
import Server.WebSocket as WebSocket


type Msg
    = ClientRequest Http.Id
    | InternalError String
    | WebSocketMsg WebSocket.Msg


init client =
    ( { client = Html.document "Chat" client
      , connections = []
      }
    , Cmd.none
    )


broadCast message sender connections =
    Cmd.batch
        (List.filterMap
            (\connection ->
                if WebSocket.compareId sender connection then
                    Nothing
                else
                    Just (WebSocket.send message connection)
            )
            connections
        )


update msg model =
    case msg of
        InternalError reason ->
            let
                _ =
                    Debug.log "An internal Error Occoured" reason
            in
            ( model, Cmd.none )

        ClientRequest id ->
            ( model, Http.send (Http.htmlResponse Http.okStatus model.client id) )

        WebSocketMsg (WebSocket.Connected id) ->
            ( { model | connections = id :: model.connections }, Cmd.none )

        WebSocketMsg (WebSocket.Disconnected id) ->
            ( { model | connections = List.filter (WebSocket.compareId id >> not) model.connections }, Cmd.none )

        WebSocketMsg (WebSocket.Message id message) ->
            ( model, broadCast message id model.connections )


routeMessage incoming =
    case incoming of
        Err reason ->
            InternalError reason

        Ok msg ->
            WebSocketMsg msg


routeRequest incoming =
    case incoming of
        Err reason ->
            InternalError reason

        Ok { id } ->
            ClientRequest id


subscriptions model =
    Sub.batch
        [ WebSocket.listen routeMessage
        , Http.listen routeRequest
        ]


main =
    Platform.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        }
