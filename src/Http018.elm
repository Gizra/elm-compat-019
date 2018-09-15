module Http018 exposing (decodeUri, encodeUri)

{-| Elm 0.19 moved `encodeUri` and `decodeUri` to the `elm/url` package,
and renamed them `percentEncode` and `percentDecode`.

@docs encodeUri, decodeUri

-}

import Url exposing (percentDecode, percentEncode)


{-| Use this to escape query parameters. Converts characters like `/` to `%2F`
so that it does not clash with normal URL

It work just like `encodeURIComponent` in JavaScript.

    encodeUri "hat" --> "hat"

    encodeUri "to be" --> "to%20be"

    encodeUri "99%" --> "99%25"

-}
encodeUri : String -> String
encodeUri =
    percentEncode


{-| Use this to unescape query parameters. It converts things like `%2F` to
`/`. It can fail in some cases. For example, there is no way to unescape `%`
because it could never appear alone in a properly escaped string.

It works just like `decodeURIComponent` in JavaScript.

    -- ASCII
    decodeUri "hat"     --> Just "hat"

    decodeUri "to%20be"   --> Just "to be"

    decodeUri "99%25"       --> Just "99%"

    -- UTF-8
    decodeUri "%24"       --> Just "$"

    decodeUri "%C2%A2"    --> Just "¢"

    decodeUri "%E2%82%AC" --> Just "€"

    -- Failing
    decodeUri "%"   --> Nothing  -- not followed by two hex digits

    decodeUri "%XY" --> Nothing  -- not followed by two HEX digits

    decodeUri "%C2" --> Nothing  -- half of the "¢" encoding "%C2%A2"

-}
decodeUri : String -> Maybe String
decodeUri =
    percentDecode
