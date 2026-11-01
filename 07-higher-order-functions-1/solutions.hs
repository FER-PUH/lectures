import Data.List

-- Exercise 1

takeThree :: [a] -> [a]
takeThree = take 3

dropThree :: [a] -> [a]
dropThree = drop 3

hundredTimes :: a -> [a]
hundredTimes = replicate 100


index :: [a] -> [(Int, a)]
index = zip [0..]

index' :: [a] -> [(a, Int)]
index' = (`zip` [0..])

divider :: Int -> String
divider = (`replicate` '=')


-- Exercise 2

applyOnLast :: (a -> b -> c) -> [a] -> [b] -> c
applyOnLast _ []  _ = error "Empty list"
applyOnLast _  _ [] = error "Empty list"
applyOnLast f xs ys = f (last xs) (last ys)

-- predefined helper
addThree x y z = x + y + z

lastTwoPlus100 :: [Integer] -> [Integer] -> Integer
lastTwoPlus100 = applyOnLast (addThree 100) 


applyManyTimes :: Int -> (a -> a) -> a -> a
applyManyTimes n _ x | n <= 0 = x
applyManyTimes n f x = f (applyManyTimes (n - 1) f x)

applyManyTimes' n _ x | n <= 0 = x
applyManyTimes' n f x = applyManyTimes (n - 1) f (f x)

finishSentence :: String -> String
finishSentence = (++ ".")

applyTwice :: (a -> a) -> a -> a
applyTwice = applyManyTimes 2



-- Exercise 3

listifylist :: [a] -> [[a]]
listifylist = map (:[])


cutoff :: Ord a => a -> [a] -> [a]
cutoff m = map (min m)



-- Exercise 4

sumEvenSquares :: [Integer] -> Integer
sumEvenSquares xs = sum $ map (^2) $ filter even xs


freq :: Eq a => a -> [a] -> Int
freq x xs = length $ filter (== x) xs


freqFilter :: Eq a => Int -> [a] -> [a]
freqFilter n xs = filter (\x -> freq x xs >= n) xs



-- Exercise 5

withinInterval :: Ord a => a -> a -> [a] -> [a]
withinInterval n m = filter (`within` (n, m))

x `within` (n, m) = n <= x && x <= m


canonicalizePairs :: Ord a => [(a,a)] -> [(a,a)]
canonicalizePairs xs = map (\(x, y) -> (min x y, max x y)) $ filter (\(x, y) -> x /= y) xs


applyAndCombine :: (a -> b) -> (a -> c) -> a -> (b, c)
applyAndCombine f g x = (f x, g x)

