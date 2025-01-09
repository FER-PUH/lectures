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
import System.Exit (die)
import System.FilePath
import System.IO
import System.IO.Error
import System.Random
import Text.Read (readMaybe)



-- * EXERCISE 3 ===============================================================

-- ** 3.1.

-- Define a function that reads in a number, then reads in that many
-- strings, and finally prints these strings in reverse order.
readAndReverse :: IO ()
readAndReverse = undefined


-- ** 3.2.

-- Give recursive definitions for 'sequence' and 'sequence_'.
sequence' :: [IO a] -> IO [a]
sequence' = undefined 

sequence_' :: [IO a] -> IO ()
sequence_' = undefined 

-- ** 3.3.
mapM' :: (a -> IO b) -> [a] -> IO [b]
mapM' = undefined

mapM_' :: (a -> IO b) -> [a] -> IO ()
mapM_' = undefined

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

-- NB: This function may misbehave if we dont use deepseq.
-- Learn more about it here: https://tinyurl.com/y9xobdyd.
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
