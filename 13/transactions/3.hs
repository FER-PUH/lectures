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
performTransactions (t1, t2, t3) balance = case updateBalance t1 balance of
  Nothing -> Nothing
  Just balance1 -> case updateBalance t2 balance1 of
    Nothing -> Nothing
    Just balance2 -> updateBalance t3 balance2

-- Chaining several "functions that can fail" in a sequence is a common pattern
-- in programming.
--
-- Transactions are one example, another example is this workflow:
--   1. Read a file (fails if the file doesn't exist).
--   2. Parse the file (fails if the file is not in the correct format).
--   3. Perform some operation on the parsed data (fails if the parsed data is invalid).
--   4. Write the result to a file (fails if the file doesn't have write permissions).
--
-- Unfortunately, the code abvove is very verbose and repetitive. We can't
-- easily compose "functions that can fail" becuase the result of one such
-- function can't be passed directly into the next function. It first needs to
-- be unwrapped from a `Maybe`.
--
-- Let's see if we can generalize this pattern and avoid the nesting. To do it,
-- we'll first need a function that "upgrades" a regular "function that can
-- fail" into a function that expects its inputs wrapped in a `Maybe`.  Let's
-- call it `chain`.
--
-- This is the desired behaviour of `chain`:
--   functionThatCanFail :: a -> Maybe b
--   (chain functionThatCanFail) :: Maybe a -> Maybe b
--
-- Task 2: Figure out what the type of chain must be to satisfy the above claim and
-- implement it.
chain :: (a -> Maybe b) -> Maybe a -> Maybe b
chain f Nothing = Nothing
chain f (Just x) = f x

-- Task 3: Implement performTransactions using the chain function.
performTransactions' :: (Transaction, Transaction, Transaction) -> Int -> Maybe Int
performTransactions' (t1, t2, t3) =
  chain (updateBalance t3) . chain (updateBalance t2) . updateBalance t1

-- Chaining operations is often nicer when done from left to right.
--
-- Task 4: Let's define an infix version of `chain`
-- It should act exactly the same as `chain`, but with the arguments flipped.
-- We want it to bind to the left and as loosely as possible (i.e. it should
-- have the lowest precedence) to avoid having to use parentheses.
infixl 1 |>

(|>) :: Maybe a -> (a -> Maybe b) -> Maybe b
(|>) = flip chain

-- Task 5: Implement performTransactions using the `|>` operator.
performTransactions'' :: (Transaction, Transaction, Transaction) -> Int -> Maybe Int
performTransactions'' (t1, t2, t3) balance =
  updateBalance t1 balance
    |> updateBalance t2
    |> updateBalance t3

-- Let's say we want a function that doubles the balance.
doubleBalance :: Int -> Int
doubleBalance = (* 2)

-- We now have a function that doesn't fail (assuming the input balance is
-- positive, doubling it cannot be negative). How can we compose it with the
-- function that can fail?

-- To make `doubleBalance` fit into our pipeline, we need a way to "wrap" its
-- result (an Int) into a Maybe.
--
-- Task 6: Implement a function that does this.
wrap :: a -> Maybe a
wrap = undefined

-- Task 7: Implement a function that doubles the value (if it exists) after each
-- transaction using `|>` and `wrap`.
performTransactionsAndDouble ::
  (Transaction, Transaction, Transaction) -> Int -> Maybe Int
performTransactionsAndDouble = undefined

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

  putStrLn "Using chain:"
  print $ performTransactions' valid 0
  print $ performTransactions' invalid1 0
  print $ performTransactions' invalid2 0
  putStrLn ""

  putStrLn "Using the `|>` operator:"
  print $ performTransactions'' valid 0
  print $ performTransactions'' invalid1 0
  print $ performTransactions'' invalid2 0
  putStrLn ""

  putStrLn "Doubling after each transaction with wrap:"
  print $ performTransactionsAndDouble valid 0
  print $ performTransactionsAndDouble invalid1 0
  print $ performTransactionsAndDouble invalid2 0
  putStrLn ""
