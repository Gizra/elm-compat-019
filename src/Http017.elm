module Http017 exposing
    ( url, uriEncode, uriDecode
    , getString, get, post, Error(..)
    , Body, empty, string, multipart, Data, stringData
    , send, Request, Settings, defaultSettings
    , Response, Value(..), fromJson, RawError(..)
    )

{-| Elm 0.18 made significant changes to the `Http` API. This module
re-implements the entire Elm 0.17 API.

Note that we could not avoid adding an extra parameter to the `string`
function. We also could not avoid adding a new constructor to `RawError`
and `Error`.


# Encoding and Decoding

@docs url, uriEncode, uriDecode


# Fetch Strings and JSON

@docs getString, get, post, Error


# Body Values

@docs Body, empty, string, multipart, Data, stringData


# Arbitrary Requests

@docs send, Request, Settings, defaultSettings


# Responses

@docs Response, Value, fromJson, RawError

-}

import Basics018 exposing (uncurry)
import Dict exposing (Dict)
import Http exposing (Body, Part, emptyBody, expectStringResponse, header, multipartBody, request, stringBody, stringPart, toTask)
import Json.Decode exposing (Decoder)
import Json.Decode018 exposing (decodeString)
import Task exposing (Task, mapError)
import Time018 exposing (Time)
import Url exposing (percentDecode, percentEncode)


{-| Create a properly encoded URL with a [query string][qs]. The first argument is
the portion of the URL before the query string, which is assumed to be
properly encoded already. The second argument is a list of all the
key/value pairs needed for the query string. Both the keys and values
will be appropriately encoded, so they can contain spaces, ampersands, etc.

[qs]: http://en.wikipedia.org/wiki/Query_string

    url "http://example.com/users" [ ("name", "john doe"), ("age", "30") ]
        --> "http://example.com/users?name=john+doe&age=30"

-}
url : String -> List ( String, String ) -> String
url baseUrl args =
    -- You could almost do this with Elm 0.19's Url.Builder, but it always adds
    -- a slash at the end of the `baseUrl`, so it's better to reproduce the
    -- original code from Elm 0.17.
    case args of
        [] ->
            baseUrl

        _ ->
            baseUrl ++ "?" ++ String.join "&" (List.map queryPair args)


queryPair : ( String, String ) -> String
queryPair ( key, value ) =
    queryEscape key ++ "=" ++ queryEscape value


queryEscape : String -> String
queryEscape input =
    String.join "+" (String.split "%20" (uriEncode input))


{-| Encode a string to be placed in any part of a URI. Same behavior as
JavaScript's `encodeURIComponent` function.

    uriEncode "hat" --> "hat"

    uriEncode "to be" --> "to%20be"

    uriEncode "99%" --> "99%25"

-}
uriEncode : String -> String
uriEncode =
    percentEncode


{-| Decode a URI string. Same behavior as JavaScript's `decodeURIComponent`
function.

    -- ASCII
    uriDecode "hat" --> "hat"

    uriDecode "to%20be" --> "to be"

    uriDecode "99%25" --> "99%"


    -- UTF-8
    uriDecode "%24" --> "$"

    uriDecode "%C2%A2" --> "¢"

    uriDecode "%E2%82%AC" --> "€"


    -- Failing
    uriDecode "%" --> "%"  -- not followed by two hex digits

    uriDecode "%XY" --> "%XY"  -- not followed by two HEX digits

    uriDecode "%C2" --> "%C2"  -- half of the "¢" encoding "%C2%A2"

> In later verions of Elm, the signature of the equivalent functions is
> `String -> Maybe String` to account for the fact that the input may be
> invalidly encoded. We can't do exactly that here, so if the input is
> invalid, we return it unchanged.

-}
uriDecode : String -> String
uriDecode input =
    percentDecode input
        |> Maybe.withDefault input


{-| Fully specify the request you want to send. For example, if you want to
send a request between domains (CORS request) you will need to specify some
headers manually.

    corsPost : Request
    corsPost =
        { verb = "POST"
        , headers =
            [ ( "Origin", "http://elm-lang.org" )
            , ( "Access-Control-Request-Method", "POST" )
            , ( "Access-Control-Request-Headers", "X-Custom-Header" )
            ]
        , url = "http://example.com/hats"
        , body = empty
        }

> In later versions of Elm, this becomes an opaque type.

-}
type alias Request =
    { verb : String
    , headers : List ( String, String )
    , url : String
    , body : Body
    }


{-| An opaque type representing the body of your HTTP message. With GET
requests this is empty, but in other cases it may be a string or blob.
-}
type alias Body =
    Http.Body


{-| An empty request body, no value will be sent along.
-}
empty : Body
empty =
    emptyBody


{-| Provide a string as the body of the request.

Notice that the first argument is a [MIME type][mime] so we know to add
`Content-Type: application/json` to our request headers. Make sure your
MIME type matches your data. Some servers are strict about this!

[mime]: https://en.wikipedia.org/wiki/Media_type

> Im Elm 0.17, the first parameter was missing, and it seems that Elm
> did not send a `Content-type` header at all. In later versions of Elm,
> there is no way of avoiding sending a `Content-type` header, so we have
> to supply the content type here. Thus, you will need to modify your code
> to specify the desired content type.

-}
string : String -> String -> Body
string =
    stringBody


{-| Represents data that can be put in a multi-part body. Right now it only
supports strings, but we will support blobs and files when we get an API for
them in Elm.
-}
type alias Data =
    Part


{-| Create multi-part request bodies, allowing you to send many chunks of data
all in one request. All chunks of data must be given a name.

Currently, you can only construct `stringData`, but we will support `blobData`
and `fileData` once we have proper APIs for those types of data in Elm.

-}
multipart : List Data -> Body
multipart =
    multipartBody


{-| A named chunk of string data.

    import Json.Encode as JS

    body =
        multipart
            [ stringData "user" (JS.encode user)
            , stringData "payload" (JS.encode payload)
            ]

-}
stringData : String -> String -> Data
stringData =
    stringPart


{-| Configure your request if you need specific behavior.

  - `timeout` lets you specify how long you are willing to wait for a response
    before giving up. By default it is 0 which means &ldquo;never give
    up!&rdquo;

  - `onStart` and `onProgress` allow you to monitor progress. This is useful
    if you want to show a progress bar when uploading a large amount of data.

  - `desiredResponseType` lets you override the MIME type of the response, so
    you can influence what kind of `Value` you get in the `Response`.

-}
type alias Settings =
    { timeout : Time
    , onStart : Maybe (Task () ())
    , onProgress : Maybe (Maybe { loaded : Int, total : Int } -> Task () ())
    , desiredResponseType : Maybe String
    , withCredentials : Bool
    }


{-| The default settings used by `get` and `post`.

    { timeout = 0
    , onStart = Nothing
    , onProgress = Nothing
    , desiredResponseType = Nothing
    , withCredentials = False
    }

-}
defaultSettings : Settings
defaultSettings =
    { timeout = 0
    , onStart = Nothing
    , onProgress = Nothing
    , desiredResponseType = Nothing
    , withCredentials = False
    }


{-| All the details of the response. There are many weird facts about
responses which include:

  - The `status` may be 0 in the case that you load something from `file://`
  - You cannot handle redirects yourself, they will all be followed
    automatically. If you want to know if you have gone through one or more
    redirect, the `url` field will let you know who sent you the response, so
    you will know if it does not match the URL you requested.
  - You are allowed to have duplicate headers, and their values will be
    combined into a single comma-separated string.

We have left these underlying facts about `XMLHttpRequest` as is because one
goal of this library is to give a low-level enough API that others can build
whatever helpful behavior they want on top of it.

-}
type alias Response =
    { status : Int
    , statusText : String
    , headers : Dict String String
    , url : String
    , value : Value
    }


{-| The information given in the response. Currently there is no way to handle
`Blob` types since we do not have an Elm API for that yet. This type will
expand as more values become available in Elm itself.
-}
type Value
    = Text String
    | Blob Blob


{-| This wasn't exported in Elm 0.17, even though the `Value` constructors were.
-}
type Blob
    = TODO_implement_blob_in_another_library


{-| The things that count as errors at the lowest level. Technically, getting
a response back with status 404 is a &ldquo;successful&rdquo; response in that
you actually got all the information you asked for.

The `fromJson` function and `Error` type provide higher-level errors, but the
point of `RawError` is to allow you to define higher-level errors however you
want.

> We needed to add a new constructor `RawBadUrl` to cover an error state
> added in Elm 0.18.

-}
type RawError
    = RawTimeout
    | RawNetworkError
    | RawBadUrl String


{-| The kinds of errors you typically want in practice. When you get a
response but its status is not in the 200 range, it will trigger a
`BadResponse`. When you try to decode JSON but something goes wrong,
you will get an `UnexpectedPayload`.

> A new `BadUrl` constructor has been added which was not in Elm 0.17.

-}
type Error
    = Timeout
    | NetworkError
    | UnexpectedPayload String
    | BadResponse Int String
    | BadUrl String


{-| Send a request exactly how you want it. The `Settings` argument lets you
configure things like timeouts and progress monitoring. The `Request` argument
defines all the information that will actually be sent along to a server.

    crossOriginGet : String -> String -> Task RawError Response
    crossOriginGet origin url =
        send defaultSettings
            { verb = "GET"
            , headers = [ ( "Origin", origin ) ]
            , url = url
            , body = empty
            }

-}
send : Settings -> Request -> Task RawError Response
send settings req =
    -- TODO
    --
    -- Ignoring `onStart` and `onProgress` in the settings for now
    --
    -- Not sure what to do with `desiredResponseType` in settings ... need
    -- to figure out Elm 0.19 equivalent.
    let
        timeout =
            if settings.timeout <= 0 then
                Nothing

            else
                Just settings.timeout

        headers =
            List.map (uncurry header) req.headers

        convertResponse response =
            { status = response.status.code
            , statusText = response.status.message
            , headers = response.headers
            , url = response.url
            , value = Text response.body
            }

        handleError error =
            case error of
                Http.BadUrl x ->
                    Task.fail (RawBadUrl x)

                Http.Timeout ->
                    Task.fail RawTimeout

                Http.NetworkError ->
                    Task.fail RawNetworkError

                Http.BadStatus response ->
                    -- In the Elm 0.17 scheme, the `RawError` type didn't
                    -- consider this an error. So, we actually succeed here.
                    Task.succeed (convertResponse response)

                Http.BadPayload _ response ->
                    -- This one is impossible here, because our `Expect` always
                    -- succeeds. However, we can't convince the compiler of
                    -- that, so we have to provide some value.
                    Task.succeed (convertResponse response)
    in
    { method = req.verb
    , headers = headers
    , url = req.url
    , body = req.body
    , timeout = timeout
    , expect = expectStringResponse Ok
    , withCredentials = settings.withCredentials
    }
        |> request
        |> toTask
        |> Task.map convertResponse
        |> Task.onError handleError



-- HIGH-LEVEL REQUESTS


{-| Send a GET request to the given URL. You will get the entire response as a
string.

    hats : Task Error String
    hats =
        getString "http://example.com/hat-categories.markdown"

-}
getString : String -> Task Error String
getString input =
    { verb = "GET"
    , headers = []
    , url = input
    , body = empty
    }
        |> send defaultSettings
        |> Task.mapError promoteError
        |> Task.andThen (handleResponse Task.succeed)


{-| Send a GET request to the given URL. You also specify how to decode the
response.

    hats : Task Error (List String)
    hats =
        get (list string) "http://example.com/hat-categories.json"

-}
get : Decoder value -> String -> Task Error value
get decoder input =
    let
        request =
            { verb = "GET"
            , headers = []
            , url = input
            , body = empty
            }
    in
    fromJson decoder (send defaultSettings request)


{-| Send a POST request to the given URL, carrying the given body. You also
specify how to decode the response with [a JSON decoder][json].

[json]: http://package.elm-lang.org/packages/elm-lang/core/latest/Json-Decode#Decoder

    hats : Task Error (List String)
    hats =
        post (list string) "http://example.com/hat-categories.json" empty

-}
post : Decoder value -> String -> Body -> Task Error value
post decoder input body =
    let
        request =
            { verb = "POST"
            , headers = []
            , url = input
            , body = body
            }
    in
    fromJson decoder (send defaultSettings request)


{-| Turn a `Response` into an Elm value that is easier to deal with. Helpful
if you are making customized HTTP requests with `send`, as is the case with
`get` and `post`.

Given a `Response` this function will:

  - Check that the status code is in the 200 range.
  - Make sure the response `Value` is a string.
  - Convert the string to Elm with the given `Decoder`.

Assuming all these steps succeed, you will get an Elm value as the result!

-}
fromJson : Decoder a -> Task RawError Response -> Task Error a
fromJson decoder response =
    let
        decode str =
            case decodeString decoder str of
                Ok v ->
                    Task.succeed v

                Err msg ->
                    Task.fail (UnexpectedPayload msg)
    in
    mapError promoteError response
        |> Task.andThen (handleResponse decode)


handleResponse : (String -> Task Error a) -> Response -> Task Error a
handleResponse handle response =
    if 200 <= response.status && response.status < 300 then
        case response.value of
            Text str ->
                handle str

            Blob _ ->
                Task.fail (UnexpectedPayload "Response body is a blob, expecting a string.")

    else
        Task.fail (BadResponse response.status response.statusText)


promoteError : RawError -> Error
promoteError rawError =
    case rawError of
        RawBadUrl x ->
            BadUrl x

        RawTimeout ->
            Timeout

        RawNetworkError ->
            NetworkError
