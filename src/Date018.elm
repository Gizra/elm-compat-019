module Date018 exposing
    ( Date, now
    , toTime, fromTime
    , Month, Day
    )

{-| In Elm 0.19, the `Date` module was moved to a separate package
[elm-time](https://package.elm-lang.org/packages/elm/time/1.0.0/), with a
significantly modified API. This implements parts of the old API.

It is not practical to re-implement Elm 0.18's `fromString`. Elm 0.18 simply
supplied the input to the Javascript runtime to perform the conversion. To
implement that reliably in Elm 0.19, we would need a pure Elm function that
mimicked the behaviour of the Javascript runtime. This would be possible, but
does not seem practical.

It does not seem possible to re-implement the Elm 0.18 signatures for `year`,
`month`, `day`, `dayOfWeek`, `hour`, `minute`, `second`, or `millisecond`.
The difficulty is that they all have an implicit dependency on some time zone.

  - In Elm 0.18, they were calculated according to the local time zone. We can
    get that in Elm 0.19 via the `here` function, but that returns a `Task`. So,
    the function signatures would also need to return a `Task`.

  - We could re-implement the functions with the Elm 0.18 signatures if we
    assumed a UTC time zone. However, that would not be the same behaviour as in
    Elm 0.18, so it seems unwise.

Thus, for these functions, there is no real substitute for re-writing your code.
\`

@docs Date, now
@docs toTime, fromTime
@docs Month, Day

-}

import Result exposing (Result)
import Task exposing (Task)
import Time exposing (Posix, millisToPosix, posixToMillis)
import Time018 exposing (Time)



-- DATES


{-| Representation of a date.
-}
type alias Date =
    Time.Posix


{-| Get the `Date` at the moment when this task is run.
-}
now : Task x Date
now =
    Time.now



-- CONVERSIONS AND EXTRACTIONS


{-| Represents the days of the week.
-}
type alias Day =
    Time.Weekday


{-| Represents the month of the year.
-}
type alias Month =
    Time.Month


{-| Convert a `Date` to a time in milliseconds.

A time is the number of milliseconds since
[the Unix epoch](http://en.wikipedia.org/wiki/Unix_time).

-}
toTime : Date -> Time
toTime =
    posixToMillis >> toFloat


{-| Convert a time in milliseconds into a `Date`.

A time is the number of milliseconds since
[the Unix epoch](http://en.wikipedia.org/wiki/Unix_time).

-}
fromTime : Time -> Date
fromTime =
    round >> millisToPosix
