module Result017 exposing (andThen, formatError)

{-| `formatError` was renamed to `mapError` in Elm 0.18, and
the parameters of `andThen` were flipped.

@docs andThen, formatError

-}

import Result


{-| Chain together a sequence of computations that may fail. It is helpful
to see its definition:

    andThen : Result e a -> (a -> Result e b) -> Result e b
    andThen result callback =
        case result of
            Ok value ->
                callback value

            Err msg ->
                Err msg

This means we only continue with the callback if things are going well. For
example, say you need to use (`toInt : String -> Result String Int`) to parse
a month and make sure it is between 1 and 12:


    toValidMonth : Int -> Result String Int
    toValidMonth month =
        if month >= 1 && month <= 12 then
            Ok month

        else
            Err "months must be between 1 and 12"

    toMonth : String -> Result String Int
    toMonth rawString =
        toInt rawString `andThen` toValidMonth


    -- toMonth "4" == Ok 4
    -- toMonth "9" == Ok 9
    -- toMonth "a" == Err "cannot parse to an Int"
    -- toMonth "0" == Err "months must be between 1 and 12"

This allows us to come out of a chain of operations with quite a specific error
message. It is often best to create a custom type that explicitly represents
the exact ways your computation may fail. This way it is easy to handle in your
code.

-}
andThen : Result x a -> (a -> Result x b) -> Result x b
andThen =
    \b a -> Result.andThen a b


{-| Format the error value of a result. If the result is `Ok`, it stays exactly
the same, but if the result is an `Err` we will format the error. For example,
say the errors we get have too much information:

    parseInt : String -> Result ParseError Int

    type alias ParseError =
        { message : String
        , code : Int
        , position : (Int,Int)
        }

    formatError .message (parseInt "123") == Ok 123
    formatError .message (parseInt "abc") == Err "char 'a' is not a number"

-}
formatError : (error1 -> error2) -> Result error1 a -> Result error2 a
formatError =
    Result.mapError
