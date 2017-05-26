module TestMaybe017 exposing (..)

{-| Tests adapted from Elm 0.17, to see whether we can pass.
-}

import Maybe017 exposing (oneOf)
import Expect
import Test exposing (..)


basics : Test
basics =
    describe "Maybe017"
        [ test "[ Nothing, Just 42, Just 71 ]" <|
            \_ ->
                oneOf [ Nothing, Just 42, Just 71 ]
                    |> Expect.equal (Just 42)
        , test "[ Nothing, Nothing, Just 71 ]" <|
            \_ ->
                oneOf [ Nothing, Nothing, Just 71 ]
                    |> Expect.equal (Just 71)
        , test "[ Nothing, Nothing, Nothing ]" <|
            \_ ->
                oneOf [ Nothing, Nothing, Nothing ]
                    |> Expect.equal Nothing
        ]
