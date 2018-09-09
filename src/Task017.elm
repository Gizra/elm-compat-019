module Task017 exposing (andThen, onError, perform, andMap, fromMaybe, fromResult, toMaybe, toResult)

{-| Elm 0.18 flipped parameters for `andThen` and `onError`, altered `perform`,
and removed functions converting from and to `Maybe` and `Result`.

@docs andThen, onError, perform, andMap, fromMaybe, fromResult, toMaybe, toResult

-}

import Task exposing (Task, fail, map, succeed)


{-| Chain together a task and a callback. The first task will run, and if it is
successful, you give the result to the callback resulting in another task. This
task then gets run.

    succeed 2 `andThen` (\n -> succeed (n + 2)) -- succeed 4

This is useful for chaining tasks together. Maybe you need to get a user from
your servers _and then_ lookup their picture once you know their name.

-}
andThen : Task x a -> (a -> Task x b) -> Task x b
andThen =
    \b a -> Task.andThen a b


{-| Recover from a failure in a task. If the given task fails, we use the
callback to recover.

    fail "file not found" `onError` (\msg -> succeed 42) -- succeed 42

    succeed 9 `onError` (\msg -> succeed 42) -- succeed 9

-}
onError : Task x a -> (x -> Task y a) -> Task y a
onError =
    \b a -> Task.onError a b


{-| Command the runtime system to perform a task. The most important argument
is the `Task` which describes what you want to happen. But you also need to
provide functions to tag the two possible outcomes of the task. It can fail or
succeed, but either way, you need to have a message to feed back into your
application.
-}
perform : (x -> msg) -> (a -> msg) -> Task x a -> Cmd msg
perform onFail onSuccess =
    Task.attempt
        (\result ->
            case result of
                Ok a ->
                    onSuccess a

                Err x ->
                    onFail x
        )


{-| Put the results of two tasks together. If either task fails, the whole
thing fails. It also runs in order so the first task will be completely
finished before the second task starts.

This function makes it possible to chain tons of tasks together and pipe them
all into a single function.

    f `map` task1 `andMap` task2 `andMap` task3 -- map3 f task1 task2 task3

-}
andMap : Task x (a -> b) -> Task x a -> Task x b
andMap taskFunc =
    andThen taskFunc << (\b a -> map a b)


{-| Translate a task that can fail into a task that can never fail, by
converting any failure into `Nothing` and any success into `Just` something.

    toMaybe (fail "file not found") -- succeed Nothing

    toMaybe (succeed 42) -- succeed (Just 42)

This means you can handle the error with the `Maybe` module instead.

-}
toMaybe : Task x a -> Task never (Maybe a)
toMaybe =
    map Just >> Task.onError (always (succeed Nothing))


{-| If you are chaining together a bunch of tasks, it may be useful to treat
a maybe value like a task.

    fromMaybe "file not found" Nothing -- fail "file not found"

    fromMaybe "file not found" (Just 42) -- succeed 42

-}
fromMaybe : x -> Maybe a -> Task x a
fromMaybe default maybe =
    case maybe of
        Just value ->
            succeed value

        Nothing ->
            fail default


{-| Translate a task that can fail into a task that can never fail, by
converting any failure into `Err` something and any success into `Ok` something.

    toResult (fail "file not found") -- succeed (Err "file not found")

    toResult (succeed 42) -- succeed (Ok 42)

This means you can handle the error with the `Result` module instead.

-}
toResult : Task x a -> Task never (Result x a)
toResult =
    map Ok >> Task.onError (succeed << Err)


{-| If you are chaining together a bunch of tasks, it may be useful to treat
a result like a task.

    fromResult (Err "file not found") -- fail "file not found"

    fromResult (Ok 42) -- succeed 42

-}
fromResult : Result x a -> Task x a
fromResult result =
    case result of
        Ok value ->
            succeed value

        Err msg ->
            fail msg
