module Maybe017 exposing (andThen, oneOf)

{-| Some functions from Elm 0.17

@docs andThen, oneOf

-}


{-| Chain together many computations that may fail. It is helpful to see its
definition:

    andThen : Maybe a -> (a -> Maybe b) -> Maybe b
    andThen maybe callback =
        case maybe of
            Just value ->
                callback value

            Nothing ->
                Nothing

This means we only continue with the callback if things are going well. For
example, say you need to use (`head : List Int -> Maybe Int`) to get the
first month from a `List` and then make sure it is between 1 and 12:

    toValidMonth : Int -> Maybe Int
    toValidMonth month =
        if month >= 1 && month <= 12 then
            Just month
        else
            Nothing

    getFirstMonth : List Int -> Maybe Int
    getFirstMonth months =
        head months `andThen` toValidMonth

If `head` fails and results in `Nothing` (because the `List` was `empty`),
this entire chain of operations will short-circuit and result in `Nothing`.
If `toValidMonth` results in `Nothing`, again the chain of computations
will result in `Nothing`.

-}
andThen : Maybe a -> (a -> Maybe b) -> Maybe b
andThen =
    flip Maybe.andThen


{-| Pick the first `Maybe` that actually has a value. Useful when you want to
try a couple different things, but there is no default value.

    oneOf [ Nothing, Just 42, Just 71 ] == Just 42
    oneOf [ Nothing, Nothing, Just 71 ] == Just 71
    oneOf [ Nothing, Nothing, Nothing ] == Nothing

-}
oneOf : List (Maybe a) -> Maybe a
oneOf maybes =
    case maybes of
        [] ->
            Nothing

        maybe :: rest ->
            case maybe of
                Nothing ->
                    oneOf rest

                Just _ ->
                    maybe
