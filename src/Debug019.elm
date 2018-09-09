module Debug019 exposing (toString, todo)

{-| Elm 0.19 moved `toString` to the `Debug` module, and renamed
`crash` to `todo`.

@docs toString, todo

-}


{-| Turn any kind of value into a string.

    Debug019.toString 42                --> "42"

    Debug019.toString [1,2]             --> "[1,2]"

    Debug019.toString ('a', "cat", 13)  --> "('a',\"cat\",13)"

    Debug019.toString "he said, \"hi\"" --> "\"he said, \\\"hi\\\"\""

Notice that with strings, this is not the `identity` function. It escapes
characters so if you say `Html.text (toString "he said, \"hi\"")` it will
show `"he said, \"hi\""` rather than `he said, "hi"`. This makes it nice
for viewing Elm data structures.

-}
toString : a -> String
toString =
    Basics.toString


{-| This is a placeholder for code that you will write later.

For example, if you are working with a large union type and have partially
completed a case expression, it may make sense to do this:

    type Entity = Ship | Fish | Captain | Seagull

    drawEntity entity =
      case entity of
        Ship ->
          ...

        Fish ->
          ...

        _ ->
          Debug.todo "handle Captain and Seagull"

The Elm compiler recognizes each `Debug.todo` so if you run into it, you get
an **uncatchable runtime exception** that includes the module name and line
number.

**Note:** For the equivalent of try/catch error handling in Elm, use modules
like [`Maybe`](#Maybe) and [`Result`](#Result) which guarantee that no error
goes unhandled!

-}
todo : String -> a
todo =
    Debug.crash
