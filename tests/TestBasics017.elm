module TestBasics017 exposing (..)

{-| Tests adapted from Elm 0.17, to see whether we can pass.
-}

import Basics017 exposing (fst, snd)
import Expect
import Test exposing (..)


basics : Test
basics =
    describe "Basics"
        [ test "fst (1, 2)" <|
            \_ ->
                fst ( 1, 2 )
                    |> Expect.equal 1
        , test "snd (1, 2)" <|
            \_ ->
                snd ( 1, 2 )
                    |> Expect.equal 2
        ]
