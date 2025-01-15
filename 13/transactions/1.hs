data Transaction
  = Incoming Int
  | Outgoing Int
  deriving (Show)

-- Updates the balance without allowing negative balances (assuming the input
-- balance is positive).
updateBalance :: Transaction -> Int -> Maybe Int
updateBalance (Incoming amount) balance = Just $ balance + amount
updateBalance (Outgoing amount) balance
  | newBalance < 0 = Nothing
  | otherwise = Just newBalance
  where
    newBalance = balance - amount

-- Task 1: Implement a function that performs three transactions given as a
-- tuple one after another.
performTransactions :: (Transaction, Transaction, Transaction) -> Int -> Maybe Int
performTransactions = undefined

-- Use this to test your functions (comment out what you haven't implemented
-- yet)
main :: IO ()
main = do
  let valid = (Incoming 10, Outgoing 5, Outgoing 3)
  let invalid1 = (Incoming 10, Outgoing 15, Outgoing 3)
  let invalid2 = (Outgoing 5, Incoming 15, Incoming 5)

  putStrLn $ "valid: " ++ show valid
  putStrLn $ "invalid1: " ++ show invalid1
  putStrLn $ "invalid2: " ++ show invalid2
  putStrLn ""

  putStrLn "Using nested case:"
  print $ performTransactions valid 0
  print $ performTransactions invalid1 0
  print $ performTransactions invalid2 0
  putStrLn ""