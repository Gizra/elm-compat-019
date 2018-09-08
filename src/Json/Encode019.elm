module Json.Encode019 exposing (dict, set)

{-| Elm 0.19 moved this module to a separate package, and added
a couple of new encoders.

@docs dict, set

-}

import Dict exposing (Dict)
import Json.Encode exposing (Value, object, list)
import Set exposing (Set)


{-| Turn a `Dict` into a JSON object.

    import Dict
    import Json.Encode as Encode

    Dict.fromList [ ("Tom",42), ("Sue", 38) ]
        |> dict identity Encode.int
        |> Encode.encode 0
        --> """{"Tom":42,"Sue":38}"""

-}
dict : (comparable -> String) -> (v -> Value) -> Dict comparable v -> Value
dict toKey toValue =
    let
        go key value accum =
            ( toKey key, toValue value ) :: accum
    in
        Dict.foldl go [] >> object


{-| Turn an `Set` into a JSON array.

    import Json.Encode as Encode
    import Set

    Set.fromList [ 42, 38 ]
        |> set Encode.int
        |> Encode.encode 0
        --> "[38,42]"

-}
set : (comparable -> Value) -> Set comparable -> Value
set func =
    Set.toList >> List.map func >> list
