module String019 exposing (replace, fromInt, fromFloat)

{-| Elm 0.19 added several new functions.

@docs replace, fromInt, fromFloat

-}

import String exposing (split, join)


{-| Replace all occurrences of some substring.

    replace "." "-" "Json.Decode.succeed" --> "Json-Decode-succeed"

    replace "," "/" "a,b,c,d,e"           --> "a/b/c/d/e"

**Note:** If you need more advanced replacements, check out the
[`elm/parser`][parser] or [`elm/regex`][regex] package.

[parser]: /packages/elm/parser/latest
[regex]: /packages/elm/regex/latest

-}
replace : String -> String -> String -> String
replace before after string =
    join after (split before string)


{-| Convert an `Int` to a `String`.

    fromInt 123 --> "123"

    fromInt -42 --> "-42"

Check out [`Debug.toString`](Debug#toString) to convert *any* value to a string
for debugging purposes.

-}
fromInt : Int -> String
fromInt =
    toString


{-| Convert a `Float` to a `String`.

    fromFloat 123 --> "123"

    fromFloat -42 --> "-42"

fromFloat 3.9 --> "3.9"

Check out [`Debug.toString`](Debug#toString) to convert *any* value to a string
for debugging purposes.

-}
fromFloat : Float -> String
fromFloat =
    toString
