module Main where

import Data.Function ((&))
import Data.List (elemIndex)
import Text.Read (readMaybe)

main :: IO ()
main = do
  gameLoop initialGame
  where
    initialGame = Game []

gameLoop :: Game -> IO ()
gameLoop game = do
  printGame game
  game' <- evaluateUserMove game
  case checkForResult game' of
    Nothing -> gameLoop game'
    Just Draw -> putStrLn "Draw"
    Just XWon -> putStrLn "X Won!"
    Just OWon -> putStrLn "O Won!"

-- | TODO: Implement!
checkForResult :: Game -> Maybe Result
checkForResult _game = Nothing

data Result = XWon | OWon | Draw

evaluateUserMove :: Game -> IO Game
evaluateUserMove game = do
  move <- getUserMove
  applyMove game move
    & either printErrorAndRetry return
  where
    printErrorAndRetry errMsg = do
      putStrLn $ "Illegal move: " ++ errMsg
      evaluateUserMove game

printGame :: Game -> IO ()
printGame (Game moves) = do
  mapM_ printRow [1 .. 3]
  where
    printRow :: Int -> IO ()
    printRow rIdx = do
      mapM_ (printCell rIdx) [1 .. 3]
      putStrLn ""

    printCell :: Int -> Int -> IO ()
    printCell rIdx cIdx =
      let cellIdx = (rIdx - 1) * 3 + cIdx
       in putStr $ case Move cellIdx `elemIndex` moves of
            Nothing -> show cellIdx
            Just moveIdx -> if even moveIdx then show X else show O

getUserMove :: IO Move
getUserMove = do
  line <- getLine
  case readMaybe line of
    Nothing -> printParseErrorAndAskAgain
    Just cellIdx
      | cellIdx >= 1 && cellIdx <= 9 -> return $ Move cellIdx
      | otherwise -> printInvalidRangeAndAskAgain
  where
    printParseErrorAndAskAgain = do
      putStrLn "Couldn't parse move! Has to be a number."
      getUserMove
    printInvalidRangeAndAskAgain = do
      putStrLn "Invalid cell index! Has to be a number between 1 and 9 (inclusive)."
      getUserMove

applyMove :: Game -> Move -> Either ErrorMsg Game
applyMove (Game moves) move =
  if move `elem` moves
    then Left "Illegal move: already performed."
    else Right $ Game $ moves ++ [move]

type ErrorMsg = String

newtype Move = Move Int
  deriving (Eq)

newtype Game = Game [Move]

data Symbol = X | O
  deriving (Show)
