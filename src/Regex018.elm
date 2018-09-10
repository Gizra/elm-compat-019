module Regex018 exposing (HowMany(..), regex, find, replace, split)

{-| Elm 0.19 made several improvements to the API.

  - `regex` was renamed `fromString`, and can no longer crash
  - `find`, `replace` and `split` were simplified, with the addition of
    variations for `findAtMost`, `replaceAtMost` and `splitAtMost`
  - the `HowMany` type was removed, in favour of the separate `...AtMost`
    functions

Some of the old API cannot be re-implemented for Elm 0.19.

  - `caseInsensitive` used to take a `Regex` as input. That signature cannot be
    implemented now. Instead, you would need to use `fromStringWith` and provide
    the desired options.

@docs HowMany, regex, find, replace, split

-}

import Regex exposing (Match, Regex, fromString)


{-| Create a Regex that matches patterns [as specified in JavaScript](https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions#Writing_a_Regular_Expression_Pattern).

Be careful to escape backslashes properly! For example, `"\w"` is escaping the
letter `w` which is probably not what you want. You probably want `"\\w"`
instead, which escapes the backslash.

> In Elm 0.18, an invalid input string would crash the runtime. It is not
> possible to reproduce this behaviour in Elm 0.19. Thus, if given invalid
> input, we will instead return a `Regex` that never matches anything.

-}
regex : String -> Regex
regex =
    fromString >> Maybe.withDefault Regex.never


{-| `HowMany` is used to specify how many matches you want to make. So
`replace All` would replace every match, but `replace (AtMost 2)` would
replace at most two matches (i.e. zero, one, two, but never three or more).
-}
type HowMany
    = All
    | AtMost Int


applyHowMany : x -> (Int -> x) -> HowMany -> x
applyHowMany all atMost howMany =
    case howMany of
        All ->
            all

        AtMost x ->
            atMost x


{-| Find matches in a string:

    find (AtMost 2) (regex ",") "a,b,c,d,e"
        |> List.map .index
    --> [1,3]

    find (AtMost 2) (regex ",") "a b c d e"
        |> List.map .index
    --> []

    find All
        (regex "[oi]n a (\\w+)")
        "I am on a boat in a lake."
        |> List.map .match
    -->  ["on a boat", "in a lake"]


    find All
        (regex "[oi]n a (\\w+)")
        "I am on a boat in a lake."
        |> List.map .submatches
    --> [ [Just "boat"], [Just "lake"] ]

-}
find : HowMany -> Regex -> String -> List Match
find =
    applyHowMany Regex.find Regex.findAtMost


{-| Replace matches. The function from `Match` to `String` lets
you use the details of a specific match when making replacements.

    replace All
        (regex "[aeiou]")
        (\_ -> "")
        "The quick brown fox"
    -->  "Th qck brwn fx"

    replace (AtMost 2)
        (regex "\\w+")
        (\{ match } -> String.reverse match)
        "deliver mined parts"
    --> "reviled denim parts"

-}
replace : HowMany -> Regex -> (Match -> String) -> String -> String
replace =
    applyHowMany Regex.replace Regex.replaceAtMost


{-| Split a string, using the regex as the separator.

    split (AtMost 1)
        (regex ",")
        "tom,99,90,85"
    --> [ "tom", "99,90,85" ]

    split All
        (regex ",")
        "a,b,c,d"
    --> [ "a", "b", "c", "d" ]

-}
split : HowMany -> Regex -> String -> List String
split =
    applyHowMany Regex.split Regex.splitAtMost
