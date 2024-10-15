-- Exercise 1

-- 1.1
product' :: (Num a) => [a] -> a
product' [] = 1
product' (x : xs) = x * product' xs

-- 1.2.
-- >>> headsOf [[1,2,3],[4,5],[6]]
-- [1,4,6]
headsOf :: [[a]] -> [a]
headsOf [] = []
headsOf ((x : _) : xss) = x : headsOf xss

headOf' :: [[a]] -> [a]
headOf' xss = [head xs | xs <- xss]

-- Exercise 2

-- 2.1.
-- >>> modMult 3 4 [1,2,3]
-- [3,2,1]
modMult :: (Integral a) => a -> a -> [a] -> [a]
modMult _ _ [] = []
modMult n m (x : xs) = x * n `mod` m : modMult n m xs

-- 2.2.
-- >>> addPredecessor [3,2,1]
-- [3,5,3]
addPredecessor :: (Num a) => [a] -> [a]
addPredecessor xs = go 0 xs
  where
    go prev [] = []
    go prev (x : xs) = x + prev : go x xs

-- Exercise 3

-- 3.1.
-- >>> equalTriplets [(1,2,3),(2,2,2),(4,5,6)]
-- [(2,2,2)]
equalTriplets :: (Eq a) => [(a, a, a)] -> [(a, a, a)]
equalTriplets [] = []
equalTriplets (t@(x, y, z) : ts)
    | x == y && y == z = t : equalTriplets ts
    | otherwise = equalTriplets ts

-- 3.2.
-- >>> replicate' 3 7
-- [7,7,7]
-- >>> replicate' 0 7
-- []
-- >>> replicate' (-2) 7
-- []
replicate' :: Int -> a -> [a]
replicate' n x
    | n <= 0 = []
    | otherwise = x : replicate' (n - 1) x

-- Exercise 4

-- 4.1.
-- >>> drop' 2 [1,2,3]
-- [3]
-- >>> drop' 4 [1,2,3]
-- []
-- >>> drop' (-2) [1,2,3]
-- [1,2,3]
drop' :: Int -> [a] -> [a]
drop' n xs
    | n <= 0 = xs
    | otherwise = drop (n - 1) (tail xs)

-- >>> drop' 2 [1,2,3]
-- [3]
-- >>> drop' 4 [1,2,3]
-- []
-- >>> drop' (-2) [1,2,3]
-- [1,2,3]
drop'' :: Int -> [a] -> [a]
drop'' n xs
    | n < 0 = reverse $ drop (-n) (reverse xs)
    | otherwise = drop' n xs

-- 4.2.
-- >>> takeFromTo 1 4 [1..6]
-- [2,3,4,5]
-- >>> takeFromTo 2 2 [1..6]
-- [3]
takeFromTo :: Int -> Int -> [a] -> [a]
takeFromTo n1 n2 xs = go 0 xs
  where
    go i (y : ys)
        | i < n1 = go (i + 1) ys
        | i <= n2 = y : go (i + 1) ys
        | otherwise = []

-- Exercise 5

-- 5.1.
-- >>> eachThird "zagreb"
-- "gb"
-- >>> eachThird "haskell"
-- "sl"
-- >>> eachThird "yo"
-- ""
eachThird :: [a] -> [a]
eachThird (_ : _ : x : xs) = x : eachThird xs
eachThird _ = []

-- 5.2.
-- >>> crossZip [1,2,3,4,5] [4,5,6,7,8]
-- [(1,5),(2,4),(3,7),(4,6)]
crossZip :: [a] -> [b] -> [(a, b)]
crossZip (x1 : x2 : xs) (y1 : y2 : ys) = (x1, y2) : (x2, y1) : crossZip xs ys
crossZip _ _ = []
