import Data.Char (isUpper, toUpper)
import Data.List (elemIndices, findIndices, intercalate, sortBy)
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

-- Exercises 2

-- 2.1
applyPairs1 :: [(a -> b, a)] -> [b]
applyPairs1 pairs = map (\(f, v) -> f v) pairs

applyPairs2 :: [(a -> b, a)] -> [b]
applyPairs2 = map (\(f, v) -> f v)

applyPairs3 :: [(a -> b, a)] -> [b]
applyPairs3 = map (uncurry ($))

-- 2.2.
maxDiff :: (Ord a, Num a) => [a] -> a
maxDiff = maximum . getDiffs

getDiffs :: (Num a) => [a] -> [a]
getDiffs xs
  | length xs < 2 = error "List must have at least two elements"
  | otherwise = map (uncurry (-)) . zip xs $ tail xs

-- Exercises 3
isTitleCased :: String -> Bool
isTitleCased = all (isUpper . head) . words

getFilename :: String -> String
getFilename = reverse . takeWhile (/= '/') . reverse
