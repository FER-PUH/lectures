{-# OPTIONS_GHC -Wno-unused-imports #-}
module LectureExercises where

import Control.Exception
import Control.Monad
import Data.Char
import Data.List
import qualified Data.Map as M
import System.Directory
import System.Environment
import System.FilePath
import System.IO
import System.IO.Error
import System.Random
import Data.Set

-- * EXERCISE 1 ===============================================================

-- ** 1.1.

-- Define a 'main' function that reads in two strings and prints them out
-- concatenated and reversed.
main11 :: IO ()
main11 = undefined

-- ** 1.2.

-- Write a function 'threeNumbers' that reads in three numbers and prints out
-- their sum.
-- Call this function from within a 'main' function, then compile and run the
-- program.
threeNumbers :: IO ()
threeNumbers = undefined

-- * EXERCISE 2 ===============================================================

-- ** 2.1.

-- Define a function 'threeStrings' that reads in three strings and outputs them
-- to the screen as one string, while it returns its total length.
threeStrings :: IO Int
threeStrings = undefined

-- ** 2.2.

-- Define a function 'askNumber9' that reads in a number and returns that number
-- converted into an 'Int'. Input should be repeated until the user enters a
-- number (a string containing only digits).
askNumber9 :: IO Int
askNumber9 = undefined

-- Define a 'main' function that calls 'askNumber9' and outputs the number to
-- the screen. Build and run the program.
main :: IO ()
main = undefined

-- ** 2.3.

-- Define a function 'askUser' that returns an action that prints out a message,
-- reads in a string from the input, repeats the input until the input string
-- satisfies the function 'p', and then returns the input string.
askUser :: String -> (String -> Bool) -> IO String
askUser = undefined

-- Generalize 'askUser' to handle input parsing with error handling.
askUser' :: (Read a) => String -> (String -> Bool) -> IO a
askUser' = undefined

-- Define a 'main' function that prints out the read-in value to the screen.
-- Build and run the program.
main23 :: IO ()
main23 = undefined

-- ** 2.4.

-- Define a function that reads in strings until the user inputs an empty
-- string, and then returns a list of strings received as input.
inputStrings :: IO [String]
inputStrings = undefined

-- * EXERCISE 3 ===============================================================

-- ** 3.1.

-- Define a function that reads in a number, then reads in that many
-- strings, and finally prints these strings in reverse order.
readAndReverse :: IO ()
readAndReverse = undefined

-- ** 3.2.

-- Give recursive definitions for 'sequence' and 'sequence_'.
sequence :: [IO a] -> IO [a]
sequence = undefined

sequence_ :: [IO a] -> IO ()
sequence_ = undefined

-- ** 3.3.

-- Give recursive definitions for 'mapM' and 'mapM_'.
mapM :: (a -> IO b) -> [a] -> IO [b]
mapM = undefined

mapM_ :: (a -> IO b) -> [a] -> IO ()
mapM_ = undefined

-- ** 3.4.

-- Define a function that prints out the Pythagorean triplets whose all sides
-- are <= 100. Every triplet should be in a separate line.
pythagoreanTriplets :: IO ()
pythagoreanTriplets = undefined

-- * EXERCISE 4 ===============================================================

-- ** 4.1.

-- Define a function that removes from standard input every second line and
-- prints the result to standard output.
filterOdd :: IO ()
filterOdd = undefined

-- ** 4.2.

-- Define a function that prefixes each line from standard input with a line
-- number (number + space).
numberLines :: IO ()
numberLines = undefined

-- ** 4.3.

-- Define a function to remove from standard input all words from a given set of
-- words.
filterWords :: Set String -> IO ()
filterWords = undefined

-- * EXERCISE 5 ===============================================================

-- ** 5.1.

-- Define a function that counts the number of characters, words, and lines
-- in a file.
wc :: FilePath -> IO (Int, Int, Int)
wc = undefined

-- NB: This function may misbehave. If so, learn more about it here:
-- https://tinyurl.com/y9xobdyd.
-- Even 'seq' won't suffice; you'll need 'deepseq' from Control.DeepSeq.

-- ** 5.2.

-- Define a function that copies given lines from the first file into the second.
copyLines :: [Int] -> FilePath -> FilePath -> IO ()
copyLines = undefined

-- * EXERCISE 6 ===============================================================

-- ** 6.1.

-- Define a function to compute the number of distinct words in the given file.
wordTypes :: FilePath -> IO Int
wordTypes = undefined

-- ** 6.2.

-- Define a function that takes two file names, compares their corresponding
-- lines, and outputs all differing lines. Lines should be prefixed with "<"
-- for the first file and ">" for the second file.
diff :: FilePath -> FilePath -> IO ()
diff = undefined

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
