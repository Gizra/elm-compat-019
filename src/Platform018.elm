module Platform018 exposing (program, programWithFlags)

{-| In Elm 0.19, `programWithFlags` was renamed to `worker`, and
`program` was removed.

@docs program, programWithFlags

-}

import Platform exposing (worker)


{-| Create a [headless] program. This is great if you want to use Elm as the
&ldquo;brain&rdquo; for something else. You can still communicate with JS via
ports and manage your model, you just do not have to specify a `view`.
-}
program :
    { init : ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }
    -> Program Never model msg
program args =
    worker
        { init = always args.init
        , update = args.update
        , subscriptions = args.subscriptions
        }


{-| Same as [`program`](#program), but you can provide flags.
-}
programWithFlags :
    { init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    }
    -> Program flags model msg
programWithFlags =
    worker
