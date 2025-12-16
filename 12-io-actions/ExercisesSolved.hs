{-# OPTIONS_GHC -Wno-type-defaults #-}
{-# OPTIONS_GHC -Wno-unused-imports #-}

module ExercisesSolved where

import Control.DeepSeq (deepseq)
import Control.Exception
import Control.Monad
import Data.Char
import Data.List
import qualified Data.Map as Map
import Data.Set (Set)
import qualified Data.Set as Set
import System.Directory
import System.Environment
import System.Exit (die)
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
  line1 <- getLine
  line2 <- getLine
  putStrLn $ reverse $ line1 ++ line2

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
  let n1 = (read line1 :: Int)
      n2 = (read line2 :: Int)
      n3 = (read line3 :: Int)
  -- let [n1, n2, n3] = fmap (read :: String -> Int) [line1, line2, line3]
  print (n1 + n2 + n3)


-- * EXERCISE 2 ===============================================================

-- ** 2.1.
-- Define a function 'threeStrings' that reads in three strings and outputs 
-- them to the screen as one string, while it returns its total length.
threeStrings :: IO Int
threeStrings = do
  line1 <- getLine
  line2 <- getLine
  line3 <- getLine
  let mergedLines = line1 ++ line2 ++ line3
  putStrLn mergedLines
  return $ length mergedLines

-- ** 2.2.
-- Define a function 'askNumber9' that reads in a number and returns that number
-- converted into an 'Int'. Input should be repeated until the user enters a
-- number (a string containing only digits).
askNumber9 :: IO Int
askNumber9 = do
  putStrLn "Enter your lucky number"
  line <- getLine
  if all isDigit line && not (null line)
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
-- For error handling use `readMaybe`.
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
inputStrings = do
  go []
  where
    go receivedLines = do
      line <- getLine
      if line == ""
        then return $ reverse receivedLines
        else go (line : receivedLines)

-- * EXERCISE 3 ===============================================================

-- ** 3.1.
-- Define a function that reads in a number, then reads in that many
-- strings, and finally prints these strings in reverse order.
readAndReverse :: IO ()
readAndReverse = do
  putStrLn "How many lines do I read?"
  line <- getLine
  let numberOfLines = read line :: Int
  lines <- mapM getLinePolitely [1 .. numberOfLines]
  -- lines <- forM [1 .. numberOfLines] getLinePolitely
  -- lines <- replicateM n getLine
  putStrLn "Now in reverse order:"
  mapM_ putStrLn (reverse lines)
  where
    getLinePolitely index = do
      putStrLn $ "Please enter line " ++ show index ++ ":" 
      getLine
  

-- ** 3.2.
-- Give recursive definitions for 'sequence' and 'sequence_'.
sequence' :: [IO a] -> IO [a]
sequence' [] = return []
sequence' (action : actions) = do
  currentResult <- action
  restOfResults <- sequence' actions
  return (currentResult : restOfResults)

sequence_' :: [IO a] -> IO ()
sequence_' [] = return ()
sequence_' (action : actions) = do
  _ <- action
  sequence_' actions

-- ** 3.3.
-- Give recursive definitions for 'mapM' and 'mapM_'.
mapM' :: (a -> IO b) -> [a] -> IO [b]
mapM' _ [] = return []
mapM' f (x : xs) = do
  currentResult <- f x
  restOfResults <- mapM' f xs
  return (currentResult : restOfResults)

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
  inputLines <- lines <$> getContents
  -- input <- fmap lines getContents
  let filteredInputLines = [line | (line, index) <- zip inputLines [1 ..], odd index]
  mapM_ putStrLn filteredInputLines


-- ** 4.2.
-- Define a function that prefixes each line from standard input with a line
-- number (number + space).
numberLines :: IO ()
numberLines = do
  inputLines <- lines <$> getContents
  let numberedInputLines = zipWith (\n line -> show n ++ " " ++ line) [1 ..] inputLines
  mapM_ putStrLn numberedInputLines

-- ** 4.3.
-- Define a function to remove from standard input all words from a given set of
-- words.
filterWords :: Set String -> IO ()
filterWords filteredWords = do
  input <- getContents
  let filteredInput = unwords [word | word <- words input, not (word `Set.member` filteredWords)]
  putStrLn filteredInput

-- * EXERCISE 5 ===============================================================

-- ** 5.1.

-- Define a function that counts the number of characters, words, and lines
-- in a file.
wc :: FilePath -> IO (Int, Int, Int)
wc filePath = do
  content <- readFile filePath
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
copyLines lineNumbersToCopy srcFilePath destFilePath = do
  sourceFileLines <- lines <$> readFile srcFilePath
  let linesToCopy = map ((sourceFileLines !!) . (\n -> n - 1)) lineNumbersToCopy
  writeFile destFilePath (unlines linesToCopy)

-- * EXERCISE 6 ===============================================================

-- ** 6.1.
-- Define a function to compute the number of distinct words in the given file.
wordTypes :: FilePath -> IO Int
wordTypes filePath = do
  wordsInFile <- words <$> readFile filePath
  let distinctWords = Set.fromList wordsInFile
  return (length distinctWords)

-- ** 6.2.
-- Define a function that takes two file names, compares their corresponding
-- lines, and outputs all differing lines. Lines should be prefixed with "<"
-- for the first file and ">" for the second file.
diff :: FilePath -> FilePath -> IO ()
diff filePath1 filePath2 = do
  fileLines1 <- lines <$> readFile filePath1
  fileLines2 <- lines <$> readFile filePath2
  -- could have used filter here
  let tuples = [t | t@(_, line1, line2) <- zip3 [1 ..] fileLines1 fileLines2, line1 /= line2]
  forM_ tuples $ \(index, line1, line2) -> do
    putStrLn $ "line " ++ show index ++ ":"
    putStrLn $ "  < " ++ line1
    putStrLn $ "  > " ++ line2

-- ** 6.3.
-- Define a function that removes trailing spaces from all lines in the given
-- file. The function should modify the original file.
removeSpaces :: FilePath -> IO ()
removeSpaces filePath = do
  fileLines <- lines <$> readFile filePath
  fileLines `deepseq` return ()
  let result = unlines . map (reverse . dropWhile isSpace . reverse) $ fileLines
  writeFile filePath result

-- * EXERCISE 7 ===============================================================

-- ** 7.1.
-- Define a function that prints the first 'n' lines from a file. The file name
-- and number of lines are provided via the command line. Default to 10 lines
-- if the number is missing. Read from standard input if the file name is
-- missing. Exit with failure if the file does not exist.
--
-- Test this by putting 'main = fileHead' in 'Exercises.hs' and running the command:
-- cabal run main -- --file testFile1.txt --lines 3
fileHead :: IO ()
fileHead = do
  args <- getArgs
  case parseArgs args of
    Left err -> die err
    Right (maybeFilePath, numLines) -> do
      content <- readContent maybeFilePath
      putStr . unlines . take numLines . lines $ content
  where
    parseArgs :: [String] -> Either String (Maybe String, Int)
    parseArgs [] = Right (Nothing, 10)
    parseArgs ["--file", filePath] = Right (Just filePath, 10)
    parseArgs ["--lines", numOfLinesString] = validateArgs Nothing numOfLinesString
    parseArgs ["--file", filePath, "--lines", numOfLinesString] = validateArgs (Just filePath) numOfLinesString
    parseArgs ["--lines", numOfLinesString, "--file", filePath] = validateArgs (Just filePath) numOfLinesString
    parseArgs _ = Left usageHelp

    validateArgs :: Maybe String -> String -> Either String (Maybe String, Int)
    validateArgs filePath numOfLinesString = case readMaybe numOfLinesString of
      Just numberOfLines -> Right (filePath, numberOfLines)
      _ -> Left "Error: Number of lines must be a positive integer."

    readContent :: Maybe String -> IO String
    readContent Nothing = getContents
    readContent (Just file) = catch (readFile file) handleReadFileError

    handleReadFileError :: IOException -> IO String
    handleReadFileError _ = die "Error: File not found or inaccessible."

    usageHelp :: String
    usageHelp = "Usage: fileHead [--file <filePath>] [--lines <numberOfLines>]"

-- ** 7.2.
-- Define a function that sorts lines from multiple files and prints them to
-- standard output. File names are provided via the command line. Print an
-- error message if any file does not exist.
--
-- Test this by putting 'main = sortFiles' in 'Main.hs' and running the command:
-- cabal run main -- testFile1.txt testFile2.txt testFile3.txt
sortFiles :: IO ()
sortFiles = do
  args <- getArgs
  if null args
    then die "Error: No files provided."
    else do
      contents <- mapM safeReadFile args
      putStr . unlines . sort . concatMap lines $ contents
  where
    safeReadFile :: FilePath -> IO String
    safeReadFile filePath = catch (readFile filePath) handleReadFileError

    -- Here we can choose to exit the program completely or continue, we chose death.
    handleReadFileError :: IOException -> IO String
    handleReadFileError _ = die "Error: One or more files could not be read."

-- * EXERCISE 8 ===============================================================

-- ** 8.1.
-- Define your own implementation of the 'randoms' function.
randoms' :: (RandomGen g, Random a) => g -> [a]
randoms' randomValueGenerator = 
  let (randomValue, randomValueGenerator') = random randomValueGenerator
   in randomValue : randoms' randomValueGenerator'

-- ** 8.2.
-- Define a function that generates a list of random integer coordinates within
-- a specified interval.
-- Example: randomPositions 0 10 0 10 => [(2,1), (4,3), (7,7), ...]
randomPositions :: (Int, Int) -> (Int, Int) -> IO [(Int, Int)]
randomPositions xRange yRange = do
  sequence $ repeat $ do
    x <- getStdRandom (randomR xRange)
    y <- getStdRandom (randomR yRange)
    return (x, y)
