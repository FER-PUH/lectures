import Data.List

-- Exercise 1

-- 1.1.

-- 1.2.
-- >>> index "xyz"

-- 1.3.
-- >>> divider 3

-- Exercise 2

addThree :: (Num a) => a -> a -> a -> a
addThree x y z = x + y + z

-- 2.1.
-- >>> applyOnLast (+) [1, 2, 3] [5, 6]

-- >>> applyOnLast max [1, 2] [3, 4]

-- 2.2.
-- >>> lastTwoPlus100 [1, 2, 3] [6, 5]

-- Exercise 3

-- 3.1.
-- >>> listifyList [1, 2, 3]

-- 3.2.
-- >>> cutoff 100 [20, 202, 34, 117]

-- Exercise 4

-- 4.1.
-- >>> sumEvenSquares [1, 2, 3, 4]

-- 4.2.
-- >>> freq 'k' "kikiriki"

-- 4.3.
-- >>> freqFilter 4 "kikiriki"

-- Exercise 5

-- 5.1.

-- 5.2.
-- >>> canonicalizePairs [(4, 1), (2, 2), (1, 5)]

-- 5.3.
-- >>> applyAndCombine (+ 2) (* 3) 5
