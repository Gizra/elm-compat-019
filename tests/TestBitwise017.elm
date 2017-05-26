module TestBitwise017 exposing (..)

{-| Tests adapted from Elm 0.17, to see whether we can pass.
-}

import Bitwise017 as Bitwise
import Expect
import Test exposing (..)


suite =
    describe


assertEqual expected tried =
    always (Expect.equal expected tried)


basics : Test
basics =
    describe "Bitwise017"
        [ suite "shiftLeft"
            [ test "8 `shiftLeft` 1 == 16" <| assertEqual 16 (Bitwise.shiftLeft 8 1)
            , test "8 `shiftLeft` 2 == 32" <| assertEqual 32 (Bitwise.shiftLeft 8 2)
            ]
        , suite "shiftRight"
            [ test "32 `shiftRight` 1 == 16" <| assertEqual 16 (Bitwise.shiftRight 32 1)
            , test "32 `shiftRight` 2 == 8" <| assertEqual 8 (Bitwise.shiftRight 32 2)
            , test "-32 `shiftRight` 1 == -16" <| assertEqual -16 (Bitwise.shiftRight -32 1)
            ]
        , suite "shiftRightLogical"
            [ test "32 `shiftRightLogical` 1 == 16" <| assertEqual 16 (Bitwise.shiftRightLogical 32 1)
            , test "32 `shiftRightLogical` 2 == 8" <| assertEqual 8 (Bitwise.shiftRightLogical 32 2)
            , test "-32 `shiftRightLogical` 1 == 2147483632" <| assertEqual 2147483632 (Bitwise.shiftRightLogical -32 1)
            ]
        ]
