University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2022/2023

LECTURE 8: Higher-order functions 2

v1.4

(c) 2017 Jan Šnajder
(c) 2022, 2023, 2024, 2025 Filip Sodić
(c) 2026 Miho Hren

===============================================================================

> import Data.Char
> import Prelude hiding (foldr,foldl,foldl',flip,curry,uncurry)
> import Data.List hiding (foldr,foldl,foldl')
> import Control.Monad
> import Data.Ord (comparing)

=== RECAP =====================================================================

Last week we discussed HOFs and how we can use them to define functional idioms
'map' and 'filter'. Today we'll explore other functional patterns, including
function composition and folds.

=== COMPOSITION ===============================================================

Composition of functions: (f . g)(x) = f (g x)

The '.' operator is defined as follows:

  (.) :: (b -> c) -> (a -> b) -> a -> c
  f . g = \x -> f (g x)

E.g., the successor of the first element of a pair:

> succOfFst :: (Int, Int) -> Int
> succOfFst p = (succ . fst) p

If we apply eta-reduction, this boils down to:

> succOfFst' :: (Int, Int) -> Int
> succOfFst' = succ . fst

Recall the 'applyTwice' function:

> applyTwice :: (a -> a) -> a -> a
> applyTwice f x = f (f x)

Written as a composition of functions:

> applyTwice' :: (a -> a) -> a -> a
> applyTwice' f = f . f

Recall the 'caesarCode' function. Let's look at three ways how to define it:

> caesarCode1 :: String -> String
> caesarCode1 s = [succ c | c <- s, c /= ' ']

> caesarCode2 :: String -> String
> caesarCode2 s = map succ $ filter (/=' ') s

> caesarCode3 :: String -> String
> caesarCode3 = map succ . filter (/=' ')

We can also define a chain of compositions. For instance,

> readBackwards :: String -> String
> readBackwards = unwords . reverse . words

> backwards = readBackwards "dogs chase cats"

Keep in mind that in such a chain the functions are applied from right to left,
because the composition operator is right-associative, meaning that

  (f . g . h)(x)

is equivalent to

  f (g (h x))

What about composing functions which don't have the same number of parameters?
This is not a problem as long as their types match.
The output type of the inner function and the input type of the outer function
must match. We can often accomplish this by partially applying functions
in the composition chain, as in the following example:

> tokenize :: String -> [String]
> tokenize = filter (\w -> length w >= 3) . words . map toUpper

> tokens1 = tokenize "These are my tokens"

Sections are very useful here:

> tokenize' = filter ((>=3) . length) . words . map toUpper

Notice how we avoided mentioning any function parameters (the variables).
This style of programming is called POINT-FREE STYLE.

When we say POINT, we don't mean the '.' symbol of composition. On the
contrary, pointfree programming style abounds with full stops!

Point-free is considered good programming style because it allows us to focus
at functional composition (higher level) rather data shuffling (lower level).
Read more about it here: http://www.haskell.org/haskellwiki/Pointfree

As a general rule of thumb, use point-free style when a function has
a simple single parameter.  With multiple or complicated parameters,
we must not sacrifice readability and documentation in favor of
point-free style. 

Don't confuse the composition operator with the application operator ('$'). The '$'
operator applies the expression on the left to the expression on the right. It
has the lowest precedence and is right-associative:

  ($) :: (a -> b) -> a -> b
  f $ x = f x

=== EXERCISE 1 ================================================================

Define the following functions using composition and/or pointfree style (you
may of course use local definitions):

1.1.
- Define 'sumEven' that adds up elements occurring at even (incl. zero)
  positions in a list.
  sumEven :: Num a => [a] -> a
  sumEven [1..10] => 25
  sumEven [-1, 3, -2, -4, 3] => 0

1.2.
- Define 'applyAll' that takes a value and an array of functions. It applies
  all functions in the array to the given value:
  element:
  applyAll :: a -> [a -> b] -> [b]
  applyAll 10 [succ, (+5), (^2)] => [11, 15, 100]
  applyAll "123" [length, read] => [3, 123]

=== FUNCTIONS USEFUL FOR COMPOSITION ==========================================

It is always wise to place the argument you're transforming (the "subject"
of the operation) as the last argument, as it better aligns with most use cases.
Read more about it here:
  - http://wiki.haskell.org/Parameter_order
  - https://stackoverflow.com/a/31738041

Designing functions this way (configuration first, subject last) increases the
chances that their partial application yields something useful.

Think about what's a more common use case:
 1. Filtering different data sets according to a fixed criteria (e.g., removing
 swear words from different pieces of text).
 2. Filtering a fixed dataset according to changing criteria (e.g., filtering
 the same specific list of words multiple times).

It's usually the first one. Here are some more examples:

> removeSpaces :: String -> String
> removeSpaces = filter (/=' ')

You can notice the same trend in other list functions: `take`, `drop`,
`map`, `repeat`, ...

That said, we still sometimes encounter functions that don't neatly fit what
we're trying to do. When this happens, we use helper functions:

> flip :: (a -> b -> c) -> b -> a -> c
> flip f x y = f y x

> zipped = zip [1,2,3] ['a', 'b', 'c']
> flipped = flip zip [1,2,3] ['a', 'b', 'c']

> getCommonElements :: Eq a => [a] -> [a] -> [a]
> getCommonElements l1 l2 = filter (flip elem l1) l2

Again, sections are very useful here:

> getCommonElements' :: Eq a => [a] -> [a] -> [a]
> getCommonElements' l1 l2 = filter (`elem` l1) l2

Dealing with tuples is another common composition hurdle.
What do we do if we have a normal (curried) function, but we want to map over
an array of tuples?

The 'curry' function takes a function that expects a pair and returns a
function in curried form:

> curry :: ((a, b) -> c) -> a -> b -> c
> curry f x y = f (x, y)

> addPair :: (Int, Int) -> Int
> addPair (x, y) = x + y

> result1 = addPair (3, 5)
> result2 = curry addPair 3 5 

Function 'uncurry' works the other way around:

> uncurry :: (a -> b -> c) -> (a, b) -> c
> uncurry f (x,y) = f x y

> add :: Int -> Int -> Int
> add x y = x + y

> result3 = add 1 5
> result4 = uncurry add (1, 5)

This function is useful in combination with 'zip':

> pairedMax :: Ord b => [b] -> [b] -> [b]
> pairedMax xs ys = map (uncurry max) $ zip xs ys

> result5 = pairedMax [2,3,4,5] [5,4,3,2]

=== REMARKS ===================================================================

If a function takes more than a single argument, in a chain of compositions all
arguments but one must be fixed (i.e., the function must be applied to all its
arguments except the last one).

FIX THIS

This is no good:

  maxPairedSum = maximum . map (uncurry (+)) . zip

It should be this instead:

> maxPairedSum xs = maximum . map (uncurry (+)) . zip xs

Or this:

> maxPairedSum' xs ys = maximum . map (uncurry (+)) $ zip xs ys

=== EXERCISE 2 ================================================================

Use composition helper functions to solve these exercises without using 
lambdas.

2.1.
- Define `joinNames xs` that takes a list of pairs, each containing a first and
  a last name. The function must join the names together without spaces:

  joinNames :: [(String, String)] -> [String]
  joinNames [("Tony", "Soprano"), ("Walter", "White"), ("Don", "Draper")]
    => ["TonySoprano","WalterWhite","DonDraper"]

2.2.
- Define 'maxDiff xs' that returns the maximum difference between
  consecutive elements in the list 'xs'.

  maxDiff :: [Int] -> Int
  maxDiff [1, 6, 3, 5, 1] => 4 (diff array is [-5,3,-2,4])

  Hint: zip, tail, uncurry


=== USEFUL HIGHER-ORDER FUNCTIONS =============================================

There's a whole bunch of useful higher order functions from 'Data.List':

  zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]

  takeWhile :: (a -> Bool) -> [a] -> [a]

  dropWhile :: (a -> Bool) -> [a] -> [a]

  break :: (a -> Bool) -> [a] -> ([a], [a])

  partition :: (a -> Bool) -> [a] -> ([a], [a])

  any :: (a -> Bool) -> [a] -> Bool

  all :: (a -> Bool) -> [a] -> Bool

  findIndices :: (a -> Bool) -> [a] -> [Int]

  sortBy :: (a -> a -> Ordering) -> [a] -> [a]

  groupBy :: (a -> a -> Bool) -> [a] -> [[a]]

  deleteBy :: (a -> a -> Bool) -> a -> [a] -> [a]

  maximumBy :: (a -> a -> Ordering) -> [a] -> a

  minimumBy :: (a -> a -> Ordering) -> [a] -> a

  nubBy :: (a -> a -> Bool) -> [a] -> [a]

From 'Data.Ord':

  comparing :: Ord a => (b -> a) -> b -> b -> Ordering

From 'Data.Function':

  on :: (b -> b -> c) -> (a -> b) -> a -> a -> c

=== EXERCISE 3 ================================================================

Use the above mentioned functions (and Hoogle) to solve the following
exercises:

3.1.
- Define 'isTitleCased' that checks whether every word in a string is
  capitalized.

  isTitleCased :: String -> Bool
  isTitleCased "University Of Zagreb" => True

  Hint: all

3.2.
- Define 'getFilename' that extracts the the name of the file from a file path.

  getFilename :: String -> String
  getFilename "/etc/init/cron.conf" => "cron.conf"
  getFilename "~/Documents/diary.txt" => "diary.txt"

  Hints:
    - Focus on readability, not on efficency. 
    - takeWhile, reverse

=== FOLD ======================================================================

We've seen that we can use 'map' and 'filter' to abstract common patterns.
Instead of writing a recursive function from scratch every time, we can
use 'map' and 'filter' to make the code more idiomatic and hence
more comprehensible and succinct.

Can we define ALL recursive functions using only 'map' and 'filter'?

For example, this one:

> sum' :: Num a => [a] -> a
> sum' []     = 0
> sum' (x:xs) = x + sum' xs

Or this one:

> length' :: [a] -> Int
> length' []     = 0
> length' (_:xs) = 1 + length' xs

Or perhaps this one:

> concat' :: [[a]] -> [a]
> concat' [] = []
> concat' (xs:xss) = xs ++ concat' xss

We cannot. We need another functional pattern for this: the RIGHT FOLD.
This pattern is abstracted by the 'foldr' function:

> foldr :: (a -> b -> b) -> b -> [a] -> b
> foldr f z []     = z
> foldr f z (x:xs) = x `f` (foldr f z xs)

The first argument is a combining function, the second argument is
the initial value, and the third argument is a list.
The combining function is of the type

  f :: a -> b -> b

where the first argument is the list element that is currently being processed,
and the second argument is the value calculated so far.

The expression

  foldr f z [x1, x2, x3, x4, x5]

evaluates to

  f x1 (f x2 (f x3 (f x4 (f x5 z)))

or in infix form

  x1 `f` (x2 `f` (x3 `f` (x4 `f` (x5 `f` z)))

Note that the evaluation first goes all the way down to the end of the list,
where the LAST element of the list is combined with the initial value 'z',
and only then is the result built back up, as in standard recursion.

Now, how can we define 'sum', 'length', and 'concat' using 'foldr'?

> sum2 = foldr (\x r -> x + r) 0

> length2 = foldr (\_ r -> 1 + r) 0

> concat2 = foldr (\xs r -> xs ++ r) []

Reminder: do not use lambdas unless you must:

> sum3 = foldr (+) 0

> length3 = foldr (const (+1)) 0

> concat3 = foldr (++) []

Remember, `const` is a function that always returns its first argument:

const x y = x


What do the following definitions do?

> foo1 = foldr (:) []

> foo2 = foldr (++) []

> foo3 = foldr max 0

> foo4 f = foldr (\x ys -> f x : ys) []

> foo5 p = foldr (\x ys -> if p x then x : ys else ys) []

We see that 'foo4' is actually 'map', while 'foo5' is filter. Therefore, we can
use 'foldr' to define 'map' and 'filter'. But the converse does not hold: FOLD
is a more general functional pattern than MAP and FILTER.


Recall the 'maximum' function:

> maximum1 :: Ord a => [a] -> a
> maximum1 [x]    = x
> maximum1 (x:xs) = x `max` maximum1 xs

How can we define this function using 'foldr'?

> maximum2 (x:xs) = foldr max x xs

In situations like this one, when the initial combining element is the first
element of the list, we can use the built-in 'foldr1' function:

  foldr1' :: (a -> a -> a) -> [a] -> a
  foldr1' f (x:xs) = foldr f x xs

We can now define:

> maximum3 :: Ord a => [a] -> a
> maximum3 = foldr1 max


The other form of recursion that we considered is the one that uses an accumulator
and builds the solution immediately as it recurses down (i.e., tail recursion).
We've already explained how we can save memory by using tail-recursive functions,
assuming we make them strict.

Recall the 'sum' function:

> sum4 :: Num a => [a] -> a
> sum4 xs = sum 0 xs
>   where sum acc []     = acc
>         sum acc (x:xs) = sum (acc + x) xs

Or the 'maximum' function:

> maximum4 :: (Ord a) => [a] -> a
> maximum4 (x:xs) = maximum x xs
>   where maximum acc     [] = acc
>         maximum acc (x:xs) = maximum (max acc x) xs

This recursive pattern is called LEFT FOLD. It is abstracted by the 'foldl'
function:

> foldl :: (a -> b -> a) -> a -> [b] -> a
> foldl f z []    = z
> foldl f z (x:xs) = foldl f (f z x) xs

Similar as with 'foldr', the first argument is the combining function,
the second is the initial value, while the third one is the list to fold over.
The combining function is of the type:

  f :: a -> b -> a

where the first argument is the accumulator, while the second argument is the
element being processed (in contrast to the 'foldr' combining function).
The reverse order of arguments is intentional and highlights fold direction.

The expression

  foldl f z [x1,x2,x3,x4,x5]

evaluates to

  f (f (f (f (f z x1) x2) x3) x4) x5)


Note that the evaluation starts from the beginning of the list (from the left)
and that the result is built along the way.

> sum5 = foldl (+) 0

> length5 = foldl (\a _ -> a + 1) 0

Similarly as with right fold, where we had 'foldr1' at our disposal, here we
can use 'foldl1'. E.g.:

> maximum5 :: Ord a => [a] -> a
> maximum5 = foldl1 max


Unfortunately, 'foldl' is not strict and thus suffers from the same issue as
all non-strict tail-recursive functions. In other words, It's a great fit for
some problems (like reversing lists) but does not save any memory when
performing "real" reductions (e.g., sum, product, max, etc.).
We therefore need a way to make it strict. Fortunately, the function
foldl' (available in Data.List, note the apostrophe) does exactly that:

> foldl' :: (b -> a -> b) -> b -> [a] -> b
> foldl' f z []     = z
> foldl' f z (x:xs) = seq z' $ foldl' f z' xs
>   where z' = z `f` x

This expression eats up a lot of memory before reducing to the final value:

> sumNonStrict = foldl (+) 0 [1..10000000]

This expression only takes up as much memory as it needs to hold the final
value:

> sumStrict = foldl' (+) 0 [1..10000000]

Finally, there is also foldl1', a strict left fold that starts with the first
element of the given list:

> sumStrict1 = foldl1' (+) [1..10000000]

=== CHOOSING THE CORRECT FOLD =================================================

WHICH FOLD IS THE BEST? This question is equivalent to "is accumulator-style
recursion better than standard recursion?".

As we've learned in Lecture 6:

    - When space complexity is an issue and the result depends on the entire
      input structure (e.g., sum, max, product), we should choose strict tail
      recursion (==accumulator-style), which means foldl'.

    - When the result doesn't depend on the entire input structure and we wish
      to consume it lazily (e.g., map, filter, concat), we should choose
      guarded recursion (==standard recursion), which means 'foldr'.

What about the non-strict 'foldl'? This function, like non-strict tail
recursion in general, is almost never the right choice. It's only useful in
rare cases when the combining function is lazy in its first argument and we
want to rely on said property.

Let's look at an example when we should use foldr.

With 'map' function we want to be able to consume the output lazily, hence we
would define it using the 'foldr' function:

> mapR f = foldr (\x acc -> f x : acc) []

We might give it a try with the 'foldl' version (we could also be using the
strict 'foldl'', it wouldn't make a difference):

> mapL f = foldl (\acc x -> acc ++ [f x]) []

One problem with this definition is its time complexity. The (++) operation is
O(n), so the total time complexity of 'mapL' is O(n^2), which is unacceptable.
Try out the following:

> xs1 = mapR (+1) [1..1000000]
> xs2 = mapL (+1) [1..1000000]

Another problem is that we cannot consume the result of 'mapL' lazily. As a
consequence, 'mapL' will hang on infinite lists.
Try out the following:

> xs3 = take 3 $ mapR (+1) [0..]
> xs4 = take 3 $ mapL (+1) [0..]

The first expression will evaluate just fine. For the second one, however, the
evaluation will never terminate. To understand why this happens, let's look at
how these expressions are evaluated.

The first expression:

take 3 $ mapR (+1) [0,1,2..] =>
take 3 $ foldr (\x acc -> x+1 : acc) [] [0,1,2..] =>
take 3 $ 1 : foldr (\x acc -> x+1 : acc) [] [1,2,3..] =>
1 : take 2 $ foldr (\x acc -> x+1 : acc) [] [1,2,3..] =>
1 : take 2 $ 2 : foldr (\x acc -> x+1 : acc) [] [2,3,4..] =>
1 : 2 : take 1 $ foldr (\x acc -> x+1 : acc) [] [2,3,4..] =>
1 : 2 : take 1 $ 3 : foldr (\x acc -> x+1 : acc) [] [3,4,5..] =>
1 : 2 : 3 : take 0 $ foldr (\x acc -> x+1 : acc) [] [3,4,5..] =>
1 : 2 : 3 : []

The second expression:

take 3 $ mapL (+1) [0,1,2..] =>
take 3 $ foldl (\acc x -> acc ++ [x+1]) [] [0,1,2..] =>
take 3 $ foldl (\acc x -> acc ++ [x+1]) ([]++[1]) [1,2,3..] =>
take 3 $ foldl (\acc x -> acc ++ [x+1]) ([1]++[2]) [2,3,4..] =>
take 3 $ foldl (\acc x -> acc ++ [x+1]) ([1,2]++[3]) [3,4,5..] => ...

'foldl' builds up the result in the accumulator and returns it only after the
list is empty. Because the list is infinite, this will never happen.

In conclusion, if we want the function to generate the result lazily (and work
on infinite lists), we must use 'foldr' instead of 'foldl'. This is because
'foldr' will start to process the list right away (using guarded recursion),
while 'foldl' must first reach the end of the list before it can return the
result (even when we're using its strict variant, 'foldl'').

  foldr f z (x:xs) = x `f` (foldr f z xs)

  foldl f z (x:xs) = foldl f (f z x) xs

OPTIONAL: Read more about folds and their differences:
  - https://wiki.haskell.org/Foldr_Foldl_Foldl'
  - https://stackoverflow.com/questions/14938584/haskell-foldl-poor-performance-with

=== EXERCISE 4 ================================================================

You have three folds at your disposal (foldr and foldr1, foldl and foldl1,
foldl' and foldl1'). Choose wisely!

4.1.
- Choose the correct fold to implement a function that checks whether
  the element is in a list (same behaviour as `elem` from Prelude).
  Which fold is the best fit and why? Hint: test it on large and inifite lists.
  myElem :: Eq a => a -> [a] -> Bool

4.2.
- Choose the correct fold to implement:
  myReverse :: [a] -> [a]
  Which fold is the best fit and why? Try calling your function on a large
  lists.

4.3.
- Choose the correct fold to implement the function 'sumEven' from problem 1.2.
  Which fold is the best fit and why?
  sumEven' :: Num a => [a] -> a
  sumEven' [1..10] => 25

== NEXT =======================================================================

Up to this point, we've only been working with Haskell's built-in types (e.g.,
integers, doubles, lists, tuples...). Next time we'll start defining our own
custom data types. They'll bring us a step closer to solving real-world
problems and demonstrate serveral other reasons that make Haskell's type system
so powerful.

=== EXTRA EXERCISES ===========================================================


1.4.
- Define 'filterWords words string' that removes from string 'string' all words
  contained in the list 'words'.
  filterWords :: [String] -> String -> String
  filterWords ["the", "over"] "the quick brown fox jumps over the lazy dog"
      => "quick brown fox jumps lazy dog"

1.5
- Define 'studentsPassed' that takes as input a list [(FullName, Score)] and
  returns the names of all students who scored at least 50% of the maximum
  score.
  studentsPassed :: [(String, Int)] -> [String]
  studentsPassed [("Tommy", 90), ("Mark", 42), ("Lisa", 48)]
    => ["Tommy","Lisa"]

1.5.
- Define `clamp minValue maxValue xs` that clamps a list of values between the
  given range:
  clamp:: (Ord a, Num a) => a -> a -> [a] -> [a]
  clamp 3 7 [0..10] => [3, 3, 3, 4, 5, 6, 7, 7, 7, 7]

1.6.
- Define 'initials3 delimiter pred str' that takes a string 'str' and
  turns it into a string of initials. The function is similar to 'initials2'
  but additionally delimits the initials with string 'delimiter' and discards
  the initials of words that don't satisfy the predicate 'pred'.
  initials3 :: String -> (String -> Bool) -> String -> String
  initials3 "." (/="that") "a company that makes everything" => "A.C.M.E."

2.3.
- Define `applyPairs` that takes a list of tuples, each containing a function
  (first element) and its argument (second element) and returns a list of
  results it got by applying the functions to arguments:

  applyPairs :: [(a -> b, a)] -> [b]
  applyPairs [((^3), 2), ((*2), 3), ((succ . succ), 1)] => [8,6,3]

2.3.
- Define the "pipe" operator that behaves like a shell pipe in bash (takes a
  value from the left and pipes it to the function on the right):
  It is left-associative by default, so no need to worry about that.

  Examples for testing:

  -- A simple one:
  "Marko" |> head => 'M'

  -- Counting the words in a sentence:
  "I am piping stuff like a pro!" |> words |> length => 7

  -- Finding the sum of all odd squares of of numbers from 1 to 5:
  [1..5] |> map (^2) |> filter odd |> sum  => 35

3.3.
- Define 'sortPairs' that sorts the list of pairs in ascending order with
  respect to the second element of a pair. Choose the most general type
  signature.

3.4. -- Extra
- Define 'maxElemIndices' that returns the indices of the maximum element in a
  list. Return "empty list" error if the list is empty.

  maxElemIndices :: Ord a => [a] -> [Int]
  maxElemIndices [1, 3, 4, 1, 3, 4] => [2, 5]

4.4.
- Chose the correct fold to imlement:
  maxUnzip :: (Ord a, Ord b) => [(a, b)] -> (a, b)
  It returns the maximum element at first position in a pair and maximum
  element at second position in the pair. In other words, the function should
  be equivalent to:
    maxUnzip zs = (maximum xs, maximum ys)
      where (xs,ys) = unzip zs
  Return "empty list" error if the list is empty.
