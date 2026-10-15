module Solutions where

import Data.Char (toUpper)
import Data.List (sort)

-- === EXERCISE 1 ===============================================================

-- Define the following functions using pattern matching.

-- 1.1.
-- - Define 'headHunter xss' that takes the head of the first list element. If
--   the first element has no head, it takes the head of the second element.
--   If the second element has no head, it takes the head of the third element.
--   If none of this works, the function returns an error.
headHunter :: [[a]] -> a
headHunter [] = undefined

-- 1.2.
-- - Define 'firstColumn2x2 m' that returns the first column of a 2x2 matrix.
--   firstColumn2x2 [[1,2],[3,4]] => [1,3]
firstColumn2x2 :: [[a]] -> [a]
firstColumn2x2 = undefined

-- - Define 'firstColumn m' that returns the first column of a matrix
--   of arbitrary size.
--   firstColumn [[1,2,3],[4,5,6],[7,8,9]] => [1,4,7]
-- - Check what happens if the input is not a valid matrix. Feed an
--   invalid matrix like [[2,3], [3], []] to your solution!
firstColumn :: [[a]] -> [a]
firstColumn = undefined

-- - Bonus question - can you write a function that checks if a matrix is
--   valid or not? ([[a]] -> Bool)

-- 1.3.
-- - Define 'shoutOutLoud' that repeats three times the initial letter of each
--   word in a string.
--   shoutOutLoud :: String -> String
--   shoutOutLoud "This is Spartaaa!!!" => "TTThis iiis SSSpartaaa!!!"
shoutOutLoud :: String -> String
shoutOutLoud = undefined

-- === EXERCISE 2 ===============================================================

-- Solve the following exercises using pattern matching and local definitions,
-- wherever appropriate.

-- 2.1.
-- - Define 'pad' that pads the shorter of two the strings with trailing spaces
--   and returns both strings capitalized.
--   Example:
--   pad :: String -> String -> (String, String)
--   pad "elephant" "cat" => ("Elephant", "Cat     ")
--   pad "dog" "armadillo" => ("Dog      ","Armadillo")
pad :: String -> String -> (String, String)
pad = undefined

-- 2.2.
-- - Define 'quartiles xs' that returns the quartiles (q1,q2,q3) of a given list.
--   The quartiles are elements at the first, second, and third quarter of a list
--   sorted in ascending order. (You can use the built-int 'splitAt' function and
--   the 'median' function defined below.)
--   Example:
--   quartiles :: [Int] -> (Double,Double,Double)
--   quartiles [3,1,2,4,5,6,8,0,7] => (1.5, 4.0, 6.5)
--   e.g.
--   [3,1,2,4,5,6,8,0,7] --sort--> [0,1,2,3,4,5,6,7,8]  --quartiles--> (1.5,4,6.5)
--                                   |    |    |
--                                  1.5   4   6.5
quartiles :: [Int] -> (Double, Double, Double)
quartiles = undefined

median :: (Integral a, Fractional b) => [a] -> b
median = undefined

-- === EXERCISE 4 ===============================================================

-- 4.1.
-- - Write a function that takes in a pair (a,b) and a list [c] and returns the
--   following string:
--   "The pair [contains two ones|contains one one|does not contain a single one]
--   and the second element of the list is <x>"
showPairAndList :: (Show a) => (Int, Int) -> [a] -> String
showPairAndList = undefined
