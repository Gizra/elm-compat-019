module Json.Decode017 exposing
    ( andThen, customDecoder
    , object1, object2, object3, object4, object5, object6, object7, object8
    , tuple1, tuple2, tuple3, tuple4, tuple5, tuple6, tuple7, tuple8
    )

{-| There were quite a few changes between Elm 0.17 and 0.18 in Json.Decode.
Here are some things from Elm 0.17.

@docs andThen, customDecoder
@docs object1, object2, object3, object4, object5, object6, object7, object8
@docs tuple1, tuple2, tuple3, tuple4, tuple5, tuple6, tuple7, tuple8

-}

import Json.Decode exposing (Decoder, fail, field, index, int, succeed)
import String exposing (fromInt)


{-| Helpful when a field tells you about the overall structure of the JSON
you are dealing with. For example, imagine we are getting JSON representing
different shapes. Data like this:

    { "tag": "rectangle", "width": 2, "height": 3 }
    { "tag": "circle", "radius": 2 }

The following `shape` decoder looks at the `tag` to know what other fields to
expect **and then** it extracts the relevant information.

    type Shape
        = Rectangle Float Float
        | Circle Float

    shape : Decoder Shape
    shape =
        field "tag" string `andThen` shapeInfo

    shapeInfo : String -> Decoder Shape
    shapeInfo tag =
        case tag of
            "rectangle" ->
                object2 Rectangle (field "width" float) (field "height" float)

            "circle" ->
                object1 Circle (field "radius" float)

            _ ->
                fail (tag ++ " is not a recognized tag for shapes")

-}
andThen : Decoder a -> (a -> Decoder b) -> Decoder b
andThen =
    \b a -> Json.Decode.andThen a b


{-| Create a custom decoder that may do some fancy computation.
-}
customDecoder : Decoder a -> (a -> Result String b) -> Decoder b
customDecoder decoder toResult =
    Json.Decode.andThen
        (\a ->
            case toResult a of
                Ok b ->
                    succeed b

                Err err ->
                    fail err
        )
        decoder


{-| Apply a function to a decoder. You can use this function as `map` if you
must (which can be done with any `objectN` function actually).

    object1 sqrt (field "x" float)

-}
object1 : (a -> value) -> Decoder a -> Decoder value
object1 =
    Json.Decode.map


{-| Use two different decoders on a JS value. This is nice for extracting
multiple fields from an object.

    point : Decoder ( Float, Float )
    point =
        object2 (\a b -> ( a, b ))
            (field "x" float)
            (field "y" float)

-}
object2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
object2 =
    Json.Decode.map2


{-| Use three different decoders on a JS value. This is nice for extracting
multiple fields from an object.

    type alias Job =
        { name : String, id : Int, completed : Bool }

    job : Decoder Job
    job =
        object3 Job
            (field "name" string)
            (field "id" int)
            (field "completed" bool)

-}
object3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
object3 =
    Json.Decode.map3


{-| -}
object4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
object4 =
    Json.Decode.map4


{-| -}
object5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
object5 =
    Json.Decode.map5


{-| -}
object6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
object6 =
    Json.Decode.map6


{-| -}
object7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
object7 =
    Json.Decode.map7


{-| -}
object8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
object8 =
    Json.Decode.map8


{-| Handle an array with exactly one element.

    extractString : Decoder String
    extractString =
        tuple1 identity string

    authorship : Decoder String
    authorship =
        oneOf
            [ tuple1 (\author -> "Author: " ++ author) string
            , list string |> map (\authors -> "Co-authors: " ++ String.join ", " authors)
            ]

-}
tuple1 : (a -> value) -> Decoder a -> Decoder value
tuple1 func d0 =
    -- We need to require that there is *exactly* 1 element in the array ...
    requireLength 1 <|
        object1 func
            (index 0 d0)


{-| If the JSON is an array of the specified length, applies the
supplied decoder to it. Otherwise, fails.
-}
requireLength : Int -> Decoder value -> Decoder value
requireLength required decoder =
    field "length" int
        |> Json.Decode.andThen
            (\length ->
                if length == required then
                    decoder

                else
                    fail <|
                        "Expected an array of length: "
                            ++ fromInt required
                            ++ ", but got an array of length: "
                            ++ fromInt length
            )


{-| Handle an array with exactly two elements. Useful for points and simple
pairs.

    point : Decoder ( Float, Float )
    point =
        tuple2 (\a b -> ( a, b )) float float


    -- ["John","Doe"] or ["Hermann","Hesse"]
    name : Decoder Name
    name =
        tuple2 Name string string

    type alias Name =
        { first : String, last : String }

-}
tuple2 : (a -> b -> value) -> Decoder a -> Decoder b -> Decoder value
tuple2 func d0 d1 =
    requireLength 2 <|
        object2 func
            (index 0 d0)
            (index 1 d1)


{-| Handle an array with exactly three elements.

    point3D : Decoder ( Float, Float, Float )
    point3D =
        tuple3 (\a b c -> ( a, b, c )) float float float

-}
tuple3 : (a -> b -> c -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder value
tuple3 func d0 d1 d2 =
    requireLength 3 <|
        object3 func
            (index 0 d0)
            (index 1 d1)
            (index 2 d2)


{-| -}
tuple4 : (a -> b -> c -> d -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder value
tuple4 func d0 d1 d2 d3 =
    requireLength 4 <|
        object4 func
            (index 0 d0)
            (index 1 d1)
            (index 2 d2)
            (index 3 d3)


{-| -}
tuple5 : (a -> b -> c -> d -> e -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder value
tuple5 func d0 d1 d2 d3 d4 =
    requireLength 5 <|
        object5 func
            (index 0 d0)
            (index 1 d1)
            (index 2 d2)
            (index 3 d3)
            (index 4 d4)


{-| -}
tuple6 : (a -> b -> c -> d -> e -> f -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder value
tuple6 func d0 d1 d2 d3 d4 d5 =
    requireLength 6 <|
        object6 func
            (index 0 d0)
            (index 1 d1)
            (index 2 d2)
            (index 3 d3)
            (index 4 d4)
            (index 5 d5)


{-| -}
tuple7 : (a -> b -> c -> d -> e -> f -> g -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder value
tuple7 func d0 d1 d2 d3 d4 d5 d6 =
    requireLength 7 <|
        object7 func
            (index 0 d0)
            (index 1 d1)
            (index 2 d2)
            (index 3 d3)
            (index 4 d4)
            (index 5 d5)
            (index 6 d6)


{-| -}
tuple8 : (a -> b -> c -> d -> e -> f -> g -> h -> value) -> Decoder a -> Decoder b -> Decoder c -> Decoder d -> Decoder e -> Decoder f -> Decoder g -> Decoder h -> Decoder value
tuple8 func d0 d1 d2 d3 d4 d5 d6 d7 =
    requireLength 8 <|
        object8 func
            (index 0 d0)
            (index 1 d1)
            (index 2 d2)
            (index 3 d3)
            (index 4 d4)
            (index 5 d5)
            (index 6 d6)
            (index 7 d7)
