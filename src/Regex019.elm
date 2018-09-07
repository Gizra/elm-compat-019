module Regex019 exposing (Options, find, findAtMost, fromString, fromStringWith, never, split, splitAtMost)

{-| `Regex` was moved to a separate package in Elm 0.19, and the
API had some significant changes. Those changes are back-ported here, so much
as is possible.

@docs fromString, fromStringWith, Options, never

@docs split, splitAtMost, find, findAtMost

-}

import Regex exposing (HowMany(..), Match, Regex, caseInsensitive, regex)


{-| Try to create a `Regex`.

    import Regex

    lowerCase : Regex.Regex
    lowerCase =
        Maybe.withDefault Regex.never <|
            Regex.fromString "[a-z]+"

**Note:** There are some [shorthand character classes][short] like `\w` for
word characters, `\s` for whitespace characters, and `\d` for digits. **Make
sure they are properly escaped!** If you specify them directly in your code,
they would look like `"\\w\\s\\d"`.

[short]: https://www.regular-expressions.info/shorthand.html

> In Elm 0.19, this returns a `Maybe` in order to cover cases where the
> input is not a valid regular expression. It is not practical to port this
> behaviour back to Elm 0.18, so we always return `Just ...`, and crash if
> the input is not valid (as Elm 0.18 would do).

-}
fromString : String -> Maybe Regex
fromString =
    regex >> Just


{-| Create a `Regex` with some additional options. For example, you can define
`fromString` like this:

    import Regex

    fromString : String -> Maybe Regex.Regex
    fromString string =
        fromStringWith { caseInsensitive = False } string

> In Elm 0.19, there is also a `multiline` option, but it is not practical
> to back-port this option to Elm 0.18.

-}
fromStringWith : Options -> String -> Maybe Regex
fromStringWith options =
    let
        applyOptions =
            if options.caseInsensitive then
                caseInsensitive
            else
                identity
    in
    Maybe.map applyOptions << fromString


{-| This type was introduced in Elm 0.19. In Elm 0.19, it also has a
`multiline` field, but it is not practical to back-port that behaviour
to Elm 0.18.
-}
type alias Options =
    { caseInsensitive : Bool
    }


{-| A regular expression that never matches any string.
-}
never : Regex
never =
    regex ".^"


{-| Split a string. The following example will split on commas and tolerate
whitespace on either side of the comma:

    import Regex

    comma : Regex.Regex
    comma =
        Maybe.withDefault Regex.never <|
            Regex.fromString " *, *"


    -- Regex.split comma "tom,99,90,85"     == ["tom","99","90","85"]
    -- Regex.split comma "tom, 99, 90, 85"  == ["tom","99","90","85"]
    -- Regex.split comma "tom , 99, 90, 85" == ["tom","99","90","85"]

If you want some really fancy splits, a library like
[`elm/parser`][parser] will probably be easier to use.

[parser]: /packages/elm/parser/latest

-}
split : Regex -> String -> List String
split =
    Regex.split All


{-| Just like `split` but it stops after some number of matches.

A library like [`elm/parser`][parser] will probably lead to better code in
the long run.

[parser]: /packages/elm/parser/latest

-}
splitAtMost : Int -> Regex -> String -> List String
splitAtMost =
    Regex.split << AtMost


{-| Find matches in a string:

    import Regex

    location : Regex.Regex
    location =
        Maybe.withDefault Regex.never <|
            Regex.fromString "[oi]n a (\\w+)"

    places : List Regex.Match
    places =
        Regex.find location "I am on a boat in a lake."


    -- map .match      places == [ "on a boat", "in a lake" ]
    -- map .submatches places == [ [Just "boat"], [Just "lake"] ]

If you need `submatches` for some reason, a library like
[`elm/parser`][parser] will probably lead to better code in the long run.

[parser]: /packages/elm/parser/latest

-}
find : Regex -> String -> List Match
find =
    Regex.find All


{-| Just like `find` but it stops after some number of matches.

A library like [`elm/parser`][parser] will probably lead to better code in
the long run.

[parser]: /packages/elm/parser/latest

-}
findAtMost : Int -> Regex -> String -> List Match
findAtMost =
    Regex.find << AtMost


{-| Replace matches. The function from `Match` to `String` lets
you use the details of a specific match when making replacements.

    import Regex

    userReplace : String -> (Regex.Match -> String) -> String -> String
    userReplace userRegex replacer string =
        case Regex.fromString userRegex of
            Nothing ->
                string

            Just regex ->
                Regex.replace regex replacer string

    devowel : String -> String
    devowel string =
        userReplace "[aeiou]" (\_ -> "") string


    -- devowel "The quick brown fox" == "Th qck brwn fx"

    reverseWords : String -> String
    reverseWords string =
        userReplace "\\w+" (.match >> String.reverse) string


    -- reverseWords "deliver mined parts" == "reviled denim strap"

-}
replace : Regex -> (Match -> String) -> String -> String
replace =
    Regex.replace All


{-| Just like `replace` but it stops after some number of matches.

A library like [`elm/parser`][parser] will probably lead to better code in
the long run.

[parser]: /packages/elm/parser/latest

-}
replaceAtMost : Int -> Regex -> (Match -> String) -> String -> String
replaceAtMost =
    Regex.replace << AtMost
