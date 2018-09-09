module TestResult017 exposing (assertEqual, basics, isEven, suite)

{-| Tests adapted from Elm 0.17, to see whether we can pass.
-}

import Expect
import Result017 exposing (andThen)
import Test exposing (..)


suite =
    describe


assertEqual expected tried =
    always (Expect.equal expected tried)


isEven n =
    if remainderBy 2 n == 0 then
        Ok n

    else
        Err "number is odd"


toInt : String -> Result String Int
toInt s =
    case String.toInt s of
        Just r ->
            Ok r

        Nothing ->
            Err "not an int"


basics : Test
basics =
    describe "Result017"
        [ suite "andThen Tests"
            [ test "andThen Ok" <|
                assertEqual
                    (Ok 42)
                    (andThen (toInt "42") isEven)
            , test "andThen first Err" <|
                assertEqual
                    (Err "not an int")
                    (andThen (toInt "4.2") isEven)
            , test "andThen second Err" <|
                assertEqual
                    (Err "number is odd")
                    (andThen (toInt "41") isEven)
            ]
        ]
