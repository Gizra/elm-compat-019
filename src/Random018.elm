module Random018 exposing (bool)

{-| Elm 0.19 removed the `bool` function.

@docs bool

-}

import Random exposing (Generator, int, map)


{-| Create a generator that produces boolean values. The following example
simulates a coin flip that may land heads or tails.

    type Flip
        = Heads
        | Tails

    coinFlip : Generator Flip
    coinFlip =
        map
            (\b ->
                if b then
                    Heads

                else
                    Tails
            )
            bool

-}
bool : Generator Bool
bool =
    map ((==) 1) (int 0 1)
