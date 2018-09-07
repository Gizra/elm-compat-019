module TestRegex019 exposing (..)

import Expect
import Fuzz
import Regex
import Regex019
import Test exposing (..)


testNever : Test
testNever =
    fuzz Fuzz.string "never" <|
        \input ->
            Regex.contains Regex019.never input
                |> Expect.false ("Should not match: " ++ input)
