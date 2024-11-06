import Data.Char
import Data.List
import Data.Tuple

-- Exercise 1

-- 1.1.
takeThree :: [a] -> [a]
takeThree xs = undefined

dropThree :: [a] -> [a]
dropThree xs = undefined

hundredTimes :: a -> [a]
hundredTimes xs = undefined

-- 1.2.
index :: [a] -> [(Int, a)]
index xs = undefined

-- 1.3.
divider :: Int -> String
divider n = undefined

-- Exercise 2

-- 2.1.
applyOnLast :: (a -> b -> c) -> [a] -> [b] -> c
applyOnLast = undefined

lastTwoPlus100 :: (Num a) => [a] -> [a] -> a
lastTwoPlus100 = undefined

-- 2.2.
applyManyTimes :: Int -> (a -> a) -> a -> a
applyManyTimes = undefined

applyTwice' :: (a -> a) -> a -> a
applyTwice' = undefined

-- Exercise 3

-- 3.1.
listifyList :: [a] -> [[a]]
listifyList = undefined

-- 3.2.
cutoff :: Int -> [Int] -> [Int]
cutoff = undefined

-- Exercise 4

-- 4.1.
sumEvenSquares :: [Integer] -> Integer
sumEvenSquares = undefined

-- 4.2.
freq :: (Eq a) => a -> [a] -> Int
freq = undefined

-- 4.3.
freqFilter :: (Eq a) => Int -> [a] -> [a]
freqFilter = undefined

-- Exercise 5

-- 5.1.
withinInterval :: Int -> Int -> [Int] -> [Int]
withinInterval = undefined

-- 5.2.
canonicalizePairs :: (Ord a) => [(a, a)] -> [(a, a)]
canonicalizePairs = undefined

-- 5.3.
applyAndCombine :: (a -> b) -> (a -> c) -> a -> (b, c)
applyAndCombine = undefined
