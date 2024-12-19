{-# LANGUAGE ImportQualifiedPost #-}
{-# OPTIONS_GHC -Wno-type-defaults #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module LectureExercises where

import Control.DeepSeq (deepseq)
import Control.Exception
import Control.Monad
import Data.Char
import Data.List
import Data.Map qualified as Map
import Data.Set (Set)
import Data.Set qualified as Set
import System.Directory
import System.Environment
import System.FilePath
import System.IO
import System.IO.Error
import System.Random
import Text.Read (readMaybe)

-- * EXERCISE 1 ===============================================================

-- ** 1.1.

-- Define a 'main' function that reads in two strings and prints them out
-- concatenated and reversed.
main11 :: IO ()
main11 = do
  string1 <- getLine
  string2 <- getLine
  putStrLn $ reverse $ string1 ++ string2

-- ** 1.2.

-- Write a function 'threeNumbers' that reads in three numbers and prints out
-- their sum.
-- Call this function from within a 'main' function, then compile and run the
-- program.
threeNumbers :: IO ()
threeNumbers = do
  line1 <- getLine
  line2 <- getLine
  line3 <- getLine
  -- let [n1, n2, n3] = fmap (read :: String -> Int) [line1, line2, line3]
  let n1 = (read line1 :: Int)
      n2 = (read line2 :: Int)
      n3 = (read line3 :: Int)
  print (n1 + n2 + n3)

-- * EXERCISE 2 ===============================================================

-- ** 2.1.

-- Define a function 'threeStrings' that reads in three strings and outputs them
-- to the screen as one string, while it returns its total length.
threeStrings :: IO Int
threeStrings = do
  line1 <- getLine
  line2 <- getLine
  line3 <- getLine
  let merged = line1 ++ line2 ++ line3
  putStrLn merged
  return $ length merged

-- ** 2.2.

-- Define a function 'askNumber9' that reads in a number and returns that number
-- converted into an 'Int'. Input should be repeated until the user enters a
-- number (a string containing only digits).
askNumber9 :: IO Int
askNumber9 = do
  putStrLn "Please enter a number:"
  line <- getLine
  if all isDigit line && not (null line) -- this is okay even for "000123" try it in ghci!
    then return (read line :: Int)
    else do
      putStrLn "Invalid input. Try again."
      askNumber9

-- ** 2.3.

-- Define a function 'askUser' that returns an action that prints out a message,
-- reads in a string from the input, repeats the input until the input string
-- satisfies the function 'p', and then returns the input string.
askUser :: String -> (String -> Bool) -> IO String
askUser message predicate = do
  putStrLn message
  line <- getLine
  if predicate line
    then return line
    else askUser message predicate

-- Generalize 'askUser' to handle input parsing with error handling.
-- For error handling use readMaybe
askUser' :: (Read a) => String -> (a -> Bool) -> IO a
askUser' message predicate = do
  putStrLn message
  line <- getLine
  case readMaybe line of
    Just value | predicate value -> return value
    _ -> do
      putStrLn "Invalid input. Please try again."
      askUser' message predicate

-- ** 2.4.

-- Define a function that reads in strings until the user inputs an empty
-- string, and then returns a list of strings received as input.
inputStrings :: IO [String]
inputStrings = collectInputs []
  where
    collectInputs :: [String] -> IO [String]
    collectInputs strings = do
      line <- getLine
      if line == ""
        then return $ reverse strings
        else collectInputs (line : strings)

-- * EXERCISE 3 ===============================================================

-- ** 3.1.

-- Define a function that reads in a number, then reads in that many
-- strings, and finally prints these strings in reverse order.
readAndReverse :: IO ()
readAndReverse = do
  putStrLn "Enter a number:"
  line <- getLine
  let n = read line :: Int
  putStrLn $ "Enter " ++ show n ++ " strings:"
  strings <- replicateM n getLine
  putStrLn "Strings in reverse order:"
  mapM_ putStrLn (reverse strings)

-- ** 3.2.

-- Give recursive definitions for 'sequence' and 'sequence_'.
sequence' :: [IO a] -> IO [a]
sequence' [] = return []
sequence' (action : actions) = do
  result <- action
  rest <- sequence' actions
  return (result : rest)

sequence_' :: [IO a] -> IO ()
sequence_' [] = return ()
sequence_' (action : actions) = do
  _ <- action
  sequence_' actions

-- ** 3.3.

mapM' :: (a -> IO b) -> [a] -> IO [b]
mapM' _ [] = return []
mapM' f (x : xs) = do
  result <- f x
  rest <- mapM' f xs
  return (result : rest)

mapM_' :: (a -> IO b) -> [a] -> IO ()
mapM_' _ [] = return ()
mapM_' f (x : xs) = do
  _ <- f x
  mapM_' f xs

-- ** 3.4.

-- Define a function that prints out the Pythagorean triplets whose all sides
-- are <= 100. Every triplet should be in a separate line.
pythagoreanTriplets :: IO ()
pythagoreanTriplets = do
  let triplets = [(a, b, c) | a <- [1 .. 100], b <- [a .. 100], c <- [b .. 100], a ^ 2 + b ^ 2 == c ^ 2]
  mapM_ print triplets

-- * EXERCISE 4 ===============================================================

-- ** 4.1.

-- Define a function that removes from standard input every second line and
-- prints the result to standard output.
filterOdd :: IO ()
filterOdd = do
  input <- lines <$> getContents
  let filtered = [line | (line, index) <- zip input [1 ..], odd index]
  mapM_ putStrLn filtered

-- ** 4.2.

-- Define a function that prefixes each line from standard input with a line
-- number (number + space).
numberLines :: IO ()
numberLines = do
  input <- lines <$> getContents
  let numbered = zipWith (\n line -> show n ++ " " ++ line) [1 ..] input
  mapM_ putStrLn numbered

-- ** 4.3.

-- Define a function to remove from standard input all words from a given set of
-- words.
filterWords :: Set String -> IO ()
filterWords wordSet = do
  input <- getContents
  let filtered = unwords [word | word <- words input, not (word `Set.member` wordSet)]
  putStrLn filtered

-- * EXERCISE 5 ===============================================================

-- ** 5.1.

-- Define a function that counts the number of characters, words, and lines
-- in a file.
wc :: FilePath -> IO (Int, Int, Int)
wc path = do
  content <- readFile path
  content `deepseq` return () -- Force eval
  let lineCount = length (lines content)
      wordCount = length (words content)
      charCount = length content
  return (charCount, wordCount, lineCount)

-- NB: This function may misbehave if we dont use deepseq.
-- Learn more about it here: https://tinyurl.com/y9xobdyd.
-- Even 'seq' won't suffice; you'll need 'deepseq' from Control.DeepSeq.

-- ** 5.2.

-- Define a function that copies given lines from the first file into the second.
copyLines :: [Int] -> FilePath -> FilePath -> IO ()
copyLines lineNumbers srcPath destPath = do
  content <- readFile srcPath
  let linesToCopy = map ((lines content !!) . (\n -> n - 1)) lineNumbers
  writeFile destPath (unlines linesToCopy)

-- * EXERCISE 6 ===============================================================

-- ** 6.1.

-- Define a function to compute the number of distinct words in the given file.

wordTypes :: FilePath -> IO Int
wordTypes path = do
  content <- readFile path
  let wordsInFile = words content
      distinctWords = Set.fromList wordsInFile
  return (length distinctWords)

-- ** 6.2.

-- Define a function that takes two file names, compares their corresponding
-- lines, and outputs all differing lines. Lines should be prefixed with "<"
-- for the first file and ">" for the second file.
diff :: FilePath -> FilePath -> IO ()
diff file1 file2 = do
  content1 <- lines <$> readFile file1
  content2 <- lines <$> readFile file2
  let maxLines = max (length content1) (length content2)
  -- TODO implement this with zip filter and mapM
  let compareLines i -- we use let here so we have content1 and content2 in scope
        | i >= length content1 && i < length content2 = putStrLn ("> " ++ content2 !! i)
        | i >= length content2 && i < length content1 = putStrLn ("< " ++ content1 !! i)
        | content1 !! i /= content2 !! i = do
            putStrLn ("< " ++ content1 !! i)
            putStrLn ("> " ++ content2 !! i)
        | otherwise = return ()
  mapM_ compareLines [0 .. maxLines - 1]

-- ** 6.3.

-- Define a function that removes trailing spaces from all lines in the given
-- file. The function should modify the original file.
removeSpaces :: FilePath -> IO ()
removeSpaces = undefined

-- * EXERCISE 7 ===============================================================

-- ** 7.1.

-- Define a function that prints the first 'n' lines from a file. The file name
-- and number of lines are provided via the command line. Default to 10 lines
-- if the number is missing. Read from standard input if the file name is
-- missing. Exit with failure if the file does not exist.
fileHead :: IO ()
fileHead = undefined

-- ** 7.2.

-- Define a function that sorts lines from multiple files and prints them to
-- standard output. File names are provided via the command line. Print an
-- error message if any file does not exist.
sortFiles :: IO ()
sortFiles = undefined

-- * EXERCISE 8 ===============================================================

-- ** 8.1.

-- Define your own implementation of the 'randoms' function.
randoms' :: (RandomGen g, Random a) => g -> [a]
randoms' = undefined

-- ** 8.2.

-- Define a function that generates a list of random integer coordinates within
-- a specified interval.
-- Example: randomPositions 0 10 0 10 => [(2,1), (4,3), (7,7), ...]
randomPositions :: Int -> Int -> Int -> Int -> IO [(Int, Int)]
randomPositions = undefined
