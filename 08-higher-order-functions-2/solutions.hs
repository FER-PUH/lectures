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

-- Extra exercises

filterWords :: [String] -> String -> String
filterWords ws = unwords . filter (not . (`elem` ws)) . words

studentsPassed :: [(String, Int)] -> [String]
studentsPassed students = map fst $ filter didPass students
  where
    didPass = (>= halfOfMaxScore) . snd
    halfOfMaxScore = maxScore `div` 2
    maxScore = maximum $ map snd students

applyPairs1 :: [(a -> b, a)] -> [b]
applyPairs1 pairs = map (\(f, v) -> f v) pairs

applyPairs2 :: [(a -> b, a)] -> [b]
applyPairs2 = map (\(f, v) -> f v)

applyPairs3 :: [(a -> b, a)] -> [b]
applyPairs3 = map (uncurry ($))

clamp :: (Ord a, Num a) => a -> a -> [a] -> [a]
clamp lower upper = map (min upper) . map (max lower)

(|>) :: a -> (a -> b) -> b
value |> function = function value

-- Alternative definition:
-- (|>) = flip ($)

simple :: Char
simple = "Marko" |> head

wordCount :: Int
wordCount = "I am piping stuff like a pro!" |> words |> length

oddSquareSum :: Int
oddSquareSum = [1 .. 5] |> map (^ 2) |> filter odd |> sum

initials3 :: String -> (String -> Bool) -> String -> String
initials3 delimiter pred =
  intercalate "." . map (map toUpper . take 1) . filter pred . words

sortPairs :: (Ord b) => [(a, b)] -> [(a, b)]
sortPairs = sortBy (comparing snd)

-- Complexity?
maxElemIndices :: (Ord a) => [a] -> [Int]
maxElemIndices list = findIndices (== maximum list) list

maxElemIndices' :: (Ord a) => [a] -> [Int]
maxElemIndices' list = elemIndices (maximum list) list

sumEven' :: (Num a) => [a] -> a
sumEven' = foldl' sumIfEvenIndex 0 . zip [0 ..]
  where
    sumIfEvenIndex acc (idx, current) = if even idx then acc + current else acc
