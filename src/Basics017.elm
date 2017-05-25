module Basics017 exposing (fst, snd)

{-| Several functions from Elm 0.17 were moved to other modules in Elm 0.18, so
here they are!

@docs fst, snd

-}

import Tuple


{-| Given a 2-tuple, returns the first value.
-}
fst : ( a, b ) -> a
fst =
    Tuple.first


{-| Given a 2-tuple, returns the second value.
-}
snd : ( a, b ) -> b
snd =
    Tuple.second
