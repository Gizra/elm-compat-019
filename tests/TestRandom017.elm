module TestRandom017 exposing (..)

{-| Tests adapted from Elm 0.17, to see whether we can pass.
-}

import Random017
import Expect
import Test exposing (..)


-- This is just here to test that Random017 compiles


tests : Test
tests =
    describe "Random017"
        [ test "Dummy test" <|
            \_ -> Expect.pass
        ]
