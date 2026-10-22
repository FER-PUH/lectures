module Solutions where

import Data.Char
import Data.List

-- === EXERCISE 1 ===============================================================

-- Define the following functions using pattern matching.

-- 1.1.
-- - Define 'headHunter xss' that takes the head of the first list element. If
--   the first element has no head, it takes the head of the second element.
--   If the second element has no head, it takes the head of the third element.
--   If none of this works, the function returns an error.
headHunter :: [[a]] -> a
headHunter [] = error "Empty list"
headHunter ((x : _) : _) = x
headHunter (_ : (x : _) : _) = x
headHunter (_ : _ : (x : _) : _) = x
headHunter _ = error "No head to behead"

-- 1.2.
-- - Define 'firstColumn2x2 m' that returns the first column of a 2x2 matrix.
--   firstColumn2x2 [[1,2],[3,4]] => [1,3]
firstColumn2x2 :: [[a]] -> [a]
firstColumn2x2 [x1 : _, x2 : _] = [x1, x2]


firstColumn2x2' [[a,_],[c,_]] = [a,c]
firstColumn2x2' _ = error "Not a 2x2"
-- - Define 'firstColumn m' that returns the first column of a matrix
--   of arbitrary size.
--   firstColumn [[1,2,3],[4,5,6],[7,8,9]] => [1,4,7]
-- - Check what happens if the input is not a valid matrix. Feed an
--   invalid matrix like [[2,3], [3], []] to your solution!
firstColumn :: [[a]] -> [a]
firstColumn m = [h | (h : _) <- m]

-- - Bonus question - can you write a function that checks if a matrix is
--   valid or not? ([[a]] -> Bool)

isValid :: [[a]] -> Bool
isValid m = (1 ==) $ length $ nub $ [length r | r <- m]

-- 1.3.
-- - Define 'shoutOutLoud' that repeats three times the initial letter of each
--   word in a string.
--   shoutOutLoud :: String -> String
--   shoutOutLoud "This is Spartaaa!!!" => "TTThis iiis SSSpartaaa!!!"
shoutOutLoud :: String -> String
shoutOutLoud ws = unwords [c : c : c : cs | (c : cs) <- words ws]

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
pad w1 w2
  | l1 > l2 = capitalize (w1, padTo l1 w2)
  | otherwise = capitalize (padTo l2 w1, w2)
  where
    l1 = length w1
    l2 = length w2
    padTo n w = take n $ w ++ repeat ' '

    capitalize :: (String, String) -> (String, String)
    capitalize (x, y) = (capitalize' x, capitalize' y)

    capitalize' :: String -> String
    capitalize' [] = []
    capitalize' (c : cs) = toUpper c : cs

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
quartiles xs = (q1,q2,q3)
  where
      q1 = median firstHalf
      q2 = median sortedList
      q3 = median secondHalf

      -- Solution working with even length lists only:
      -- (firstHalf, secondHalf) = splitAt halfLength sortedList

      -- Solution working with odd and even length lists:
      (firstHalf, secondHalf) = (take halfLength sortedList, take halfLength (reverse sortedList))
      sortedList = sort xs
      halfLength = length xs `div` 2

median :: (Integral a, Fractional b) => [a] -> b
median [] = error "median: Empty list"
median xs
  | odd l = realToFrac $ ys !! h
  | otherwise = realToFrac (ys !! h + ys !! (h - 1)) / 2
  where
    l = length xs
    h = l `div` 2
    ys = sort xs

-- === EXERCISE 4 ===============================================================

-- 4.1.
-- - Write a function that takes in a pair (a,b) and a list [c] and returns the
--   following string:
--   "The pair [contains two ones|contains one one|does not contain a single one]
--   and the second element of the list is <x>"
showPairAndList :: Show a => (Int, Int) -> [a] -> String
showPairAndList pair (_ : e2 : _) =
  "The pair "
    ++ ( case pair of
           (1, 1) -> "contains two ones"
           (a, b) | a == 1 || b == 1 -> "contains one one"
           (_, _) -> "does not contain a single one"
       )
    ++ " and the second element of the list is "
    ++ show e2
showPairAndList _ _ = error "The list must contain at least two elements"
