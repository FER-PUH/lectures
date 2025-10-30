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
sumEven = sum . map snd . filter (even . fst) . zip [0 ..]

-- 1.2
applyAll1 :: a -> [a -> b] -> [b]
applyAll1 value functions = map (\f -> f value) functions

applyAll2 :: a -> [a -> b] -> [b]
applyAll2 value = map (\f -> f value)

applyAll3 :: a -> [a -> b] -> [b]
applyAll3 value = map apply
  where
    apply f = f value

-- This is the best solution, a textbook use case for the application operator
-- ($).
applyAll4 :: a -> [a -> b] -> [b]
applyAll4 value = map ($ value)

applyAll5 :: a -> [a -> b] -> [b]
applyAll5 value functions = map ($ value) functions

-- Exercises 2

-- 2.1

joinNames :: [(String, String)] -> [String]
joinNames = map (uncurry (++))

-- Exercises 3
isTitleCased :: String -> Bool
isTitleCased = all (isUpper . head) . words

{-
 -
  getFilename :: String -> String
  getFilename "/etc/init/cron.conf" => "cron.conf"
  getFilename "~/Documents/diary.txt" => "diary.txt"
 -}
getFilename :: String -> String
getFilename = reverse . takeWhile (/= '/') . reverse
