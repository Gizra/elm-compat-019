module Random017 exposing (andThen)

{-| Like in other modules, the paramenters of `andThen` were flipped in Elm
0.18.

@docs andThen
-}

import Random exposing (Generator)


{-| Chain random operations, threading through the seed. In the following
example, we will generate a random letter by putting together uppercase and
lowercase letters.

    letter : Generator Char
    letter =
      bool `andThen` \b ->
        if b then uppercaseLetter else lowercaseLetter

    -- bool : Generator Bool
    -- uppercaseLetter : Generator Char
    -- lowercaseLetter : Generator Char
-}
andThen : Generator a -> (a -> Generator b) -> Generator b
andThen =
    flip Random.andThen
