--------------
-- EXERCISE 1
--------------

-- 1.1.
-- >>> product' [1, 2, 0]
-- 0
product' :: (Num a) => [a] -> a
product' [] = 1
product' (x : xs) = x * product' xs

-- 1.2.
-- >>>  headsOf [[1, 2, 3], [4, 5], [6]]
-- [1,4,6]
headsOf :: [[a]] -> [a]
headsOf [] = []
headsOf ([] : xss) = headsOf xss
headsOf ((x : _) : xss) = x : headsOf xss

headsOf' :: [[a]] -> [a]
headsOf' xss = [x | (x:_) <- xss]














--------------
-- EXERCISE 2
--------------

-- 2.1.
-- >>> modMult 3 4 [1, 2, 3]
-- [3,2,1]
modMult :: (Integral a) => a -> a -> [a] -> [a]
modMult _ _ [] = []
modMult n m (x : xs) = x * n `mod` m : modMult n m xs

-- 2.2.
-- >>> addPredecessor [3, 2, 1]
addPredecessor :: (Num a) => [a] -> [a]
addPredecessor [] = []
addPredecessor (x : xs) = x : go x xs
  where
    go _ [] = []
    go prev (y : ys) = (y + prev) : go y ys

addPredecessor' :: (Num a) => [a] -> [a]
addPredecessor' xs = go 0 xs
  where
    go _ [] = []
    go prev (y : ys) = (y + prev) : go y ys

--------------
-- EXERCISE 3
--------------

-- 3.1.
-- >>> equalTriplets [(1, 2, 3), (2, 2, 2), (4, 5, 6)]
-- [(2,2,2)]
equalTriplets :: (Eq a) => [(a, a, a)] -> [(a, a, a)]
equalTriplets [] = []
equalTriplets list@(triple@(x1, x2, x3) : xs)
  | x1 == x2 && x2 == x3 = triple : equalTriplets xs
  | otherwise = equalTriplets xs

-- 3.2.
-- >>> replicate' 3 7
-- [7,7,7]
--
-- >>> replicate' 0 7
-- []
--
-- >>> replicate' (-2) 7
-- []
replicate' :: Int -> a -> [a]
replicate' 0 _ = []
replicate' n x
  | n <= 0 = []
  | otherwise = x : replicate' (n-1) x

--------------
-- EXERCISE 4
--------------

-- 4.1.
-- >>> drop' 2 [1, 2, 3]
-- [3]
--
-- >>> drop' 4 [1, 2, 3]
-- []
--
-- >>> drop (-2) [1, 2, 3]
-- [1,2,3]
drop' :: Int -> [a] -> [a]
drop' _ [] = []
drop' n xs
  | n <= 0 = xs
  | otherwise = drop' (n-1) (tail xs)

-- >>> drop'' (-2) [1, 2, 3]
drop'' :: Int -> [a] -> [a]
drop'' n xs
  | n < 0 = reverse $ drop' (-n) (reverse xs)
  | otherwise = drop' n xs

-- 4.2.
-- >>> takeFromTo 1 4 [1..6]
--
-- >>> takeFromTo 2 2 [1..6]
takeFromTo :: Int -> Int -> [a] -> [a]
takeFromTo from to xs = go 0 xs
  where 
    go _ [] = []
    go i (y:ys)
      | i < from = go (i+1) ys
      | i <= to = y : go (i+1) ys
      | otherwise = []

--------------
-- EXERCISE 5
--------------

-- 5.1.
-- >>> eachThird "zagreb"
--
-- >>> eachThird "haskell"
--
-- >>> eachThird "yo"
eachThird :: [a] -> [a]
eachThird (_:_:z:xs) = z : eachThird xs
eachThird _ = []

-- 5.2.
-- >>> crossZip [1, 2, 3, 4, 5] [4, 5, 6, 7, 8]
crossZip :: [a] -> [b] -> [(a, b)]
crossZip (x1:x2:xs) (y1:y2:ys) = (x1, y2) : (x2, y1) : crossZip xs ys
crossZip _ _ = []
