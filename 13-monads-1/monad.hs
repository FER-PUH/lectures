import Control.Monad.Writer

-- ========================================================================
-- ============================== Transactions ============================
-- ========================================================================

data Transaction
  = Incoming Int
  | Outgoing Int
  deriving (Show)

updateBalance :: Transaction -> Int -> Maybe Int
updateBalance (Incoming amount) balance = Just $ balance + amount
updateBalance (Outgoing amount) balance
  | newBalance < 0 = Nothing
  | otherwise = Just newBalance
  where
    newBalance = balance - amount

performTransactionsAndDouble' ::
  (Transaction, Transaction, Transaction) -> Int -> Maybe Int
performTransactionsAndDouble' (t1, t2, t3) balance =
  updateBalance t1 balance
    >>= return . doubleBalance
    >>= updateBalance t2
    >>= return . doubleBalance
    >>= updateBalance t3
    >>= return . doubleBalance
  where
    doubleBalance = (* 2)

-- ========================================================================
-- ============================== Knight ==================================
-- ========================================================================

type Position = (Int, Int)

moveKnight :: Position -> [Position]
moveKnight (row, col) = filter onBoard $ map makeAMove moves
  where
    makeAMove (dRow, dCol) = (row + dRow, col + dCol)
    onBoard (row, col) = row `elem` [1 .. 8] && col `elem` [1 .. 8]
    moves = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]

moveAsAPawn :: Position -> Position
moveAsAPawn (row, col) = (row + 1, col)

canReachIn3WhileMovingUp :: Position -> Position -> Bool
canReachIn3WhileMovingUp start end =
  elem end $
    moveKnight start
      >>= return . moveAsAPawn
      >>= moveKnight
      >>= return . moveAsAPawn
      >>= moveKnight
      >>= return . moveAsAPawn

-- ========================================================================
-- ============================== Logging =================================
-- ========================================================================

doubleL :: Double -> Writer [String] Double
doubleL x =
  let result = x * 2
   in writer (result, [show x ++ " -> double -> " ++ show result])

squareL :: Double -> Writer [String] Double
squareL x =
  let result = x * x
   in writer (result, [show x ++ " -> square -> " ++ show result])

halveL :: Double -> Writer [String] Double
halveL x =
  let result = x / 2
   in writer (result, [show x ++ " -> halve -> " ++ show result])

doubleSquareHalveAndIncrementL' :: Double -> Writer [String] Double
doubleSquareHalveAndIncrementL' x =
  doubleL x
    >>= squareL
    >>= halveL
    >>= return . (+ 1)

-- ========================================================================
-- ============================== Main ====================================
-- ========================================================================

main :: IO ()
main = do
  putStrLn "Transactions"
  print $ performTransactionsAndDouble' (Incoming 10, Outgoing 5, Incoming 5) 0
  print $ performTransactionsAndDouble' (Incoming 10, Outgoing 30, Incoming 5) 0
  putStrLn ""

  putStrLn "Knight"
  print $ canReachIn3WhileMovingUp (6, 2) (6, 1)
  putStrLn ""

  putStrLn "Logging"
  let (result, log) = runWriter $ doubleSquareHalveAndIncrementL' 3
  putStrLn $ "Result: " ++ show result
  putStrLn $ "Log: " ++ show log
