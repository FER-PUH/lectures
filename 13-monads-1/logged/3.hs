import Data.List (intercalate)

double :: Double -> Double
double = (* 2)

square :: Double -> Double
square = (^ 2)

halve :: Double -> Double
halve = (/ 2)

-- Task 1: Implement a function that doubles, squares, and then halves a number
-- (in that order).
doubleSquareAndHalve :: Double -> Double
doubleSquareAndHalve = halve . square . double

-- What if we wanted to log the performed operations? The only possible way to
-- do this in a pure language is to return the log alongside the result.
-- Let's create a new type for this purpose...

data Logged a = Logged (a, [String])

-- ... Along with a couple of logged functions.

doubleL :: Double -> Logged Double
doubleL x =
  let result = double x
   in Logged (result, [show x ++ " -> double -> " ++ show result])

squareL :: Double -> Logged Double
squareL x =
  let result = square x
   in Logged (result, [show x ++ " -> square -> " ++ show result])

halveL :: Double -> Logged Double
halveL x =
  let result = halve x
   in Logged (result, [show x ++ " -> halve -> " ++ show result])

-- Task 2: Implement a LOGGED function that doubles, squares, and halves a
-- number (in that order). Its log should be a concatenation of the logs of
-- individual functions.
doubleSquareAndHalveL :: Double -> Logged Double
doubleSquareAndHalveL x = Logged (result3, log1 ++ log2 ++ log3)
  where
    Logged (result1, log1) = doubleL x
    Logged (result2, log2) = squareL result1
    Logged (result3, log3) = halveL result2

-- Composing regular functions is short and elegant.
-- On the other hand, composing logged functions is hard work!
--
-- If we had to do implement this kind of plumbing all the way through our code
-- it would be a pain. What we need is to define a higher order function to
-- perform this plumbing for us. Again, the problem is that the output from one
-- logged function can't simply be plugged into the input of another one.
--
-- You can probably see where this is going. We want a higher order function for
-- making logged functions easily composable:
--
--   funD :: Double -> Logged Double
--   (chain funD) :: Logged Double -> Logged Double
--
-- Task 3: Assuming this holds, how does the signature of `chain` have to look
-- like? Implement it (no need to worry any kind of polymorphism yet)!
chain :: (Double -> Logged Double) -> Logged Double -> Logged Double
chain funD (Logged (input, log)) =
  let Logged (result, newLog) = funD input in Logged (result, log ++ newLog)

-- Task 4: Implement doubleSquareAndHalveL using `chain`.
doubleSquareAndHalveL' :: Double -> Logged Double
doubleSquareAndHalveL' = chain halveL . chain squareL . doubleL

-- Chain is sometimes more convenient to use as an operator.
--
-- Task 5: Implement the operator `|>`.
-- It should act exactly the same as chain, but with the arguments flipped.
infixl 1 |>

(|>) :: Logged Double -> (Double -> Logged Double) -> Logged Double
loggedDouble |> fD = chain fD loggedDouble

-- Task 6: Implement doubleSquareAndHalveL using the `|>` operator.
doubleSquareAndHalveL'' :: Double -> Logged Double
doubleSquareAndHalveL'' x = doubleL x |> squareL |> halveL

-- What if we wanted to compose regular functions with logged functions?
-- Let's say this one:
increment :: Double -> Double
increment = (+ 1)

-- We'll need a way to turn a `Double` into a `Logged Double`.
--
-- Task 7: Implement a function that does this in a way that makes the most
-- sense:
wrap :: Double -> Logged Double
wrap = undefined

-- Task 8: Implement a function that does what doubleSquareAndHalveL does, but
-- also increments the result in the end. Use `|>` and `wrap`, don't define new
-- logged functions.
doubleSquareHalveAndIncrementL :: Double -> Logged Double
doubleSquareHalveAndIncrementL = undefined

-- You can use this to test your functions (comment out what you haven't
-- implemented yet).
main :: IO ()
main = do
  putStrLn $ "doubleSquareAndHalve 5 == " ++ show (doubleSquareAndHalve 5)
  putStrLn ""

  let Logged (result, log) = doubleSquareAndHalveL 5
  putStrLn $ "doubleSquareAndHalveL 5 = " ++ show result
  putStrLn $ "Log: " ++ show log
  putStrLn ""

  let Logged (result, log) = doubleSquareAndHalveL' 5
  putStrLn $ "doubleSquareAndHalveL' 5 = " ++ show result
  putStrLn $ "Log: " ++ show log
  putStrLn ""

  let Logged (result, log) = doubleSquareAndHalveL'' 5
  putStrLn $ "doubleSquareAndHalveL'' 5 = " ++ show result
  putStrLn $ "Log: " ++ show log
  putStrLn ""

  let Logged (result, log) = doubleSquareHalveAndIncrementL 5
  putStrLn $ "doubleSquareHalveAndIncrementL 5 = " ++ show result
  putStrLn $ "Log: " ++ show log
  putStrLn ""
