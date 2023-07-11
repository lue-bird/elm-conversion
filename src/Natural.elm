module Natural exposing
    ( Natural(..), AtLeast1
    , fromN
    , toN
    )

{-| Natural number ≥ 0

@docs Natural, AtLeast1


## create

@docs fromN


## transform

@docs toN

The type is rarely useful in its current state,
as the only thing you can do is convert from and to other types.

This is enough for my use-cases
but feel free to PR or open an issue if you'd like to see support
for arbitrary-precision arithmetic like addition, multiplication, ...

-}

import ArraySized
import Bit exposing (Bit)
import BitArray
import BitArray.Extra
import N exposing (Min, N, Up0, n0, n1)
import N.Local exposing (n32)
import RecordWithoutConstructorFunction exposing (RecordWithoutConstructorFunction)


{-| Whole number (integer) >= 0 of arbitrary precision.
Either 0 directly or a positive number represented by the bit `I` followed by at most a given count of
[`Bit`](https://dark.elm.dmy.fr/packages/lue-bird/elm-bits/latest/Bit)s

If you need a natural number representation with a specific number of bits, go

    ArraySized Bit (Exactly (On bitLength))

For larger numbers, where you want to allow numbers of arbitrary precision,
only `O | I ...` can enforce that `==` always gives the correct answer,
since the `ArraySized` could be constructed with leading `O`s!

Feel free to incorporate this into a new `type`
with variants `NaN`, `Infinity`, ... based on your specific use-case

-}
type Natural
    = N0
    | AtLeast1 AtLeast1


{-| Positive natural number, can be arbitrarily large
-}
type alias AtLeast1 =
    RecordWithoutConstructorFunction
        { bitsAfterI : List Bit }


{-| Convert from a [natural number of type `N`](https://dark.elm.dmy.fr/packages/lue-bird/elm-bounded-nat/latest/)
-}
fromN : N range_ -> Natural
fromN =
    \n_ ->
        case
            n_
                |> BitArray.fromN n32
                |> BitArray.Extra.unpad
                |> ArraySized.hasAtLeast n1
        of
            Err _ ->
                N0

            Ok atLeast1 ->
                AtLeast1
                    { bitsAfterI = atLeast1 |> ArraySized.toList }


{-| Convert to a [natural number of type `N`](https://dark.elm.dmy.fr/packages/lue-bird/elm-bounded-nat/latest/)

Keep in mind that this can overflow
since `N` is fixed in bit size just like `Int` while [`Natural`](#Natural) is not.

-}
toN : Natural -> N (Min (Up0 minX_))
toN =
    \naturalNarrow ->
        case naturalNarrow of
            N0 ->
                n0 |> N.maxToInfinity

            AtLeast1 atLeast1 ->
                Bit.I
                    :: atLeast1.bitsAfterI
                    |> ArraySized.fromList
                    |> BitArray.toN
