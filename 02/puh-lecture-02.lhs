University of Zagreb
Faculty of Electrical Engineering and Computing

PROGRAMMING IN HASKELL

Academic Year 2023/2024

LECTURE 2: Lists (cont.) and tuples

v1.1

(c) 2017 Jan Šnajder, 2022 Martin Sosic

==============================================================================

> import Data.Char
> import Data.List


=== How to write haskell during the lecture

- create a new .hs file, e.g. lecture2.hs
- open that file in editor with Haskell support
- run `ghci` in your terminal
  - `:l some/path/lecture2.hs` to load your Haskell script for the first time
  - `:r` to reload the file when you do changes
  - demo: https://discord.com/channels/947985530841337856/1152372711537004576/1161743495103524986

- you can use and run any functions from the file

- tip: "poor man's tests": define helper functions to test your code
  demo: https://discord.com/channels/947985530841337856/1152372711537004576/1161743764168134687

===

=== LISTS RECAP (from the last lecture) ======================================

  head
  |    |--------------|-> tail
  1 -> 2 -> 3 -> 4 -> 5

  list = head : tail

operator :

> _ = 1:[2, 3] == [1, 2, 3]

operator ++

> _ = [1, 2] ++ [3, 4] == [1, 2, 3, 4]

head

> _ = head [1, 2, 3] == 1

complexity?

tail

> _ = tail [1, 2, 3] == [2, 3]

complexity?

init

> _ = init [1, 2, 3] == [1, 2]

complexity?

last

> _ = last [1, 2, 3] == 3

complexity?

take

> _ = take 2 [1, 2, 3] == [1, 2]

drop

> _ = drop 2 [1, 2, 3] == [3]

reverse

> _ = reverse [1, 2] == [2, 1]

string is a list of characters

> _ = ['a', 'b'] == "ab"

repeat

repeat 0 == [0, 0, 0, ..] -- pseudocode!

cycle

cycle [1,2] == [1, 2, 1, 2, 1, 2, ..] -- pseudocode!

replicate

> _ = replicate 5 'a' == "aaaaa"

list intervals

[a..b]

> _ = [1..3] == [1, 2, 3]

[a,b..c]

> _ = [1,3..7] == [1, 3, 5, 7]

[1..] == [1, 2, 3, ...] -- pseudocode!

==============================================================================



=== LISTS (cont.) ============================================================

A list without its first and last element:

> trim l = tail (init l)
> trim' l = init $ tail l


--- Padding: padTo10 ---



> blanks = repeat ' '

> padTo10 s = s ++ take (10 - length s) blanks

(?) Why not:

> padTo10' s = take 10 (s ++ blanks)








Because it won't work for s longer than 10.
---------------




Be careful with this:

> l20 = head [] -- ?

Lists of lists:

> l21 = [[1,2,3],[4,5,6],[7,8,9,10]]
> l22 = ["red","green","blue"]

Again, remember that lists cannot be heterogenous, thus we cannot have
[1,2,[3,4]] nor ["red",'a'].

'concat': Concatenating list of sublists:

> l23 = concat l21

Minimum and maximum of a list:

> m1 = minimum [4, 1, 2, 3]

> m2 = maximum "Haskell for the win!"

Looking up elements from a list:

> e1 = [1,3..100] !! 3 -- ?

> e2 = l21 !! 1 !! 2 -- ?

Our own implementation of 'chr':

> intToChar i = ['A'..] !! (i - 65)

(?) What happens if i < 65?



Let's fix it:

> intToChar' i | i >= 65   = ['A'..] !! (i - 65)
>              | otherwise = error "Index should be at least 65"

Logical operation on lists:

> r1 = and [True,True,False]
> r2 = or [True,True,False]

Removing duplicates with 'nub':

> l24 = nub [1, 2, 3, 1, 1, 2]
> l25 = nub "Give me every letter only once!"

Sorting a list:

> l26 = sort [1,4,5,6,1,2]
> l27 = sort "Alphabet"

Checking list membership: 'elem' and 'notElem':

> hasA xs = 'a' `elem` xs

Function 'null' returns True if the list is empty, otherwise it returns False.

> isEmpty = null l27

We now have three ways at our disposal to check whether a list is empty:
(1) length xs == 0
(2) xs == []
(3) null xs

Which one should you use? You should definitively use (3). Approach (1) won't
work for infinite list. Approach (2) is more restrictive than (3), because it
won't work for all list types (why this is so will be clear after Lecture 3).

=== EXERCISE 1 ===============================================================

1.1.
- Define a function that returns a list without the first three elements and
  last three elements.

1.2.
- Define a function 'initials s1 s2' that takes a person's name and a surname
  as input and returns a string consisting of person's initials.
  initials "James" "Bond" => "J. B."

1.3.
- Define a function 'hasDuplicates' that checks whether a list contains
  duplicate elements (use 'nub') and returns True or False.

=== LIST COMPREHENSIONS ======================================================

> doubles = [x*2 | x <- [1..3]]

> food = [s1 ++ " " ++ s2
>         | s1 <- ["cold", "hot", "fresh"],
>           s2 <- ["cake", "strudel", "salad"]]

> sums1 = [x + y | x <- [1..3], y <- [1..3]]

> sums2 = [x + y | x <- [1..3], y <- [1..3], x < y]

> sums3 = [x + y | x <- [1..3], y <- [1..3], x < y, odd x || even y]

> sums4 = [x * y | x <- [1..2], odd x, y <- [4..5], even y] -- ?

List of sublist lengths:

> lengths xss = [length xs | xs <- xss]

> totalLength xss = sum $ lengths xss  -- NEW: sum!

> exampleListOfLists = [[1..3], [1..5]] -- for testing

Since strings are actually lists of characters, we can do list comprehensions
with strings:

> codes = [ [c1,c2] | c1 <- "abc", c2 <- "123"]

> codes' = [ [c1,c2] | c1 <- ['a', 'b', 'c'], c2 <- ['1', '2', '3']]

> caesarCode text = [succ c | c <- text, c /= ' ']

> onlyDigits text = [c | c <- text, isDigit c] -- NEW: isDigit!

> upperCase text = [toUpper c | c <- text]

=== EXERCISE 2 ===============================================================

2.1
- Define 'doublesFromTo' function that takes two numbers and generates a sequence
  [a*2, (a+1)*2, (a+2)*2, ..., (b-1)*2, b*2] where 'a' is a smaller of two numbers.

2.2.
- Define 'ceasarCode' n xs' so that it:
  1. Converts all characters into lowercase.
  2. Keeps only characters within the ['a'..'z'] interval.
  3. Increases value of each character for n. Example for n == 2: 'a' -> 'c'.
  Example: ceasarCode' 3 "aB10c" == "def"
  Tip: ord, chr, toLower.

==============================================================================

Breaking up a string into tokens:

> someText = "I think we agree John, the past is over." -- For testing.

> ws = words someText -- NEW: words!

Breaking up a string into lines:

> ls = lines "First line\nSecond line" -- NEW: lines!

Concatenating lines into a single string:

> stream = unlines ls -- NEW: unlines!

Filtering words with initial uppercase letter:

> capitalized text = [w | w <- words text, isUpper $ head w]

> capitalize text = unwords [toUpper (head w) : tail w | w <- words text]

Or, more succinctly, using pattern matching:

> capitalize' text = unwords [(toUpper h) : t | (h:t) <- words text]

=== EXERCISE 3 ===============================================================

Tip: consider writing helper functions when appropriate!

3.1.
- Define 'letterCount' that computes the total number of letters in a string,
  thereby ignoring the whitespaces and all words shorter than three letters.
  Example: letterCount "I have 23 ducks in my yard." == 13

3.2
- Redefine 'isPalindrome' so that it's case insensitive and works correctly
  for strings that contain whitespaces (by ignoring whitespace).

3.3.
- Define 'flipp xss' that takes a list of lists,
  reverts each list with odd number of elements,
  and concatenates all of them, but in the reverse order.
  flipp ["water","is","warm"] == "warmisretaw"

     ["water", "is", "warm"]
      --- reverts lists with odd number of elements ---
     ["retaw", "is", "warm"]
      --- reverses it ---
     ["warm", "is", "retaw"]
      --- concatenates ---
     ["warmisretaw"]

=== TUPLES ===================================================================

> pair1 = (1, 2)
> pair2 = ("Vatroslav", "Lisinski")

> triplet1 = (10, 1, 8)
> triplet2 = ("Vatroslav", "Lisinski", 1819)

> e3 = pair1 == (1, 2)

What do we get if we type in 'pair1 == pair2' ?

Assigning values to tuples (pattern matching again):

> (a,b) = (1,2)

Extract of the first and the second element of a tuple, respectively:

> p = fst (5,6)
> q = snd (5,6)

List of pairs:

> pairs = [(1,2),(3,4),(5,6)]

Pairs of numbers from 1 to 100:

> pairsUpTo100 = [(x,y) | x <- [0..100], y <- [0..100]]

Pairs of numbers that sum up to 100:

> pairsSumTo100 = [(x,y) | x <- [0..100], y <- [0..100], x + y == 100 ]

Integer lengths of triangle sides that satisfy the Pythagorean theorem
(Pythagorean triplets):

> pythagoreanTriplets =
>   [(a,b,c) | a <- [1..10], b <- [1..10], c <- [1..10], a^2 + b^2 == c^2]

Can be optimized:

> pythagoreanTriplets' =
>   [(a,b,c) | c <- [1..10], a <- [1..c], b <- [1..a], a^2 + b^2 == c^2]

'zip' function:

> pairs2 = zip [1,2,3] "abc"
> pairs3 = zip [1,2,3,4] "abc"
> pairs4 = zip [1..] "abc"
> pairs5 = zip [1..100] [2..100]

=== EXERCISE 4 ===============================================================

4.1.
- Define 'inCircle r x y' that returns the coordinates of all points within
  the ([-10..10],[-10..10]) interval that fall inside a circle of radius
  'r' with center '(x,y)'.
  TIP: x**2 == x * x
- Redefine the function so that it takes the resolution of the grid as an
  additional argument (resolution is an integer: 1, 2, ...).

4.2.
- Define 'steps xs' that, given a list xs=[x1,x2,..], generates the pairs
  [(x1,x2),(x2,x3),...]. Hint: have a look at 'pairs5'.

==============================================================================

Indexing elements of a list:

> index xs = zip [1..] xs

Filtering every second list element:

> evenElems xs = [snd ix | ix <- index xs, even (fst ix)]

The same thing, but using pattern matching:

> evenElems' xs = [x | (i,x) <- index xs, even i]

Zip3:

> triplets2 = zip3 [0..10] ['A'..] [100..]

=== EXERCISE 5 ===============================================================

5.1.
- Define 'indices y xs' that returns the indices of element 'y' in list 'xs'
  (if 'y' appears multiple times, there will be a number of such indices).
  indices 'a' "alphabet" => [0, 4]

5.2.
- Define 'showLineNumbers s' that prefixes all lines from string 's' with a
  line number.
  showLineNumbers "first line\nsecond line" => "1 first line\n2 second line\n"
  Tip: lines, show

5.3.
- Define 'haveAlignment xs ys' that returns 'True' if 'xs' and 'ys' have
  any identical elements that are aligned (appear at the same position in
  both lists).
- Define 'common xs ys' that returns the aligned subsequences.
  haveAlignment "water" "fire" => True
  common "witer" "fire" => "ie"

=== NEXT =====================================================================

So far we have deliberately avoided talking about types of values and
functions. Because Haskell is a strongly and statically typed language, we
cannot postpone this any longer. In the next lecture, we'll look into types
and type inference system of Haskell.

To prepare, you may (but need not to) read Chapter 3 of LYH:
http://learnyouahaskell.com/types-and-typeclasses
