module Main where

import Data.List (find, intercalate)

main :: IO ()
main = do
  putStrLn "Welcome to Tic Tac Toe!"
  gameLoop initialGame

data Move = Move !Int !Int -- TODO: Use stricter types: Row, Col
  deriving (Eq, Show)

newtype Game = Game [Move]

data GameResult = Win !Symbol | Draw

data Symbol = X | O
  deriving (Show)

type ErrorMsg = String

initialGame :: Game
initialGame = Game []

gameLoop :: Game -> IO ()
gameLoop game = do
  printGame game
  game' <- askForAndPerformMove game
  case checkGameResult game' of
    Just (Win symbol) -> putStrLn $ show symbol ++ " won!"
    Just Draw -> putStrLn "It's a draw!"
    Nothing -> gameLoop game'

printGame :: Game -> IO ()
printGame game = putStrLn $ intercalate "\n" $ showRow <$> [0 .. 2]
  where
    showRow :: Int -> String
    showRow rIdx = concatMap (showCell rIdx) [0 .. 2]

    showCell :: Int -> Int -> String
    showCell rIdx cIdx = maybe "-" show (getCell game (rIdx, cIdx))

getCell :: Game -> (Int, Int) -> Maybe Symbol
getCell (Game moves) (rIdx, cIdx) = fst <$> find ((== Move rIdx cIdx) . snd) (zip (cycle [X, O]) moves)

askForAndPerformMove :: Game -> IO Game
askForAndPerformMove game = do
  moveOrError <- askForMove
  case moveOrError >>= performMove game of
    Left errMsg -> putStrLn errMsg >> askForAndPerformMove game
    Right game' -> return game'

-- If user gives invalid move, we will ask again till we get a valid move.
askForMove :: IO (Either ErrorMsg Move)
askForMove = do
  putStrLn "Type your move (e.g. 0 1):"
  parseMove <$> getLine
  where
    parseMove :: String -> Either ErrorMsg Move
    parseMove [rChar, ' ', cChar] = do
      r <- parseCoord rChar
      c <- parseCoord cChar
      return $ Move r c
    parseMove _ = Left "Wrong input. Input should be row and column separated with space (e.g. 0 1)."

    parseCoord :: Char -> Either ErrorMsg Int
    parseCoord cChar | cChar >= '0' && cChar <= '2' = Right $ read [cChar]
    parseCoord cChar = Left $ "Coordinate " <> show cChar <> " must be a digit between 0 and 2 (included)."

performMove :: Game -> Move -> Either ErrorMsg Game
performMove (Game moves) move
  | move `elem` moves = Left $ "Move " <> show move <> " is illegal, that move has already been done."
  | otherwise = Right $ Game $ moves ++ [move]

checkGameResult :: Game -> Maybe GameResult
checkGameResult game = Nothing -- TODO: implement
