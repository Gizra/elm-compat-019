module String018 exposing (toInt, toFloat)

{-| Elm 0.19 changed the signatures of `toInt` and `toFloat`.

@docs toInt, toFloat

-}

import Result exposing (fromMaybe)


{-| Try to convert a string into an int, failing on improperly formatted strings.

    String018.toInt "123" --> Ok 123

    String018.toInt "-42" --> Ok -42

    String018.toInt "3.1" --> Err "could not convert string '3.1' to an Int"

    String018.toInt "31a" --> Err "could not convert string '31a' to an Int"

If you are extracting a number from some raw user input, you will typically
want to use [`Result.withDefault`](Result#withDefault) to handle bad data:

    Result.withDefault 0 (String018.toInt "42") --> 42

    Result.withDefault 0 (String018.toInt "ab") --> 0

-}
toInt : String -> Result String Int
toInt input =
    fromMaybe
        ("could not convert string '" ++ input ++ "' to an Int")
        (String.toInt input)


{-| Try to convert a string into a float, failing on improperly formatted strings.

    String018.toFloat "123" --> Ok 123.0

    String018.toFloat "-42" --> Ok -42.0

    String018.toFloat "3.1" --> Ok 3.1

    String018.toFloat "31a" --> Err "could not convert string '31a' to a Float"

If you are extracting a number from some raw user input, you will typically
want to use [`Result.withDefault`](Result#withDefault) to handle bad data:

    Result.withDefault 0 (String018.toFloat "42.5") == 42.5

    Result.withDefault 0 (String018.toFloat "cats") == 0

-}
toFloat : String -> Result String Float
toFloat input =
    fromMaybe
        ("could not convert string '" ++ input ++ "' to a Float")
        (String.toFloat input)
