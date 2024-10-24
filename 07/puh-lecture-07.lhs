University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2022/2023

LECTURE 7: Higher-order functions 1

v1.0

(c) 2022 Jan Šnajder, Ante Kegalj
(c) 2017 Jan Šnajder

==============================================================================

> import Data.Tuple hiding (curry, uncurry)
> import Data.Char
> import Prelude hiding (map, filter, curry, uncurry)
> import Data.List hiding (map, filter)

=== RECAP ====================================================================

Last week we talked about recursion. It turns out that there are a number of
ubiquitous recursion patterns, which can be abstracted into so-called 
FUNCTIONAL IDIOMS using higher-order functions. We'll look into that today. 

=== LAMBDA EXPRESSIONS =======================================================

In Haskell, functions are first-class citizens, meaning they can be passed 
as arguments to other functions, returned as results, and assigned to 
variables—just like any other data type, such as numbers or lists.

With lambda expressions we can define ANONYMOUS FUNCTIONS. Anonymous functions
are functions that we only need once. Because we only need them once, we can
just as well define them exactly there where we need them, and we don't even
need to give them a name.

Instead of

  myFunction x = x + 5

we can write

  \x -> x + 5

and that's an anonymous function. Which means that in ghci we can do:

> myFunction x = x + 5

and then apply an argument to the function like so:  

myFunction $ 2

or like so:  

(\x -> x + 5) $ 2

We can give a name to an anonymous function

> addFive = \x -> x + 5

but this, obviously, makes little sense.

However this is in fact how haskell desugars the 'foo' function. 

Lambdas can take any number of arguments so lets say we have the following 
function:

> add x y = x + y

this gets desugared to 

> desugaredAdd = \x y -> x + y

But this isnt even its final form, which brings us into the next section, 
curried functions.

=== CURRIED FORM =============================================================

We know that functions in Haskell can take many arguments. For example:

> number :: Int -> Int -> Int
> number x y = x*10 + y

But the real truth is that functions in Haskell always take only ONE argument.
Functions that seem like they take multiple arguments are in fact CURRIED
FUNCTIONS. Such functions take the first argument and return a new function
that takes the second argument, then this function returns a new function that
takes the third argument, etc. So, each function takes only one argument and
returns a function that takes the next argument, while the last function
returns the final result. 

This means that the signature of the 'number' function is in fact:

  number :: Int -> (Int -> Int)

i.e., a function that takes an 'Int' and returns a function that takes 'Int'
and returns an 'Int'.

Similarly, a function for concatenating three strings:

> concatThree :: String -> (String -> (String -> String))
> concatThree s1 s2 s3 = s1 ++ s2 ++ s3

This may be more clear if we desugar the function

concatThree = \s1 s2 s3 -> s1 ++ s2 ++ s3
concatThree = \s1 -> (\s2 s3 -> s1 ++ s2 ++ s3)
concatThree = \s1 -> (\s2 -> (\s3 -> s1 ++ s2 ++ s3))

concatThree :: String -> String -> String -> String
concatThree  = \s1    ->(\s2    ->(\s3    -> s1 ++ s2 ++ s3)) 

Writing functions in curried form would be cumbersome, thats why we have
the syntax sugar :)  !
                 

As per convention, the operator '->' in a type signature is RIGHT ASSOCIATIVE.
This means that, if we drop the parentheses, they group to the right. So:

  a -> a -> a

is equal to

  a -> (a -> a)

hence we can (and we want to) drop the parentheses.

On the other hand, function APPLICATION is left associative. This means that

  number 1 2

is equivalent to

  (number 1) 2

To remember:
* operator '->' in a type signature is RIGHT associative
* function application is LEFT associative



=== PARTIAL APPLICATION ======================================================

What happens if a curried function is applied to a fewer number of arguments
than it actually has? For example:

> foo = number 5

Because

  number :: Int -> (Int -> Int)

then it has to be

  number 5 :: Int -> Int

Thus, by partially applying a function we obtain a new function that expects
the next argument. This makes it possible to define many specific functions
using one more generic function:

> fifty = number 5
> sixty = number 6
> atLeast100 = max 100

Notice that we could have defined:

> atLeast100' x = max 100 x

But real Haskellers don't do that! In general, instead of:

  foo x = f x

we define:

  foo = f

In lambda calculus, this is called ETA REDUCTION.

Note that, because of partial function application, the order with which the
arguments are defined is relevant. You should order the arguments so to
make it possible to define more specific functions. The first arguments 
should be those that vary the least, i.e., arguments for which we expect 
that the user would like to have them fixed.

Also note that partially applied functions cannot be shown. A partially 
applied function is still a function, and functions are not members of 
the Show typeclass.

=== SECTIONS =================================================================

Whenever we wish to partially apply an infix function, we use SECTIONS.

We write an infix function in parentheses and supply it with an argument on
either side:

> addTwo = (+2)
> halve  = (/2)
> divideTwoBy = (2/)
> is42   = (==42)
> lessThanTwo = (<2)
> aMillionOrMore = (>=1000000)

> finishSentence :: String -> String
> finishSentence = (++ ".")

> prependZero :: [Integer] -> [Integer]
> prependZero = (0:)

> prepend123 :: [Integer] -> [Integer]
> prepend123 = ([1,2,3] ++)

We can do the same with binary functions that are not defined as operators:

> isUpperLetter :: Char -> Bool
> isUpperLetter = (`elem` ['A'..'Z'])
 
=== EXERCISE 1 ===============================================================

Define the following functions using partial application of existing 
functions:

1.1.
- Function 'takeThree' that takes the first three elements from a list.
- Function 'dropThree' that drops the first three elements from a list.
- Function 'hundredTimes' that takes one element and repeats it 100 times in a
  list.

1.2.
- Define 'index' that indexes the elements in a list:
    index "xyz" => [(0,'x'),(1,'y'),(2,'z')]
- Define index' in which the index comes at the second position in the pair.

1.3.
- Define 'divider n' that returns a string of length 'n' consisting of
  characters '='.
  divider :: Int -> [Char]
  divider 3 => "==="

=== HIGHER-ORDER FUNCTIONS ===================================================

A higer-order function is a function that returns a function and/or takes a
function as argument.

For instance, a function that takes another function and applies it twice:

> applyTwice :: (a -> a) -> a -> a
> applyTwice f x = f (f x)

Note that in this case it would be incorrect to define the type as:

  applyTwice :: a -> a -> a -> a

or to apply the function as:

  applyTwice f = f f x

We've already defined some of higher-order functions. Here is a couple more:

> applyToPair :: (a -> b) -> (a, a) -> (b, b)
> applyToPair f (x, y) = (f x, f y)

> applyToPair2 :: (a -> b) -> (c -> d) -> (a, c) -> (b, d)
> applyToPair2 f g (x, y) = (f x, g y)

> equalBy :: Eq b => (a -> b) -> a -> a -> Bool
> equalBy p x y = p x == p y

What about functions that return function?

Recall: because of currying, every function of two or more arguments is in 
fact returning a function! For example:

> addThree :: Num a => a -> a -> a -> a   -- or: a -> (a -> (a -> a))
> addThree x y z = x + y + z

But here is a more concrete example:

A pair of functions imported from 'Data.Tuple'.

> curry :: ((a, b) -> c) -> a -> b -> c
> curry f a b = f (a,b)

> uncurry :: (a -> b -> c) -> (a, b) -> c
> uncurry f (a,b) = f a b 

> uncurryPlus = uncurry (+)
> regularPlus = curry uncurryPlus

=== EXERCISE 2 ==============================================================

2.1.
- Define 'applyOnLast f xs ys' that applies a binary function 'f' on the last
  element of 'xs' and the last element of 'ys'.
  applyOnLast (+) [1,2,3] [5,6] => 9
  applyOnLast max [1,2] [3,4] => 4
- Using this function and the 'addThree' function, define
  lastTwoPlus100 :: [Integer] -> [Integer] -> Integer
  lastTwoPlus100 [1,2,3] [6,5] => 108

2.2.
- Define 'applyManyTimes n f x' that applies 'n' times function 'f' to 
  argument 'x'. If n<=0, return 'x' unaltered.
  applyManyTimes 5 (+2) 0 => 10
  applyManyTimes 3 finishSentence "hm" => "hm..."
- Using 'applyManyTimes', define 'applyTwice'


=== MAP =======================================================================

Look at the following recursive functions:

> incList :: Num a => [a] -> [a]
> incList []     = []
> incList (x:xs) = x + 1 : incList xs

> uppercaseString :: String -> String
> uppercaseString []     = []
> uppercaseString (x:xs) = toUpper x : uppercaseString xs

> addToList :: Num a => a -> [a] -> [a]
> addToList _ []     = []
> addToList n (x:xs) = x + n : addToList n xs

Do you see a pattern here?

Let's define a higher-order function as a generalization of the above
functions:

> map :: (a -> b) -> [a] -> [b]
> map _ []     = []
> map f (x:xs) = f x : map f xs

We've just defined one of the most common functional idiom (design pattern)!
In fact, function 'map' is so commonly used that it is defined in the 
standard library.

We can now use 'map' and our knowledge of higher-order functions and sections
to elegantly define the following functions:

> incList' = map (+1)
> uppercaseString' = map toUpper
> addToList' n = map (+n)

Note that, being real Haskellers, we've eta reduced 
the definitions right away!

With 'map' we can do things for which we previously needed list comprehensions.

> lengths :: [[a]] -> [Int]
> lengths xss = [length xs | xs <- xss]

> lengths' :: Foldable t => [t a] -> [Int]
> lengths' = map length

> camelCase :: String -> String
> camelCase s = concat [toUpper h : t | (h:t) <- words s]

> camelCase2 s = concat $ map up $ words s
>   where up (h:t) = toUpper h : t

Because often 'map' is followed by 'concat', there is a function 'concatMap'
that does exactly this. For example:

> camelCase3 s = concatMap up $ words s
>   where up (h:t) = toUpper h : t

=== EXERCISE 3 ================================================================

Write the following functions using 'map'.

3.1.
- listifylist :: [a] -> [[a]]
  listifylist [1,2,3] => [[1],[2],[3]]

3.2.
- Define 'cutoff n xs', which cuts off all values from the lists 'xs' at 
  value 'n'.
  cutoff :: Int -> [Int] -> [Int]
  cutoff 100 [20,202,34,117] => [20,100,34,100]

=== FILTER ====================================================================

Consider the following function:

> evenNumbers :: Integral a => [a] -> [a] 
> evenNumbers [] = []
> evenNumbers (x:xs)
>   | even x    = x : evenNumbers xs
>   | otherwise = evenNumbers xs

By generalizing this function, we obtain the 'filter' higher-order function,
the second important functional idiom:

> filter :: (a -> Bool) -> [a] -> [a]
> filter _ [] = []
> filter p (x:xs)
>   | p x       = x : filter p xs
>   | otherwise = filter p xs

For example:

> threeOrMore = filter (>=3)
> digits = filter (`elem` ['0'..'9'])

By combining 'map' and 'filter', we can now implement all functions that we've
previously defined using list comprehensions. For example:

> caesarCode :: String -> String
> caesarCode s = [succ c | c <- s, c /= ' ']

> caesarCode' :: String -> String
> caesarCode' s = map succ $ filter (/=' ') s

=== EXERCISE 4 ================================================================

Define the following functions using 'map' and 'filter':

4.1.
- Function 'sumEvenSquares' that adds the squares of all even numbers from a
  list.
  sumEvenSquares :: [Integer] -> Integer
  sumEvenSquares [1,2,3,4] => 20

4.2.
- Function 'freq x xs' that counts how many times element 'x' occurs in list
  'xs'.
  freq :: Eq a => a -> [a] -> Int
  freq 'k' "kikiriki" => 3

4.3.
- Function 'freqFilter n' that filters all elements that occur at least 'n'
  times in a list.
  freqFilter :: Eq a => Int -> [a] -> [a]
  freqFilter 4 "kikiriki" => "iiii"

=== MORE ON LAMBDA EXPRESSIONS ================================================

We often use lambda expressions when applying a higher-order function. For
example, instead of

  incList' = map (+1)
  addToList' n = map (+n)

we can write

> incList'' = map (\x -> x + 1)
> addToList'' n = map (\x -> x + n)

although it doesn't really pay off here.

A function that adds 1 to each element in a list and then squares it:

> foo2 :: [Int] -> [Int]
> foo2 = map (\x -> (x + 1)^2) 

A lambda expression can also use pattern matching. For example, a function that
sums pairs from a list of pairs:

> addPairs :: [(Int,Int)] -> [Int]
> addPairs = map (\(x,y) -> x + y) 

Another example: instead of

  camelCase'' s = concatMap up (words s)
    where up (h:t) = toUpper h : t

we can define

> camelCase''' s = 
>  concatMap (\(h:t) -> toUpper h : t) $ words s

REMARK 1: If pattern matching within a lambda expression fails, we get a
runtime error.

REMARK 2: Avoid the use of lambda expressions. Use them only for functions that
are trivial, but not trivial enough to be defined using sections. For
nontrivial functions, use local definitions instead ("where" or "let"). This
will make your code more readable. Moreover, if you give your functions
meaningful names, your local definitions serve as a kind of documentation.

REMARK 3: Because FP is based on lambda calculus, each function can be written
as a lambda expression, although no one would really want to do that.

For example, instead of

  addThree :: Num a => a -> a -> a -> a
  addThree x y z = x + y + z

we could have defined  

> addThree' = \x y z -> x + y + z

or (due to currying)
  
> addThree'' = \x -> \y -> \z -> x + y + z

but this only makes the code less readable.

=== EXERCISE 5 ================================================================

5.1.
- Define a function 'withinInterval n m xs' that filters from list 'xs' all
  elements that fall within the [n,m] interval.

5.2
- Define 'canoinicalizePairs' that takes a list of pairs and returns a list of
  pairs with the order of elements switched so that the first element of the
  pair is smaller than the second one. Filter out any pair that has the
  first element equal to the second element
  canonicalizePairs :: Ord a => [(a, a)] -> [(a, a)]
  canonicalizePairs [(4,1), (2,2), (1,5)] => [(1,4), (1,5)]

5.3
- Define 'applyAndCombine': a function that takes two unary functions, applies 
  some input to them returns and combines the results into a result pair.
  applyAndCombine :: (a -> b) -> (a -> c) -> a -> (b, c)
  applyAndCombine (+2) (*3) 5 => (7, 15)


=== NEXT =====================================================================

There is more important stuff to learn about higher-order functions. 'map' and
'filter' are great, but there is one even more powerful functional pattern,
called 'fold', which you absolutely need to know about. We'll also look into
functional composition and how it can help us in writing even shorter code.

