import Data.Char
import Data.List
import Data.Tuple

-- Exercise 1

-- 1.1.
takeThree :: [a] -> [a]
takeThree xs = take 3 xs

dropThree :: [a] -> [a]
dropThree xs = drop 3 xs

hundredTimes :: a -> [a]
hundredTimes xs = replicate 100 xs

-- 1.2.
index :: [a] -> [(Int, a)]
index xs = zip [0 ..] xs

index' xs = zip xs [0 ..]

-- 1.3.
divider :: Int -> String
divider n = replicate n '='

-- Exercise 2










-- 2.1.
applyOnLast :: (a -> b -> c) -> [a] -> [b] -> c
applyOnLast _ _ [] = error "Empty right list."
applyOnLast _ [] _ = error "Right left list."
applyOnLast f xs ys = f (last xs) (last ys)

lastTwoPlus100 :: (Num a) => [a] -> [a] -> a
lastTwoPlus100 xs ys =
  applyOnLast addThree xs ys 100
  where
    addThree x y z = x + y + z

-- 2.2.
applyManyTimes :: Int -> (a -> a) -> a -> a
applyManyTimes 0 f x = x
applyManyTimes n f x = applyManyTimes (n - 1) f (f x)

applyTwice' :: (a -> a) -> a -> a
applyTwice' = applyManyTimes 2

-- Exercise 3

-- 3.1. Partial application of cons
listifyList :: [a] -> [[a]]
listifyList = map (: []) -- or just a lambda \x -> [x]

-- 3.2.
cutoff :: Int -> [Int] -> [Int]
cutoff n = map (min n) 

-- Exercise4

-- 4.1. straightforward approach
sumEvenSquares :: [Integer] -> Integer
sumEvenSquares xs = sum $ map (^ 2) $ filter even xs -- cant eta reduce bc ($)

-- 4.1. eta reduced (we must use the composition operator for this (.))
sumEvenSquares' = sum . map (^ 2) . filter even

-- 4.2. straightforward approach
freq :: (Eq a) => a -> [a] -> Int
freq x xs = length $ filter (== x) xs

-- 4.2. eta reduced
freq' x = length . filter (== x)

-- 4.3. straightforward approach
freqFilter :: (Eq a) => Int -> [a] -> [a]
freqFilter n xs = filter (\x -> freq x xs >= n) xs

-- 4.3. eta reduced
freqFilter' n = filter ((>= n) . freq)

-- Exercise 5

-- 5.1.
withinInterval :: Int -> Int -> [Int] -> [Int]
withinInterval n m = filter (`elem` [n .. m])

-- 5.2.
canonicalizePairs :: (Ord a) => [(a, a)] -> [(a, a)]
canonicalizePairs = map sortTuple 
  where
    sortTuple (x, y)
      | x > y = (y, x)
      | otherwise = (x, y)

applyAndCombine :: (a -> b) -> (a -> c) -> a -> (b, c)
applyAndCombine f g x = (f x, g x)
