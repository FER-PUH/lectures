University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2017/2018

LECTURE 4: Syntax of functions

v1.0

(c) 2017 Jan Šnajder, 2022 Vlatko Klabučar, 2023 Mihovil Ilakovac

==============================================================================

> import Data.Char
> import Data.List
  
=== PATTERN MATCHING =========================================================

Remember guards?
  
> magicNumber :: Int -> String
> magicNumber x | x == 42   = "Yeah!"
>               | otherwise = "Nope, try again."

Instead of using guards, we can write out two CLAUSES with PATTERN MATCHING:

> magicNumber2 :: Int -> String
> magicNumber2 42 = "Yeah!"
> magicNumber2 x  = "Nope, try again."

If a variable is not used in the definition, we can anonymize it:

> magicNumber3 :: Int -> String
> magicNumber3 42 = "Yeah!"
> magicNumber3 _  = "Nope, try again."

We often do pattern matching on tuples:

> fst' :: (a, b) -> a
> fst' (x, _) = x

> snd' :: (a, b) -> b
> snd' (_, y) = y

> addVectors :: (Double, Double) -> (Double, Double) -> (Double, Double)
> addVectors (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

> swap :: (a, b) -> (b, a)
> swap (x, y) = (y, x)

> mallcolmInTheMiddle :: (a, b, c) -> b
> mallcolmInTheMiddle (_, y, _) = y

> leaves :: ((a, a), (a, a)) -> [a]
> leaves ((x, y), (z, w)) = [x, y, z, w]

Note that the above pattern will always match. We call such patterns
IRREFUTABLE. Some patterns, however, are REFUTABLE, i.e., they can fail to
match. For example:

> goo (x, 1) = x + 1

We can also pattern match on lists. For example, we can split up right away a
list into its head and tail:

> head' :: [a] -> a
> head' []    = error "No head to behead"
> head' (x:_) = x

> tail' :: [a] -> [a]
> tail' []     = []
> tail' (_:xs) = xs

Can we use pattern matching to accomplish the opposite: split up the initial
part of a list from its last element?

No, we can not. Because of the way how list is defined (a pair of a head and a
tail).

You can have many patterns:

> partnerSwap :: (a, b) -> (c, d) -> ((a, c), (b, d))
> partnerSwap (x, y) (z, w) = ((x, z), (y, w))

> headSwap :: [a] -> [a] -> ([a], [a])
> headSwap (x:xs) (y:ys) = (y:xs, x:ys)
> headSwap _ _ = error "Nope"

Also, we can have many different patterns:

> foo :: [a] -> [a] -> [a]
> foo (x:xs) (_:y:_) = x:y:xs
> foo (x:_)  [y]     = [x, y]
> foo xs     []      = xs

Furthermore, patterns can be nested:

> headOfHead :: [[a]] -> a
> headOfHead ((x:_):_) = x
> headOfHead _         = error "No head of head"

You must be careful how you order the definitions. The most general case should
come at the end:

> rhymeMe :: String -> String
> rhymeMe "letters" = "matters"
> rhymeMe "love"    = "glove"
> rhymeMe "pain"    = "rain"
> rhymeMe (x:xs)    = succ x : xs
> rhymeMe _         = "huh?"

Unless all your patterns are irrefutable, you must take care that all cases are
covered, i.e., that the patterns are exhaustive. This no good:

> fullName :: Char -> String
> fullName 'a' = "Ann"
> fullName 'b' = "Barney"
> fullName 'c' = "Clark"

As a matter of fact, "Non-exhaustive patterns" is one of the most
common runtime errors in Haskell. Thus, be watchful for non-exhaustive
patterns, especially when pattern matching on recursive data types (e.g.,
lists). Compiler can warn whether the patterns are exhaustive if started 
with `-Wincomplete-patterns` flag. To enable all warnings use `-Wall` flag.

What is the difference between '[x,y]' from '(x:y:_)' ?

> describeList :: Show a => [a] -> String
> describeList []      = "This thing is empty"
> describeList [x]     = "This list has only one element: " ++ show x
> describeList [x, y]  = "This list has elements " ++ show x ++ " and " ++ show y
> describeList (x:y:_) =
>   "This list has many elements, of which the first two are " ++
>   show x ++ " and " ++ show y

Now, let's say we'd also like to print out the length of the list in the above
function. For this we need the complete list. So, we need both the complete
list and its first two elements. We can do that with an AS-PATTERN:

> describeList' xs@(x:y:_) = 
>   "This list has " ++ show (length xs) ++ " elements, " ++
>   "of which the first two are " ++ show x ++ " and " ++ show y
> describeList' _          = "This list has two or less elements"

Another example of an AS-PATTERN in action:

> spellFirst :: String -> String
> spellFirst w@(c:_) = toUpper c : " as in " ++ w

Let's write a function that tests whether a matrix (here represented as a list
of lists) contains a row with identical elements. First shot:

> rowWithEqualElems :: Eq a => [[a]] -> Bool
> rowWithEqualElems m = 
>   or [ and [ e == head row | e <- row] |  row <- m ]

Pattern matching makes this a bit prettier:

> rowWithEqualElems' :: Eq a => [[a]] -> Bool
> rowWithEqualElems' m = 
>   or [ and [ e==h | e <- row] |  row@(h:_) <- m]

Important: All patterns within a list comprehension are irrefutable in the
sense that they cannot cause an error. If an element doesn't match a pattern,
it is simply skipped.

> singletonElems :: [[a]] -> [a]
> singletonElems xs = [x | [x] <- xs]

Another thing to remember is that you cannot test for equality by using a
variable multiple times. This will not work:

sameElems2 :: (a, a) -> Bool
sameElems2 (x, x) = True
sameElems2 _      = False

Nor will this:

headsEqual :: [a] -> [a] -> Bool
headsEqual (x:_) (x:_) = True
headsEqual _     _     = False

(The reason why this doesn't work is because Haskell is doing PATTERN MATCHING,
and not variable UNIFICATION. Prolog does unification, so there it would work.
But luckily we don't program in Prolog here.)

The correct way of doing this is to use different variables and then explicitly
check for equality:

> sameElems :: Eq a => (a, a) -> Bool
> sameElems (x, y) = x == y

> headsEqual :: Eq a => [a] -> [a] -> Bool
> headsEqual (x:_) (y:_) = x == y
> headsEqual _     _     = False

=== EXERCISE 1 ===============================================================

Define the following functions using pattern matching.

1.1.
- Define 'headHunter xss' that takes the head of the first list element. If 
  the first element has no head, it takes the head of the second element.
  If the second element has no head, it takes the head of the third element.
  If none of this works, the function returns an error.

  headHunter :: [[a]] -> a

1.2.
- Define 'firstColumn2x2 m' that returns the first column of a 2x2 matrix.
  firstColumn2x2 [[1,2],[3,4]] => [1,3]

  firstColumn2x2 :: [[a]] -> [a]

- Define 'firstColumn m' that returns the first column of a matrix
  of arbitrary size.

  firstColumn :: [[a]] -> [a]
  firstColumn [[1,2,3],[4,5,6],[7,8,9]] => [1,4,7]

- Check what happens if the input is not a valid matrix. Feed an
  invalid matrix like [[2,3], [3], []] to your solution!
  
- Bonus question - can you write a function that checks if a matrix is
  valid or not? ([[a]] -> Bool)


1.3.
- Define 'shoutOutLoud' that repeats three times the initial letter of each
  word in a string.
  shoutOutLoud :: String -> String
  shoutOutLoud "This is Spartaaa!!!" => "TTThis iiis SSSpartaaa!!!"

=== LOCAL DEFINITIONS (WHERE) ================================================

We should avoid situations in which the same value is computed many times over.
In Haskell, we use local definitions for that.

> triangleArea :: Double -> Double -> Double -> Double
> triangleArea a b c = sqrt $ s * (s-a) * (s-b) * (s-c)
>   where s = (a + b + c) / 2

> pairsSumTo100 = [(x,y) | x <- xs, y <- xs, x + y == 100 ]
>   where xs = [1..100]

The scope of 'where' declarations extends over guards:

> tripCost :: Int -> Double -> Double -> String
> tripCost days hotel travel
>   | cost <= 100 = "Extremely cheap vacation"
>   | cost <= 500 = "Cheap vacation"
>   | otherwise   = "Expensive vacation"
>   where cost = hotel * realToFrac days + travel

We can have many 'where' declarations:

> tripCost' :: Int -> Double -> Double -> String
> tripCost' days hotel travel
>   | cost <= 100 = "Extremely cheap vacation"
>   | cost <= 500 = "Cheap vacation"
>   | otherwise   = "Expensive vacation"
>   where hotelCost = hotel * realToFrac days
>         cost      = hotelCost + travel

The scope of a 'where' definition is the clause in which it is defined.

This is no good:

whatNumber 5 = good ++ "5"
whatNumber x = bad ++ show x
  where good = "I like the number " 
        bad  = "I don't like the number "

If a definition needs to be shared among several clauses, you must define it at
the top level so that it becomes visible to all clauses (and other functions as
well).

We can of course also pattern match in 'where' blocks:

> tripCost2 :: Int -> Double -> Double -> String
> tripCost2 days hotel travel
>   | cost <= i = "Extremely cheap vacation"
>   | cost <= j = "Cheap vacation"
>   | otherwise = "Expensive vacation"
>   where cost  = hotel * realToFrac days + travel
>         (i,j) = (100,500)

But this should not be taken too far. This is perhaps too much:

> tripCost3 :: Int -> Double -> Double -> String
> tripCost3 days hotel travel
>   | exCheap   = "Extremely cheap vacation"
>   | cheap     = "Cheap vacation"
>   | otherwise = "Expensive vacation"
>   where cost    = hotel * realToFrac days + travel
>         (i,j)   = (100,500)
>         exCheap = cost <= i
>         cheap   = cost <= j

Another example of a bad style:

> initials :: String -> String -> String
> initials first last = f : ". " ++ l : "."
>   where (f:_) = first
>         (l:_) = last

Do this instead:

> initials' (f:_) (l:_) = f : ". " ++ l : "."

How can the above definition be extended to cover the cases when the first/last
name is an empty string?

Within a 'where' block we can also define functions:

> middleOne :: (a,b,c) -> (d,e,f) -> (b,e)
> middleOne x y = (middle x, middle y)
>   where middle (_, w ,_) = w

And, as you would have expected, these locally-defined functions can also use
pattern matching:

> middleOne' x y = (middle x,middle y)
>   where middle (0,0,0) = 1
>         middle (_,w,_) = w

The question that's probably tormenting you now is: when should I use 'where',
and when should I use global definitions instead?

Good reasons FOR using 'where':
* Use 'where' if an expression is being repeated locally.
* Use 'where' if this makes your code more comprehensive.
* Use 'where' as a sort of documentation (assuming that the variables/functions
  have meaningful names).

Reasons for NOT using 'where':
* If a value/function is used also in other functions.
* If 'where' blocks nest in more than two levels.

=== EXERCISE 2 ===============================================================

Solve the following exercises using pattern matching and local definitions,
wherever appropriate.

2.1.
- Define 'pad' that pads the shorter of two the strings with trailing spaces 
  and returns both strings capitalized.

  Example:
  pad :: String -> String -> (String, String)
  pad "elephant" "cat" => ("Elephant", "Cat     ")
  pad "dog" "armadillo" => ("Dog      ","Armadillo")

2.2.
- Define 'quartiles xs' that returns the quartiles (q1,q2,q3) of a given list.
  The quartiles are elements at the first, second, and third quarter of a list
  sorted in ascending order. (You can use the built-int 'splitAt' function and
  the 'median' function defined below.)

  Example:

  quartiles :: [Int] -> (Double,Double,Double)
  quartiles [3,1,2,4,5,6,8,0,7] => (1.5, 4.0, 6.5)

  e.g.

  [3,1,2,4,5,6,8,0,7] --sort--> [0,1,2,3,4,5,6,7,8]  --quartiles--> [1.5,4,6.5]
                                  |    |    |
                                 1.5   4   6.5


> median :: (Integral a, Fractional b) => [a] -> b
> median [] = error "median: Empty list"
> median xs 
>   | odd l     = realToFrac $ ys !! h
>   | otherwise = realToFrac (ys !! h + ys !! (h-1)) / 2
>   where l  = length xs
>         h  = l `div` 2
>         ys = sort xs


=== LET ======================================================================

A 'let-in' statement is similar to a 'where' block. The differences are:

* 'where' is declared at the end of a function and is visible only to the last
   clause, including the guards
* 'let' can be declared everywhere and is by itself an expression

> triangleArea' :: Double -> Double -> Double -> Double
> triangleArea' a b c = 
>   let s = (a + b + c) / 2 in sqrt $ s * (s-a) * (s-b) * (s-c)

> foo2 x =
>   let a = x
>       b = x * 2
>       c = b + 1 
>   in a + b + c

Or shorter:

> foo3 x = let (a, b, c) = (x, x*2, x*2+1) in a + b + c

Use 'let' when you need a "very local" definition that is not used at several
places within a function.

Note that 'let' has actually nothing to do with 'let' in REPL, although
in both cases they serve the same purpose: assigning values to a variable.

'let' (without the 'in' part) can also be used within a list comprehension:

> sumLists :: [Int] -> [Int] -> [Int]
> sumLists xs ys = [s | (x, y) <- zip xs ys, let s = x + y, s >= 0]

Btw., note that 'where' declarations are not visible within a list comprehension:

sumLists' :: [Int] -> [Int] -> [Int]
sumLists' xs ys = [s | (x,y) <- zip xs ys, s >= 0]
  where s = x+y

Instead of using 'let', you can use the following trick:

> sumLists' :: [Int] -> [Int] -> [Int]
> sumLists' xs ys = [s | (x,y) <- zip xs ys, s <- [x+y], s >= 0]

One more example:

> bigTriangles :: [((Double, Double, Double), Double)]
> bigTriangles = [ ((x,y,z), a) | 
>   x <- ns, y <- ns, z <- ns, 
>   let a = triangleArea x y z, x + y >= z, x < y, a >= 100]
>   where ns = [1..100]

=== EXERCISE 3 ===============================================================

Redo Exercise 2 using 'let' instead of 'where'.

=== CASE =====================================================================

A 'case' statement is quite powerful as it enables pattern matching anywhere in
the code. A 'case' statement is an expression itself, much like 'if-then-else'
and 'let-in' expressions.

> magicNumber4 :: Int -> String
> magicNumber4 x = case x of
>   42 -> "Yeah!"
>   _  -> "Nope, try again."

As a matter of fact, pattern matching used in function definition is just
syntactic sugar for a 'case' statement. Otherwise said, every definition of the
form:

  foo pattern1 = def1
  foo pattern2 = def2
  ...

is equivalent to:

  foo = case expression of
    pattern1 -> def1
    pattern2 -> def2
    ...

The difference is that 'case' can be used everywhere (inside another
expression):

> describeList2 :: [a] -> String
> describeList2 xs =
>   "This is a list that " ++ (case xs of
>     []  -> "is empty"
>     [x] -> "has one element"
>     xs  -> "has " ++ show (length xs) ) ++ " elements"

=== EXERCISE 4 ===============================================================

4.1.
- Write a function that takes in a pair (a,b) and a list [c] and returns the
  following string:
  "The pair [contains two ones|contains one one|does not contain a single one]
  and the second element of the list is <x>"

  Example:

  describePairAndList :: Show a => (Int, Int) -> [a] -> String
  describePairAndList (1,0) [1,2,3] => "The pair contains one one and the second element of the list is 2"

=== SUMMARY ===================================================================

Let's wrap it up:

* guards are similar to 'if-then-else'
* pattern matching in function definition is similar to 'case'
* 'where' is similar to 'let'

'if-then-else', 'case', and 'let' are expressions by themselves so you can use
them everywhere.

You can combine anything in any way you wish (sky is the limit). Apart from
efficiency, code readability should be your primary objective.

Note: Some tests can be done with pattern matching (e.g., is the list empty?),
but some require Boolean expressions (e.g., is the number less than 1?)

Rule of thumb: use pattern matching and local definitions (more 'where' than
'let') as much as you can.

=== NEXT =====================================================================

Many functions cannot be defined without RECURSION, and it is only with
recursion that Haskell is a Turing-complete language. So, next week we'll look
into recursive functions.
