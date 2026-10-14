import Data.Char
import Data.List

-- 1.1.
trim3 xs = drop 3 (take (length xs - 3) xs)

trim3' xs = reverse (drop 3 (reverse (drop 3 xs)))

-- 1.2.
-- >>> initials "James" "Bond"
initials s1 s2 = (head s1 : ". ") ++ (head s2 : ".")

initials' s1 s2
  | not (null s1) && not (null s2) = head s1 : ". " ++ head s2 : "."
  | otherwise = ""

-- 1.3.
concatLongest s1 s2
  | length s1 < length s2 = s1 ++ s2
  | otherwise = s2 ++ s1

-- 1.4.
safeHead l
  | null l = []
  | otherwise = [head l]

-- 1.5.
hasDuplicates l = l /= nub l

-- 2.1.
doublesFromTo a b = [x * 2 | x <- if a < b then [a .. b] else [b .. a]]

-- 2.2.
-- >>> caesarCode' 3 "aB10c"
caesarCode' n xs =
  [ chr $ ord x + n
  | x <- stringToLower xs
  , x `elem` ['a' .. 'z']
  ]

stringToLower xs = [toLower x | x <- xs]

-- 3.1.
-- >>> letterCount "I have 23 ducks in my yard."
letterCount text =
  length
    [ c
    | c <- concat [w | w <- words text, length w >= 3]
    , isLetter c
    ]

-- 3.2.
isPalindrome str = isPalindromeSimple [toLower c | c <- str, c /= ' ']

isPalindromeSimple str = reverse str == str

-- 3.3.
-- >>> flipp ["water", "is", "warm"]
flipp xss = concat (reverse [reverseIfOddLength xs | xs <- xss])

reverseIfOddLength xs
  | odd (length xs) = reverse xs
  | otherwise = xs

-- 4.1.
inCircle r x y =
  [ (x', y')
  | x' <- [-10 .. 10]
  , y' <- [-10 .. 10]
  , (x - x') ** 2 + (y - y') ** 2 <= r ** 2
  ]

inCircle' res r x y =
  [ (x', y')
  | x' <- [-10, -10 + res .. 10]
  , y' <- [-10, -10 + res .. 10]
  , (x - x') ** 2 + (y - y') ** 2 <= r ** 2
  ]

-- 4.2.
steps xs = zip xs (drop 1 xs)

-- 5.1.
-- >>> indices 'a' "alphabet"
indices y xs = [i | (i, x) <- zip [0 ..] xs, x == y]

-- 5.2.
-- >>> showLineNumbers "first line\nsecond line"
showLineNumbers s = unlines [show i ++ " " ++ l | (i, l) <- zip [0 ..] (lines s)]

-- 5.3.
-- >>> haveAlignment "water" "fire"
haveAlignment xs ys = or [x == y | (x, y) <- zip xs ys]

-- >>> common "witer" "fire"
common xs ys = [x | (x, y) <- zip xs ys, x == y]
