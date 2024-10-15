University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2022/2023

LECTURE 5: Recursive functions 1

v1.2

(c) 2017 Jan Snajder, 2022 Matija Sosic, 2023 Filip Sodic

==============================================================================

== RECAP =====================================================================

Last week we covered the full syntax of Haskell functions. You now know how to
write arbitrary complex functions, at least in terms of syntax. However, to
unleash the full computational power of Haskell, you must know how to
write recursive functions.

== INTRO =====================================================================

Recursion occurs when we define a concept by depending on a simpler version of
the same concept. For example, here's a mathematical definition of the
factorial operation:

0! = 1
n! = n * (n - 1)!

All recursive definitions come down to two cases:
- The base case (the simplest case) - The terminating case that doesn't use
  recursion to produce the result (e.g., the definition for `0!`). 
- The recursive step - A set of rules that reduces all other cases to the base
  case. It uses recursion the result (e.g., the definition for `n!`).

In programming, recursive functions are functions that call themselves.

Since purely functional languages (like Haskell) dissallow mutation, they can't
have loops. Therefore, many problems in functional programming are solved using
recursion.

Here's how we might implement the factorial function in Haskell:

> fact :: Integral a => a -> a 
> fact x = if x == 0 then 1 else x * fact (x - 1)

Or, better, with pattern matching (separate function bodies):

> fact' :: Integral a => a -> a 
> fact' 0 = 1
> fact' x = x * fact' (x - 1)

Another typical example is getting the nth Fibonacci Number:

> fib :: Int -> Int 
> fib 0 = 0
> fib 1 = 1
> fib n = fib (n - 1) + fib (n - 2)

(This definition is not the best one. Do you know why?)

Haskellers are quite proud of the quicksort definition:

> quicksort :: Ord a => [a] -> [a]
> quicksort [] = []
> quicksort (x : xs) = quicksort lesser ++ [x] ++ quicksort greater
>   where lesser = [y | y <- xs, y <= x]
>         greater = [y | y <- xs, y  > x]

== STRUCTURAL RECURSION ======================================================

We'll now focus on recursion over a data structure. We'll mostly be doing this
over a LIST or a TREE, but it works with any recursive structure. This
pattern is called STRUCTURAL RECURSION and we use it to process items inside
data structure (something we would do using a loop in an imperative language).

The main idea: recurse down the structure by gradually decomposing it using
pattern matching, and combine the results:

> sum' :: Num a => [a] -> a
> sum' []     = 0
> sum' (x : xs) = x + sum' xs

> length' :: [a] -> Int
> length' []     = 0
> length' (_ : xs) = 1 + length' xs

> incList :: Num a => [a] -> [a]
> incList []     = []
> incList (x : xs) = (x + 1) : incList xs

(The last function can be defined via list comprehension. How?)

> incList' :: Num a => [a] -> [a]
> incList' xs = [ x + 1 | x <- xs ]

> concat' :: [[a]] -> [a]
> concat' []       = []
> concat' (xs : xss) = xs ++ concat' xss

> maximum' :: Ord a => [a] -> a
> maximum' [x]    = x
> maximum' (x :xs) = max x (maximum' xs)

(What would happen if we were to apply this function to an empty list?)

What is the time complexity of the above functions?

For lists of length 'n', the time complexity is O(n).

Notice that there is a recurring pattern in the above functions: 

foo ...                             <-- base case
foo (x:xs) = f x `operator` foo xs  <-- general case

== EXERCISE 1 ================================================================

1.1.
- Define a recursive function to compute the product of a list of elements.

1.2.
- Define a recursive function 'headsOf' that takes a list of lists and
  returns a list of their heads.
  headsOf :: [[a]] -> [a]
  headsOf [[1,2,3],[4,5],[6]] => [1,4,6]

- Bonus question: try to do it with a list comprehension?

==============================================================================

Recursive functions can have many arguments. Arguments that remain
unchanged throughout the recursive calls exist only to store the state. We
call such arguments CONTEXT VARIABLES. For example:

> addToList :: Num a => a -> [a] -> [a]
> addToList _ []     = []
> addToList n (x : xs) = x + n : addToList n xs

Of course, if required, we can change the variables in each recursive call:

What if we wanted to define a function that increments the first element by 0,
the second by 1, etc.?

incIncList' [3,2,1] => [3,3,3]

We need an extra argument to "carry" some state while we traverse the list:

> incIncList :: Num a => a -> [a] -> [a]
> incIncList _ []     = []
> incIncList n (x : xs) = x + n : incIncList (n + 1) xs

To make the function more ergonimic and spare the caller from having to always
provide 0 as the first argument, we can define a WRAPPER FUNCTION:

> incIncList' :: Num a => [a] -> [a]
> incIncList' xs = inc 0 xs
>   where
>     inc _ []     = []
>     inc n (y : ys) = y + n : inc (n + 1) ys

== EXERCISE 2 ================================================================

2.1.
- Define a recursive function 'modMult n m xs' that multiplies each element of
  a list 'xs' with 'n' and then does modulo 'm'.
  modMult :: Integral a => a -> a -> [a] -> [a]
  modMult 3 4 [1,2,3] => [3, 2, 1]

2.2.
- Define a function 'addPredecessor' that adds to each element of a list the
  value of the preceding element. The first element gets no value added.
  addPredecessor :: Num a => [a] -> [a]
  addPredecessor [3,2,1] => [3,5,3]

==============================================================================

The recurisve case can act differently depending on additional conditions.
Let's use that idea to implement a function that counts the number of positive
numbers in a list:

> countPositives :: (Num a, Ord a) => [a] -> Int
> countPositives []     = 0
> countPositives (x : xs)
>  | x >= 0  = 1 + countPositives xs
>  | otherwise = countPositives xs

== EXERCISE 3 ================================================================

3.1.
- Define 'equalTriplets' that filters from a list of triplets (x,y,z) all
  triplets for which x==y==z.
  equalTriplets [(1,2,3),(2,2,2),(4,5,6)] => [(2,2,2)]

3.2.
- Define your own version of the `replicate`` function. Implement it using
  recursion (not using the `repeat` function from Prelude).
  replicate' :: Int -> a -> [a]
  replicate' 3 7 => [7,7,7]
  replicate' 0 7 => []
  replicate' (-2) 7 => []

==============================================================================

Let's define our version of `take`:

> take' :: Int -> [a] -> [a]
> take' _ [] = []
> take' n (x : xs)
>  | n <= 0 = []
>  | otherwise = x : take' (n - 1) xs

Does this work as expected if n < 0 (it should return an empty list)?

How can we extend the above definition so that, if n > length xs, the last
element of the list gets repeated?
supertake 5 [1,2,3] => [1,2,3,3,3]


> supertake :: Int -> [a] -> [a]
> supertake _ [] = []
> supertake n (x : xs)
>  | n <= 0 = []
>  | null xs = x : supertake (n - 1) [x]
>  | otherwise = x : supertake (n - 1) xs

Of course, in the real world, we would define this function without writing our
own recursion. We would instead use standard functions from Prelude:

> supertakeP :: Int -> [a] -> [a]
> supertakeP n xs
>   | n > length xs = xs ++ replicate (n - length xs) (last xs)
>   | otherwise = take n xs

Or, even better:

> supertakeP' :: Int -> [a] -> [a]
> supertakeP' n xs = take n $ xs ++ repeat (last xs)

== EXERCISE 4 ================================================================

4.1.
- Define your own recursive version of the drop function:
  drop' :: Int -> [a] -> [a].
- Define drop'' (a wrapper function) so that for n < 0 the function drops
  the elements from the end of the list. You can use 'reverse'.
  drop' 2 [1,2,3] = [3]
  drop' 4 [1,2,3] = []
  drop' (-2) [1,2,3] = [1,2,3]

4.2.
- Define a recursive function 'takeFromTo n1 n2 xs'.
  takeFromTo :: Int -> Int -> [a] -> [a]
  takeFromTo 1 4 [1..6] => [2,3,4,5]
  takeFromTo 2 2 [1..6] => [3]

==============================================================================

Here's how the 'zip' function is defined:

> zip' :: [a] -> [b] -> [(a, b)]
> zip' []     _      = []
> zip' _      []     = []
> zip' (x : xs) (y : ys) = (x, y) : zip' xs ys

How can we extend this so that it only pairs up (x,y) where x==y?

> zipEquals :: Eq a => [a] -> [a] -> [(a, a)]
> zipEquals [] _ = []
> zipEquals _ [] = []
> zipEquals (x : xs) (y : ys)
>   | x == y = (x, y) : zipEquals xs ys
>   | otherwise = zipEquals xs ys

We don't always need to process the elements one by one. For example, a
function that takes a list and pairs up the consecutive elements would be
defined like this:

> pairUp :: [a] -> [(a,a)]
> pairUp (x : y : xs) = (x, y) : pairUp xs
> pairUp _        = []

== EXERCISE 5 ================================================================

5.1.
- Define a recursive function 'eachThird' that retains every third element
  in a list.
  eachThird :: [a] -> [a]
  eachThird "zagreb" => "gb"
  eachThird "haskell" => "sl"
  eachThird "yo" => ""

5.2.
- Define a recursive function 'crossZip' that zips two lists in a "crossing"
  manner:
  crossZip [1,2,3,4,5] [4,5,6,7,8] => [(1,5),(2,4),(3,7),(4,6)]

==============================================================================

Let's have a look at two more exotic function.

First is 'reverse'. How would you go about defining the reverse function
recursively?

Here the solution:

> reverse1 :: [a] -> [a]
> reverse1 []     = []
> reverse1 (x : xs) = reverse1 xs ++ [x]

Space complexity is O(n) but time complexity is as much as O(n^2).
Can you say why?

This is bad. We'll see next week how to improve on this and write an
alternative definition to reduce both the space and time complexity.

Another function is 'unzip':

> unzip'' :: [(a,b)] -> ([a],[b])
> unzip'' []          = ([], [])
> unzip'' ((x, y) : zs) = (x : xs, y : ys)
>   where
>     (xs, ys) = unzip'' zs

== CORECURSION ===============================================================

Corecursion is "dual" to recursion: Recursive functions are functions expressed
in terms of themselves, and corecursive variables are variabels expressed in
terms of themselves.

Instead of decomposing a structure, we build it up. In RECURSION, each recursive
call is applied to a structure that is smaller than the input structure.
Conversely, in CORECURSION, the recursive call is applied to a larger structure
than the input structure and there is no base case. The structure that we build
up can be finite or infinite. Of course, thanks of laziness, we will build only
as much as needed.

> ones :: [Integer]
> ones = 1 : ones

> repeat' :: a -> [a]
> repeat' x = x : repeat' x

In each step we can use a part of the already constructed structure.

List of natural numbers:

> nats :: [Integer]
> nats = 0 : [n + 1 | n <- nats]

A bit more complex: a list of Fibonacci Numbers:

> fibs :: [Integer]
> fibs = 0 : 1 : [a + b | (a, b) <- zip fibs (tail fibs)]

More details here:
http://programmers.stackexchange.com/questions/144274/whats-the-difference-between-recursion-and-corecursion

== NEXT ======================================================================

Next week, we'll continue talking about recursion, and also look into how to
make Haskell less lazy and more strict.
