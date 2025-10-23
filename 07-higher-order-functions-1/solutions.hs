import Data.List

-- Exercise 1

-- 1.1.
takeThree :: [a] -> [a]
takeThree = take 3

dropThree :: [a] -> [a]
dropThree = drop 3

hundredTimes :: a -> [a]
hundredTimes = replicate 100

-- 1.2.
-- >>> index "xyz"
index :: [a] -> [(Int, a)]
index = zip [0 ..]

-- 1.3.
-- >>> divider 3
divider :: Int -> String
divider = flip replicate '='

-- Exercise 2

addThree :: (Num a) => a -> a -> a -> a
addThree x y z = x + y + z

-- 2.1.
-- >>> applyOnLast (+) [1, 2, 3] [5, 6]
-- >>> applyOnLast max [1, 2] [3, 4]
applyOnLast :: (a -> b -> c) -> [a] -> [b] -> c
applyOnLast _ [] _ = error "Empty list"
applyOnLast _ _ [] = error "Empty list"
applyOnLast f xs ys = f (last xs) (last ys)

-- 2.2.
-- >>> lastTwoPlus100 [1, 2, 3] [6, 5]
lastTwoPlus100 :: [Integer] -> [Integer] -> Integer
lastTwoPlus100 = applyOnLast (addThree 100)

-- Exercise 3

-- 3.1.
-- >>> listifyList [1, 2, 3]
listifyList :: [a] -> [[a]]
listifyList = map (: [])

listifyList' :: [a] -> [[a]]
listifyList' = map singleton

-- 3.2.
-- >>> cutoff 100 [20, 202, 34, 117]
cutoff :: Int -> [Int] -> [Int]
cutoff n = map (min n)

-- Exercise 4

-- 4.1.
-- >>> sumEvenSquares [1, 2, 3, 4]
sumEvenSquares :: [Integer] -> Integer
sumEvenSquares xs = sum $ map (^ 2) $ filter even xs

-- 4.2.
-- >>> freq 'k' "kikiriki"
freq x xs = length $ filter (== x) xs

-- 4.3.
-- >>> freqFilter 4 "kikiriki"
freqFilter :: (Eq a) => Int -> [a] -> [a]
freqFilter n xs = filter (\x -> freq x xs >= n) xs

-- Exercise 5

-- 5.1.
withinInterval :: (Ord a) => a -> a -> [a] -> [a]
withinInterval n m = filter (`inRange` (n, m))

inRange :: (Ord a) => a -> (a, a) -> Bool
x `inRange` (low, high) = low <= x && x <= high

-- 5.2.
-- >>> canonicalizePairs [(4, 1), (2, 2), (1, 5)]
canonicalizePairs :: (Ord a) => [(a, a)] -> [(a, a)]
canonicalizePairs xs = map sortPair $ filter (uncurry (/=)) xs
    where
        sortPair (x, y) = (min x y, max x y)

-- 5.3.
-- >>> applyAndCombine (+ 2) (* 3) 5
applyAndCombine :: (a -> b) -> (a -> c) -> a -> (b, c)
applyAndCombine f g x = (f x, g x)
