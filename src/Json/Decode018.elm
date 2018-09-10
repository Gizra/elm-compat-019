module Json.Decode018 exposing (decodeString, decodeValue)

{-| Elm 0.19 changed the signatures of `decodeString` and `decodeValue`.

@docs decodeString, decodeValue

-}

import Json.Decode exposing (Decoder, errorToString)
import Json.Encode exposing (Value)


{-| Parse the given string into a JSON value and then run the `Decoder` on it.
This will fail if the string is not well-formed JSON or if the `Decoder`
fails for some reason.

    import Json.Decode exposing (int)

    decodeString int "4"     --> Ok 4

    decodeString int "1 + 2" == Err ...

-}
decodeString : Decoder a -> String -> Result String a
decodeString decoder input =
    Json.Decode.decodeString decoder input
        |> Result.mapError errorToString


{-| Run a `Decoder` on some JSON `Value`. You can send these JSON values
through ports, so that is probably the main time you would use this function.
-}
decodeValue : Decoder a -> Value -> Result String a
decodeValue decoder input =
    Json.Decode.decodeValue decoder input
        |> Result.mapError errorToString
