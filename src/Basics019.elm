module Basics019 exposing (modBy, remainderBy)

{-| Elm 0.19 renamed these two functions, so here they are with their
new names.

@docs modBy, remainderBy

-}


{-| Perform [modular arithmetic](https://en.wikipedia.org/wiki/Modular_arithmetic).
A common trick is to use (n mod 2) to detect even and odd numbers:

    modBy 2 0 --> 0

    modBy 2 1 --> 1

    modBy 2 2 --> 0

    modBy 2 3 --> 1

Our `modBy` function works in the typical mathematical way when you run into
negative numbers:

    List.map (modBy 4)
        [ -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5 ]
        --> [  3,  0,  1,  2,  3,  0,  1,  2,  3,  0,  1 ]

Use [`remainderBy`](#remainderBy) for a different treatment of negative numbers,
or read Daan Leijen’s [Division and Modulus for Computer Scientists][dm] for more
information.

[dm]: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf

-}
modBy : Int -> Int -> Int
modBy =
    flip (%)


{-| Get the remainder after division. Here are bunch of examples of dividing by four:

    List.map (remainderBy 4)
        [ -5, -4, -3, -2, -1,  0,  1,  2,  3,  4,  5 ]
        --> [ -1,  0, -3, -2, -1,  0,  1,  2,  3,  0,  1 ]

Use [`modBy`](#modBy) for a different treatment of negative numbers,
or read Daan Leijen’s [Division and Modulus for Computer Scientists][dm] for more
information.

[dm]: https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf

-}
remainderBy : Int -> Int -> Int
remainderBy =
    flip rem
