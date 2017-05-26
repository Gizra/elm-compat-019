module TestJsonDecode017 exposing (..)

{-| Tests adapted from Elm 0.17, to see whether we can pass.
-}

import Json.Decode exposing (string, decodeString, int)
import Json.Decode017 as Json17 exposing ((:=), tuple1, tuple2, tuple3, tuple4)
import Expect
import Test exposing (..)


suite =
    describe


assertEqual expected tried =
    always (Expect.equal expected tried)


customTests : Test
customTests =
    let
        jsonString =
            """{ "foo": "bar" }"""

        customErrorMessage =
            "I want to see this message!"

        myDecoder =
            Json17.customDecoder ("foo" := string) (\_ -> Err customErrorMessage)
    in
        test "customDecoder preserves user error messages" <|
            \_ ->
                case decodeString myDecoder jsonString of
                    Ok _ ->
                        Expect.fail "expected `customDecoder` to produce a value of type Err, but got Ok"

                    Err message ->
                        if String.contains customErrorMessage message then
                            Expect.pass
                        else
                            Expect.fail <|
                                "expected `customDecoder` to preserve user's error message '"
                                    ++ customErrorMessage
                                    ++ "', but instead got: "
                                    ++ message


tupleTests : Test
tupleTests =
    let
        decoder1 =
            tuple1 identity int

        decoder2 =
            tuple2 (,) int int

        decoder3 =
            tuple3 (,,) int int int

        decoder4 =
            tuple4 (,,,) int int int int

        input1 =
            """[ 1 ]"""

        input2 =
            """[ 1, 2 ]"""

        input3 =
            """[ 1, 2, 3 ]"""

        input4 =
            """[ 1, 2, 3, 4 ]"""

        output1 =
            1

        output2 =
            ( 1, 2 )

        output3 =
            ( 1, 2, 3 )

        output4 =
            ( 1, 2, 3, 4 )
    in
        suite "tuples"
            [ test "tuple1 input1" <|
                \_ ->
                    decodeString decoder1 input1
                        |> Expect.equal (Ok output1)
            , test "tuple1 input2" <|
                \_ ->
                    decodeString decoder1 input2
                        |> Expect.err
            , test "tuple1 input3" <|
                \_ ->
                    decodeString decoder1 input3
                        |> Expect.err
            , test "tuple1 input4" <|
                \_ ->
                    decodeString decoder1 input4
                        |> Expect.err
            , test "tuple2 input1" <|
                \_ ->
                    decodeString decoder2 input1
                        |> Expect.err
            , test "tuple2 input2" <|
                \_ ->
                    decodeString decoder2 input2
                        |> Expect.equal (Ok output2)
            , test "tuple2 input3" <|
                \_ ->
                    decodeString decoder2 input3
                        |> Expect.err
            , test "tuple2 input4" <|
                \_ ->
                    decodeString decoder2 input4
                        |> Expect.err
            , test "tuple3 input1" <|
                \_ ->
                    decodeString decoder3 input1
                        |> Expect.err
            , test "tuple3 input2" <|
                \_ ->
                    decodeString decoder3 input2
                        |> Expect.err
            , test "tuple3 input3" <|
                \_ ->
                    decodeString decoder3 input3
                        |> Expect.equal (Ok output3)
            , test "tuple3 input4" <|
                \_ ->
                    decodeString decoder3 input4
                        |> Expect.err
            , test "tuple4 input1" <|
                \_ ->
                    decodeString decoder4 input1
                        |> Expect.err
            , test "tuple4 input2" <|
                \_ ->
                    decodeString decoder4 input2
                        |> Expect.err
            , test "tuple4 input3" <|
                \_ ->
                    decodeString decoder4 input3
                        |> Expect.err
            , test "tuple4 input4" <|
                \_ ->
                    decodeString decoder4 input4
                        |> Expect.equal (Ok output4)
            ]
