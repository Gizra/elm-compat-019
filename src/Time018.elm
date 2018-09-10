module Time018 exposing
    ( Time, now, every
    , millisecond, second, minute, hour
    , inMilliseconds, inSeconds, inMinutes, inHours
    )

{-| In Elm 0.19, the `Time` module was moved to a separate package
[elm-time](https://package.elm-lang.org/packages/elm/time/1.0.0/), with a
significantly modified API. This implements the old API.


# Time

@docs Time, now, every


# Units

@docs millisecond, second, minute, hour
@docs inMilliseconds, inSeconds, inMinutes, inHours

-}

import Task exposing (Task)
import Time exposing (millisToPosix, posixToMillis)



-- TIMES


{-| Type alias to make it clearer when you are working with time values.
Using the `Time` helpers like `second` and `inSeconds` instead of raw numbers
is very highly recommended.
-}
type alias Time =
    Float


{-| Get the `Time` at the moment when this task is run.
-}
now : Task x Time
now =
    Task.map
        (posixToMillis >> toFloat)
        Time.now


{-| Subscribe to the current time. First you provide an interval describing how
frequently you want updates. Second, you give a tagger that turns a time into a
message for your `update` function. So if you want to hear about the current
time every second, you would say something like this:

    type Msg = Tick Time | ...

    subscriptions model =
      every second Tick

Check out the [Elm Architecture Tutorial][arch] for more info on how
subscriptions work.

[arch]: https://github.com/evancz/elm-architecture-tutorial/

**Note:** this function is not for animation! You need to use something based
on `requestAnimationFrame` to get smooth animations. This is based on
`setInterval` which is better for recurring tasks like “check on something
every 30 seconds”.

-}
every : Time -> (Time -> msg) -> Sub msg
every interval tagger =
    Time.every
        interval
        (posixToMillis >> toFloat >> tagger)



-- UNITS


{-| Units of time, making it easier to specify things like a half-second
`(500 * millisecond)` without remembering Elm&rsquo;s underlying units of time.
-}
millisecond : Time
millisecond =
    1


{-| -}
second : Time
second =
    1000 * millisecond


{-| -}
minute : Time
minute =
    60 * second


{-| -}
hour : Time
hour =
    60 * minute


{-| -}
inMilliseconds : Time -> Float
inMilliseconds t =
    t


{-| -}
inSeconds : Time -> Float
inSeconds t =
    t / second


{-| -}
inMinutes : Time -> Float
inMinutes t =
    t / minute


{-| -}
inHours : Time -> Float
inHours t =
    t / hour
