import Data.Char (isUpper, toUpper)
import Data.Foldable (foldl')
import Data.List
  ( elemIndices,
    findIndices,
    intercalate,
    sortBy,
  )
import Data.Ord (comparing)

-- Exercises 1

-- 1.1
sumEven :: (Num a) => [a] -> a
sumEven = undefined

-- 1.2
applyAll :: a -> [a -> b] -> [b]
applyAll = undefined

-- Exercises 2

-- 2.1
joinNames :: [(String, String)] -> [String]
joinNames = undefined

-- 2.2.
maxDiff :: (Ord a, Num a) => [a] -> a
maxDiff = undefined

-- Exercises 3

-- 3.1
isTitleCased :: String -> Bool
isTitleCased = undefined

-- 3.2
getFilename :: String -> String
getFilename = undefined

-- Exercises 4

-- 4.1
myElem :: (Eq a) => a -> [a] -> Bool
myElem = undefined

-- 4.2
myReverse :: [a] -> [a]
myReverse = undefined

-- 4.3
sumEvenL :: (Num a) => [a] -> a
sumEvenL = undefined
