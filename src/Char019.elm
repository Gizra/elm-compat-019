module Char019 exposing (isAlpha, isAlphaNum)

{-| Elm 0.19 added a few new functions.

@docs isAlpha, isAlphaNum

-}

import Char exposing (isDigit, isLower, isUpper)


{-| Detect upper case and lower case ASCII characters.

    isAlpha 'a' --> True

    isAlpha 'b' --> True

    isAlpha 'E' --> True

    isAlpha 'Y' --> True

    isAlpha '0' --> False

    isAlpha '-' --> False

    isAlpha 'π' --> False

-}
isAlpha : Char -> Bool
isAlpha char =
    isLower char || isUpper char


{-| Detect upper case and lower case ASCII characters.

    isAlphaNum 'a' --> True

    isAlphaNum 'b' --> True

    isAlphaNum 'E' --> True

    isAlphaNum 'Y' --> True

    isAlphaNum '0' --> True

    isAlphaNum '7' --> True

    isAlphaNum '-' --> False

    isAlphaNum 'π' --> False

-}
isAlphaNum : Char -> Bool
isAlphaNum char =
    isLower char || isUpper char || isDigit char
