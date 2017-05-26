module TestTask017 exposing (..)

{-| Tests adapted from Elm 0.17, to see whether we can pass.
-}

import Task017
import Expect
import Test exposing (..)


-- This is just here to test that Task017 compiles


basics : Test
basics =
    describe "Task017"
        [ test "Compiles" <|
            \_ -> Expect.pass
        ]
