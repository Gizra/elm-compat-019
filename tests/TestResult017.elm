module TestResult017 exposing (..)

{-| Tests adapted from Elm 0.17, to see whether we can pass.
-}

import Result017 exposing (andThen)
import Expect
import Test exposing (..)


suite =
    describe


assertEqual expected tried =
    always (Expect.equal expected tried)


isEven n =
    if n % 2 == 0 then
        Ok n
    else
        Err "number is odd"


basics : Test
basics =
    describe "Result017"
        [ suite "andThen Tests"
            [ test "andThen Ok" <|
                assertEqual
                    (Ok 42)
                    (andThen (String.toInt "42") isEven)
            , test "andThen first Err" <|
                assertEqual
                    (Err "could not convert string '4.2' to an Int")
                    (andThen (String.toInt "4.2") isEven)
            , test "andThen second Err" <|
                assertEqual
                    (Err "number is odd")
                    (andThen (String.toInt "41") isEven)
            ]
        ]
