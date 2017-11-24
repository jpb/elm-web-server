module Server.Http.Response.Status exposing (Status, badRequest, internalError, notFound, ok, unauthorized)


type alias Status =
    { code : Int
    , message : String
    }


ok : Status
ok =
    Status 200 "ok"


badRequest : Status
badRequest =
    Status 400 "bad request"


unauthorized : Status
unauthorized =
    Status 401 "unauthorized"


notFound : Status
notFound =
    Status 404 "not found"


internalError : Status
internalError =
    Status 500 "internal server error"
