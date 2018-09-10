module Basics018 exposing (rem, flip, curry, uncurry)

{-| Elm 0.19 made sevral changes:

  - renamed `rem` to `remainderBy`
  - removed `flip`,`curry`, and `uncurry`

The `toString` function was moved to the `Debug` module. It is not possible to
re-implement it here.

@docs rem, flip, curry, uncurry

-}


{-| Find the remainder after dividing one number by another.

    rem 11 4 --> 3

    rem 12 4 --> 0

    rem 13 4 --> 1

    rem -1 4 --> -1

-}
rem : Int -> Int -> Int
rem =
    flip remainderBy


{-| Flip the order of the first two arguments to a function.
-}
flip : (a -> b -> c) -> (b -> a -> c)
flip f b a =
    f a b


{-| Change how arguments are passed to a function.
This splits paired arguments into two separate arguments.
-}
curry : (( a, b ) -> c) -> a -> b -> c
curry f a b =
    f ( a, b )


{-| Change how arguments are passed to a function.
This combines two arguments into a single pair.
-}
uncurry : (a -> b -> c) -> ( a, b ) -> c
uncurry f ( a, b ) =
    f a b
