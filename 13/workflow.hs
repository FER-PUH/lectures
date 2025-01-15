class Workflow w where
  infixl 1 |>
  (|>) :: a -- TODO: properly define signature
  wrap :: a -- TODO: properly define signature

-- ========================================================================
-- ============================== Transactions ============================
-- ========================================================================

-- TODO: Make this work using by correctly implementing a Workflow instance

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
    |> doubleBalance
    |> updateBalance t2
    |> doubleBalance
    |> updateBalance t3
    |> doubleBalance
  where
    doubleBalance = wrap . (* 2)

-- ========================================================================
-- ============================== Knight ==================================
-- ========================================================================

-- TODO: Make this work using by correctly implementing a Workflow instance

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
      |> wrap . moveAsAPawn
      |> moveKnight
      |> wrap . moveAsAPawn
      |> moveKnight
      |> wrap . moveAsAPawn

-- ========================================================================
-- ============================== Logging =================================
-- ========================================================================

data Logged a = Logged (a, [String])

-- TODO: Make this work using by correctly implementing a Workflow instance

doubleL :: Double -> Logged Double
doubleL x =
  let result = x * 2
   in Logged (result, [show x ++ " -> double -> " ++ show result])

squareL :: Double -> Logged Double
squareL x =
  let result = x * x
   in Logged (result, [show x ++ " -> square -> " ++ show result])

halveL :: Double -> Logged Double
halveL x =
  let result = x / 2
   in Logged (result, [show x ++ " -> halve -> " ++ show result])

doubleSquareHalveAndIncrementL' :: Double -> Logged Double
doubleSquareHalveAndIncrementL' x =
  doubleL x |> squareL |> halveL |> wrap . (+ 1)

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
  let Logged (result, log) = doubleSquareHalveAndIncrementL' 3
  putStrLn $ "Result: " ++ show result
  putStrLn $ "Log: " ++ show log
