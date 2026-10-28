import Data.List

-- Exercise 1

takeThree :: [a] -> [a]
takeThree = undefined

dropThree :: [a] -> [a]
dropThree = undefined

hundredTimes :: a -> [a]
hundredTimes = undefined


index :: [a] -> [(Int, a)]
index = undefined

index' :: [a] -> [(a, Int)]
index' = undefined

divider :: Int -> String
divider = undefined



-- Exercise 2

applyOnLast :: (a -> b -> c) -> [a] -> [b] -> c
applyOnLast = undefined

-- helper
addThree x y z = x + y + z

lastTwoPlus100 :: [Integer] -> [Integer] -> Integer
lastTwoPlus100 = undefined


applyManyTimes :: Int -> (a -> a) -> a -> a
applyManyTimes n = undefined

finishSentence :: String -> String
finishSentence = (++ ".")

applyTwice :: (a -> a) -> a -> a
applyTwice = undefined



-- Exercise 3

listifylist :: [a] -> [[a]]
listifylist = undefined


cutoff :: Num a => a -> [a] -> [a]
cutoff m = undefined



-- Exercise 4

sumEvenSquares :: [Integer] -> Integer
sumEvenSquares = undefined


freq :: Eq a => a -> [a] -> Int
freq x = undefined


freqFilter :: Eq a => Int -> [a] -> [a]
freqFilter n = undefined



-- Exercise 5

withinInterval :: Ord a => a -> a -> [a] -> [a]
withinInterval n m = undefined


canonicalizePairs :: Ord a => [(a,a)] -> [(a,a)]
canonicalizePairs = undefined


applyAndCombine :: (a -> b) -> (a -> c) -> a -> (b, c)
applyAndCombine = undefined
