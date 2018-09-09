module Random019 exposing (constant, independentSeed, lazy, uniform, weighted)

{-| Elm 0.19 moved `Random` to a separate module and added several functions
to the API. Those functions are provided here.

Elm 0.19 also improved the basic algorithm for randomness. That is not
implemented here -- so, this is the Elm 0.18 algorithm with the Elm 0.19 API.
If you want something closer to the Elm 0.19 algorithm in Elm 0.18, then
consider using
[mgold/elm-random-pcg](https://package.elm-lang.org/packages/mgold/elm-random-pcg/latest)

@docs uniform, weighted, constant, lazy, independentSeed

-}

import Bitwise
import Random exposing (..)


{-| Generate the same value every time.

    import Random

    alwaysFour : Random.Generator Int
    alwaysFour =
        Random.constant 4

Think of it as picking from a hat with only one thing in it. It is weird,
but it can be useful with [`elm-community/random-extra`][extra] which has
tons of nice helpers.

[extra]: /packages/elm-community/random-extra/latest

-}
constant : a -> Generator a
constant value =
    map (always value) bool


{-| Generate values with equal probability. Say we want a random suit for some
cards:

    import Random

    type Suit
        = Diamond
        | Club
        | Heart
        | Spade

    suit : Random.Generator Suit
    suit =
        Random.uniform Diamond [ Club, Heart, Spade ]

That generator produces all `Suit` values with equal probability, 25% each.

**Note:** Why not have `uniform : List a -> Generator a` as the API? It looks
a little prettier in code, but it leads to an awkward question. What do you do
with `uniform []`? How can it produce an `Int` or `Float`? The current API
guarantees that we always have _at least_ one value, so we never run into that
question!

-}
uniform : a -> List a -> Generator a
uniform value valueList =
    weighted (addOne value) (List.map addOne valueList)


addOne : a -> ( Float, a )
addOne value =
    ( 1, value )


{-| Generate values with a _weighted_ probability. Say we want to simulate a
[loaded die](https://en.wikipedia.org/wiki/Dice#Loaded_dice) that lands
on ⚄ and ⚅ more often than the other faces:

    import Random

    type Face
        = One
        | Two
        | Three
        | Four
        | Five
        | Six

    roll : Random.Generator Face
    roll =
        Random.weighted
            ( 10, One )
            [ ( 10, Two )
            , ( 10, Three )
            , ( 10, Four )
            , ( 20, Five )
            , ( 40, Six )
            ]

So there is a 40% chance of getting `Six`, a 20% chance of getting `Five`, and
then a 10% chance for each of the remaining faces.

**Note:** I made the weights add up to 100, but that is not necessary. I always
add up your weights into a `total`, and from there, the probablity of each case
is `weight / total`. Negative weights do not really make sense, so I just flip
them to be positive.

-}
weighted : ( Float, a ) -> List ( Float, a ) -> Generator a
weighted first others =
    let
        normalize ( weight, _ ) =
            abs weight

        total =
            normalize first + List.sum (List.map normalize others)
    in
    map (getByWeight first others) (float 0 total)


getByWeight : ( Float, a ) -> List ( Float, a ) -> Float -> a
getByWeight ( weight, value ) others countdown =
    case others of
        [] ->
            value

        second :: otherOthers ->
            if countdown <= abs weight then
                value
            else
                getByWeight second otherOthers (countdown - abs weight)


{-| Helper for defining self-recursive generators. Say we want to generate a
random number of probabilities:

    import Random

    probabilities : Random.Generator (List Float)
    probabilities =
        Random.andThen identity <|
            Random.uniform
                (Random.constant [])
                [ Random.map2 (::)
                    (Random.float 0 1)
                    (Random.lazy (\_ -> probabilities))
                ]

In 50% of cases we end the list. In 50% of cases we generate a probability and
add it onto a random number of probabilities. The `lazy` call is crucial
because it means we do not unroll the generator unless we need to.

This is a pretty subtle issue, so I recommend reading more about it
[here](https://elm-lang.org/hints/0.19.0/bad-recursion)!

**Note:** You can delay evaluation with `andThen` too. The thing that matters
is that you have a function call that delays the creation of the generator!

-}
lazy : (() -> Generator a) -> Generator a
lazy callback =
    andThen callback (constant ())


{-| A generator that produces a seed that is independent of any other seed in
the program. These seeds will generate their own unique sequences of random
values. They are useful when you need an unknown amount of randomness _later_
but can request only a fixed amount of randomness _now_.

> It does not seem possible to implement Elm 0.19's exact algorithm in an Elm
> 0.18 user package. So, what is implemented here is an approximation of what Elm
> 0.19 does, and probably does not have the same quality of randomness.

-}
independentSeed : Generator Seed
independentSeed =
    -- The Elm 0.19 implementation relies on the internal properties of seeds,
    -- so we can't implement it quite the same way here. So, we try something
    -- that is roughly sinilar, but may or may not work as well.
    --
    -- 1. We generate two integers using our current seed. This advances the
    --    current seed (which you might call the "main" seed).
    --
    -- 2. We xor the two random integers together, and use the result to produce an
    --    `initialSeed`. (Elm 0.19's code also makes sure it is a positive odd
    --    number, but that's because they are working directly with the seed
    --    value, rather than going through `initialSeed`).
    --
    -- So, we end up with a new seed (you might call it a "forked" seed), and
    -- an updated "main" seed. Thus, if you do this again with the updated
    -- "main" seed, you should get a distinct "forked" seed the second time.
    --
    -- This is a bit simpler than the Elm 0.19 implementation, but it ought to
    -- work at some level. It probably does not produce the same quality of
    -- randomness that the Elm 0.19 implementation achieves (since the Elm 0.19
    -- implementation could be much simpler if it did).
    let
        gen =
            int 0 0xFFFFFFFF

        makeIndependentSeed a b =
            initialSeed (Bitwise.xor a b)
    in
    map2 makeIndependentSeed gen gen
