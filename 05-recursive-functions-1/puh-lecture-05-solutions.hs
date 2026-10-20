--------------
-- EXERCISE 1
--------------

-- 1.1.
-- >>> product' [1, 2, 0]
product' :: (Num a) => [a] -> a
product' = undefined

-- 1.2.
-- >>>  headsOf [[1, 2, 3], [4, 5], [6]]
headsOf :: [[a]] -> [a]
headsOf = undefined

--------------
-- EXERCISE 2
--------------

-- 2.1.
-- >>> modMult 3 4 [1, 2, 3]
modMult :: (Integral a) => a -> a -> [a] -> [a]
modMult = undefined

-- 2.2.
-- >>> addPredecessor [3, 2, 1]
addPredecessor :: (Num a) => [a] -> [a]
addPredecessor = undefined

--------------
-- EXERCISE 3
--------------

-- 3.1.
-- >>> equalTriplets [(1, 2, 3), (2, 2, 2), (4, 5, 6)]
equalTriplets :: (Eq a) => [(a, a, a)] -> [(a, a, a)]
equalTriplets = undefined

-- 3.2.
-- >>> replicate' 3 7
--
-- >>> replicate' 0 7
--
-- >>> replicate' (-2) 7
replicate' :: Int -> a -> [a]
replicate' = undefined

--------------
-- EXERCISE 4
--------------

-- 4.1.
-- >>> drop' 2 [1, 2, 3]
--
-- >>> drop' 4 [1, 2, 3]
--
-- >>> drop (-2) [1, 2, 3]
drop' :: Int -> [a] -> [a]
drop' = undefined

-- >>> drop'' (-2) [1, 2, 3]
drop'' :: Int -> [a] -> [a]
drop'' = undefined

-- 4.2.
-- >>> takeFromTo 1 4 [1..6]
--
-- >>> takeFromTo 2 2 [1..6]
takeFromTo :: Int -> Int -> [a] -> [a]
takeFromTo = undefined

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
eachThird = undefined

-- 5.2.
-- >>> crossZip [1, 2, 3, 4, 5] [4, 5, 6, 7, 8]
crossZip :: [a] -> [b] -> [(a, b)]
crossZip = undefined
