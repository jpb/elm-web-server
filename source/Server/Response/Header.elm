module Server.Response.Header exposing (Header, jsContent, contentType, htmlContent, jsonContent, textContent)


type alias Header =
    ( String, String )


contentType : String -> Header
contentType value =
    (,) "content-type" value


textContent : Header
textContent =
    contentType "text/plain"


htmlContent : Header
htmlContent =
    contentType "text/html"


jsonContent : Header
jsonContent =
    contentType "application/json"


jsContent : Header
jsContent =
    contentType "application/javascript"
