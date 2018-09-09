module Tuple019 exposing (pair, mapBoth)

{-| Elm 0.19 added `pair` and `mapBoth`.

@docs pair, mapBoth

-}


{-| Create a 2-tuple.

    pair 3 4 --> (3, 4)

    zip : List a -> List b -> List (a, b)
    zip xs ys =
      List.map2 Tuple.pair xs ys

-}
pair : a -> b -> ( a, b )
pair a b =
    ( a, b )


{-| Transform both parts of a tuple.

    mapBoth String.reverse sqrt  ("stressed", 16) --> ("desserts", 4)

    mapBoth String.length negate ("stressed", 16) --> (8, -16)

-}
mapBoth : (a -> x) -> (b -> y) -> ( a, b ) -> ( x, y )
mapBoth funcA funcB ( x, y ) =
    ( funcA x, funcB y )
