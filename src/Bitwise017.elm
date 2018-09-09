module Bitwise017 exposing (shiftLeft, shiftRight, shiftRightLogical)

{-| Elm 0.18 replaced some functions from Elm 0.17 with flipped versions.
So, here are the original unfipped versions.

@docs shiftLeft, shiftRight, shiftRightLogical

-}

import Bitwise


{-| Shift bits to the left by a given offset, filling new bits with zeros.
This can be used to multiply numbers by powers of two.

    8 `shiftLeft` 1 == 16

    8 `shiftLeft` 2 == 32

-}
shiftLeft : Int -> Int -> Int
shiftLeft =
    \b a -> Bitwise.shiftLeftBy a b


{-| Shift bits to the right by a given offset, filling new bits with
whatever is the topmost bit. This can be used to divide numbers by powers of two.

    32 `shiftRight` 1 == 16

    32
        `shiftRight` 2
        == 8
        - 32
        `shiftRight` 1
        == -16

This is called an [arithmetic right
shift](http://en.wikipedia.org/wiki/Bitwise_operation#Arithmetic_shift),
often written (>>), and sometimes called a sign-propagating
right shift because it fills empty spots with copies of the highest bit.

-}
shiftRight : Int -> Int -> Int
shiftRight =
    \b a -> Bitwise.shiftRightBy a b


{-| Shift bits to the right by a given offset, filling new bits with
zeros.

    32 `shiftRightLogical` 1 == 16

    32
        `shiftRightLogical` 2
        == 8
        - 32
        `shiftRightLogical` 1
        == 2147483632

This is called an [logical right
shift](http://en.wikipedia.org/wiki/Bitwise_operation#Logical_shift), often written (>>>),
and sometimes called a zero-fill right shift because it fills empty spots
with zeros.

-}
shiftRightLogical : Int -> Int -> Int
shiftRightLogical =
    \b a -> Bitwise.shiftRightZfBy a b
