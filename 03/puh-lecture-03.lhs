University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2024/2025

LECTURE 3: Types and type classes

v1.2

(c) 2017 Jan Šnajder
    2024 Luka Hadžiegrić

================================================================================

> import Data.Char
> import Data.List

== INTRO =======================================================================

So far, we've covered some basics of values, functions, guards, strings, lists,
tuples and list comprehensions. However, until now, we have not dealt with
types.

Haskell is (among other things):

* STRONGLY typed
  A loosely defined term generally used to describe programming languages that
  prevent programmers from circumventing their type system.

* STATICALLY typed
  Means that the type of each expression is known at compile time, and the code
  can be checked for type errors.

To be able to check for type errors, Haskell has to do TYPE INFERENCE. To this
end, Haskell uses the so-called Hindley-Milner (HM) type system. HM allows to
infer the most general type of a given program, using the type annotations
provided by the programmer as a starting point.

== TYPES =======================================================================

In Haskell, as in many other languages, you'll find the usual data types like
Bool, Int, Float, Double, Word (unsigned Int), String; as well as some less
common ones like () (pronounced unit), tuple (a, b, ...), Integer (infinitely
big integers), Natural (infinitely big natural numbers) and many more.

With those in mind, let's pause for a minute and think about "what is a type"?

* Types may be inhabited by values
  If we take Integer as an example, we can say that it is inhabited by values
  like -1, 5, 0, -22, etc. However, there are also types that have no values,
  like Void, however they are useful in some very specific cases.

* Types are not sets
  You might liken types to sets, however they have a very subtle but important
  difference with a big impact on type inference.

  When we talk about sets, we can say that sets, in some sense, imply values.
  However, when we talk about types, then values imply the types.

  In other words, in the context of sets, if we look at a particular value, it
  could belong to multiple sets, however, in the context of types, looking at a
  value should generally immediately tell us which type it inhabits.

  There are some exceptions, and one of them are numbers due to practical
  reasons, as it would be a paint to write e.g. I12 to be explicit that we are
  talking about 12 that inhabits Int.

* Types are interpretations of representations

  If we take a random byte in our memory, we may see something like e.g.
  10110110. But, what does it mean?

  Well, it means what ever we say it means. We could interpret it as a decimal
  number 182, or as the ASCII character ¶, or perhaps as some configuration
  with 8 options that can be turned on or off.

  Types are here to tell us how exactly we should interpret a certain data
  representation.

From now on, you will be expected to provide type signatures for all top level
definitions. So let's take a look at how to do that.

> addPairs :: [(Int, Int)] -> [Int]
> addPairs xs = [ x + y | (x, y) <- xs]

> lowerCase :: [Char] -> [Char]
> lowerCase s = [toLower c | c <- s]

Types serve both as a light form of documentation and as basic tests for your code.

> factorial :: Int -> Int
> factorial n = product [1..n]

> circumference :: Float -> Float
> circumference r = 2 * pi * r

> circumference' :: Double -> Double
> circumference' r = 2 * pi * r

So far, we've only used functions that take a single argument, but what if we
want to pass in multiple values into a function.

We could use tuples and do something like this:

> concatThree' :: (String, String, String) -> String
> concatThree' (s1, s2, s3) = s1 ++ s2 ++ s3

However, real Haskellers never do that! Instead, we'll do it as follows:

> concatThree :: String -> String -> String -> String
> concatThree s1 s2 s3 = s1 ++ s2 ++ s3

> number :: Int -> Int -> Int
> number x y = x * 10 + y

> trimBy :: Int -> String -> String
> trimBy n xs = reverse $ drop n $ reverse $ drop n xs

This way of defining functions of multiple arguments is called CURRIED FORM
(writing functions in this way is called CURRYING). We will come back to this
idea in Lecture 6, when we talk about higher-order functions.

=== EXERCISE 1 ===============================================================

Without using the ':t' command, determine the types of the following
functions:

> foo10 w = [x ++ y | x <- lines w, y <- lines w]
> foo11 w = [(x,y) | x <- lines w, y <- lines w]
> foo12 w = [y : x | x <- lines w, y <- w]
> foo13 w = [(y:x, w) | x <- lines w, y <- w]
> foo14 w = [(x, x=='a') | x <- w ]
> foo15 s = tail [ c | c <- s, isLower c ]
> foo16 s = zip [ c | c <- s, isLower c ] "Haskell"
> foo17 n c = reverse $ drop n $ c : "Haskell"
> foo18 xs = last $ words xs
> foo19 x z = x : 'y' : z

=== TYPE SYNONYMS ============================================================

Often it is useful to define an alias for a type, to make the code more
comprehensible. To this end we use the "type" keyword in Haskell.

A couple of examples:

> type IdNumber  = Int
> type FirstName = String
> type LastName  = String

Now, for example, 'IdNumber' is synonymous to 'Int' and you can use both
interchangeably. Note that, similar to built-in types, type names have to be
capitalized.

Note that this is exactly how 'String' is defined:

  type String = [Char]

We can now build more complex types:

> type Address = (String, Int, String)
> type Point = (Int, Int)

We can also reuse type definitions:

> type Person    = (FirstName, LastName)
> type Customer  = (Person, Address)
> type Customers = [Customer]
> type Triangle  = (Point, Point, Point)

=== POLYMORPHIC TYPES ========================================================

The types can be polymorphic, i.e., they can be generic so that they can adapt
(specialize) to a more concrete type.

Polymorphic functions: 'head', 'last', 'tail', 'fst', 'length', 'take', 'drop',
'concat', (++).

Variables 'a', 'b', etc. (written in lowercase) are called TYPE VARIABLES.

> listifySnd :: (a, b) -> [b]
> listifySnd p = [snd p]

Functions can be more or less polymorphic, i.e., more or less generic. E.g.:

> myConcat :: [a] -> [a] -> [a]
> myConcat s1 s2 = s1 ++ s2

but:

> myConcat' :: String -> String -> String
> myConcat' s1 s2 = s1 ++ s2

One more example of a generically-typed function:

> swap1 :: (a, b) -> (b, a)
> swap1 p = (snd p, fst p)

Three examples of more specific versions of the above function (note that the
definition remains the same, it's only the type that changes):

> swap2 :: (a, Int) -> (Int, a)
> swap2 p = (snd p, fst p)

> swap3 :: (a, a) -> (a, a)
> swap3 p = (snd p, fst p)

> swap4 :: (Int, Int) -> (Int, Int)
> swap4 p = (snd p, fst p)

These functions are (for no particular reason) more specific than they could
actually be. In practice, you should define the type that is as general as
possible. This is exactly the type that is inferred by the ':t' command. In
other words, HM algorithm infers the most general type.

Haskell type inference will detect all type errors before compiling the code.

bogus1 x = 2 + "abc"

bogus2 x = if x==5 then 1 else "error"

bogus3 x y = x ++ ' ' ++ y

bogus4 x = tail x ++ head x

Example of a type mismatch between type signature (expected type) and function
definition (actual type):

bogus5 :: Int -> Char -> [String]
bogus5 c n = take n [c,c..]

What is the type of the 'error' function?

It is often the case that we need some standard built-in function, but don't
know how it's called. If we know what the function is supposed to do, we can
guess its type and search for it with Hoogle (approximate type signature
Haskell API search engine):

http://www.haskell.org/hoogle/

=== EXERCISE 2 ===============================================================

Without using the ':t' command, determine the types of the following
functions:

> foo20 xs = tail xs ++ [head xs]
> foo21 xs = (head xs, tail xs)
> foo22 x xs = x:xs
> foo23 l = init $ tail l
> foo24 xss ys = concat xss ++ ys
> foo25 xss ys = (head $ concat xss, head ys)
> foo26 xs = head $ concat $ concat xs
> foo27 cs = [[c1,c2] | c1 <- cs, c2 <- cs]
> foo28 cs = [concat [c1,c2] | c1 <- cs, c2 <- cs]
> foo29 cs = concat [[c1,c2] | c1 <- cs, c2 <- cs]

=== TYPE CLASSES =============================================================

A type class is an INTERFACE that determines the interactions that we can have
with some type.

If type 'a' belongs to some type class, it means that functions provided by
that type class can be applied to the type 'a'.

Type definitions can have CLASS CONSTRAINTS. We use the symbol '=>' to define
such.

E.g., the definition of 'elem' function or (==) operator.

Class constraints are typical for polymorphic functions. This means that the
function is polymorphic (i.e., generic), nonetheless the type it operates on
has to support certain operations.

Basic type classes: Eq, Ord, Show, Read, Enum, Bounded, Num, Integral,
Floating.

Type class 'Eq' is for types that provide the equality test, i.e., operators
(==) and (/=). The majority of types belongs to this class, i.e., for the
majority of types we can test if two values are equal. Unfortunately, the
"function type" is not in this class. What this means is that we cannot test
whether two functions are equal. (Why is this so?)

1 == 1
(1,2) == (1,2)
[1,2,3] == [3,2,1,0]

But this won't work:

(1,2) /= (1,2,3)

because we're dealing with different types here. Keep in mind that (==) and
(/=) operate on two values of an identical type.

Type class 'Ord' is for types that can be compared, i.e., types with a defined
total order. These types provide the (>), (>=), (<), (<=) operators and the
'compare' function.

1 < 2
"water" <= "fire"
(1,2) < (2,1)
compare 1 2
compare "water" "fire"

(What do you think: what is the relation between 'Eq' and 'Ord' type classes?)

Type class 'Show' is for types that can be shown as a string. All such types
provide a 'show' function:

show :: Show a => a -> String

show 2.3
show [1,2,3]
show (1,2)

Conversely, type class 'Read' is for types whose values can be read in from in
a string. All such types provide a 'read' function:

read :: Read a => String -> a

For example:

read "True" || False
read "3.14" + 5.0
read "[1,2,3]" ++ [4]
read "(1,2)" : [(2,2)]

However, due to polymorphism, sometimes it is not possible to infer the type
automatically without the context:

read "4"
read "True"
read "[1,2,3]"

To resolve this, we need to provide more context, e.g.:

[read "True",True,False]

Alternatively, we can provide an explicit type annotation:

read "4" :: Int
read "4" :: Float
read "True" :: Bool
read "[1,2,3]" :: [Double]
read "[1,2,3]" :: [Int]

Type class 'Enum' is for enumerable types. Such types are, e.g., Bool, Char,
Int, Integer, Float, Double. These types provide the 'succ' and 'pred'
functions and can generate lists from a specified interval.

succ 'a'
succ '1'
['a'..'z']
['1'..'2']

succ 1.5
[1.5..5.5]

But the following is not defined:

succ (1,2)
succ [1]

'Bounded' is a type class for types that have an upper and lower bound:

maxBound :: Int
minBound :: Int

maxBound :: Char
minBound :: Char

Double, Float, Integer, String etc. are not bounded.

The values 'maxBound' and 'minBound' are not functions, but polymorphic
constant of type '(Bounded a) => a'.

'Num' is a type class for numbers.

:t 100

Integer types are polymorphic constants. They can assume every numeric type
depending on the context:

100 :: Int
100 :: Integer
100 :: Float
100 :: Double

Function 'sum' is defined for 'Num' types.

Type class 'Fractional' is for fractions. All types of this type class
provide the (/) operator.

Type class 'Floating' is for real numbers (fractions + trigonometric
operations, logarithm and exponential functions).

Type class 'Integral' is for integer numbers.

For example, functions 'odd' and 'even'.

Casting 'Integer' type into the more general 'Num' type:

fromIntegral :: (Num b, Integral a) => a -> b

fromIntegral (length [1,2,3]) / 2

Read more about numeric types here:
http://www.haskell.org/tutorial/numbers.html

Obviously, there are inheritance relations between the classes.

Diagrams:
- http://www.haskell.org/onlinereport/classes.gif
- http://lh4.ggpht.com/_PiUWFeprZSw/Sd72lQjUr3I/AAAAAAAAKfA/4PLE8uFQqUk/hs-nums.png

=== EXERCISE 3 ===============================================================

Without using the ':t' command, determine the types of the following
functions:

> foo30 x ys = if x == head ys then x else last ys
> foo31 x ys = if x < head ys then x else last ys
> foo32 xs yss = if xs == head yss then head xs else last xs
> foo33 x ys = if x then zip [1..9] ys else []
> foo34 w = zip [0..] (lines w)
> foo35 x y = if odd x then y else x `div` 10
> foo36 xs = sort xs == xs
> foo37 x xs = show x ++ (show $ concat xs)
> foo38 xs = sum $ concat xs
> foo39 xs yss = sum $ [min x y | x <- xs, ys <- yss, y <- ys]

=== NEXT =====================================================================

So far we've only written simple functions. Haskell syntax is more
sophisticated than what we've seen so far. Next, we'll look into pattern
matching and local definitions. Also, we'll take a look into how to set up a
Haskell project and package it using Cabal.
