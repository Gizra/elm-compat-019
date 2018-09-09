module TestRandom019 exposing (..)

import Expect
import Fuzz exposing (Fuzzer)
import Random exposing (Generator, Seed, initialSeed, step)
import Random019 exposing (constant, independentSeed, lazy, uniform)
import Test exposing (..)


fuzzSeed : Fuzzer Seed
fuzzSeed =
    Fuzz.map initialSeed Fuzz.int


testConstant : Test
testConstant =
    fuzz fuzzSeed "constant" <|
        \seed ->
            step (constant 17) seed
                |> Expect.all
                    [ \( value, _ ) -> Expect.equal value 17
                    , \( _, newSeed ) -> Expect.notEqual seed newSeed
                    ]


probabilities : Generator (List Float)
probabilities =
    Random.andThen identity <|
        uniform
            (constant [])
            [ Random.map2 (::)
                (Random.float 0 1)
                (lazy (\_ -> probabilities))
            ]


testLazy : Test
testLazy =
    -- We're just testing that lazy avoids blowing the stack
    step probabilities (initialSeed 0)
        |> always (test "lazy" (always Expect.pass))


testIndependentSeed : Test
testIndependentSeed =
    fuzz fuzzSeed "independentSeed" <|
        \seed ->
            let
                -- Given our original seed, we fork it
                ( forked1, seed1 ) =
                    step independentSeed seed

                -- Then, we do it again (with the updated main seed)
                ( forked2, seed2 ) =
                    step independentSeed seed1

                -- So, we should now have a bunch of seeds, all of which are
                -- unequal. We can't directly compare seeds, but we can step
                -- them and compare the results!
                results =
                    List.map
                        (step (Random.int 0 0xFFFFFFFF) >> Tuple.first)
                        [ seed, seed1, seed2, forked1, forked2 ]

                -- For each thing in the results, count how many there are in
                -- the list. (No doubt there is a more efficient way to do
                -- this).
                counts =
                    List.map (\result -> List.length (List.filter ((==) result) results)) results

                allOne =
                    List.all ((==) 1) counts
            in
            Expect.true "Should be unique" allOne
