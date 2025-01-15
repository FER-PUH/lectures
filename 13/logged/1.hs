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
doubleSquareAndHalve = undefined

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
doubleSquareAndHalveL = undefined

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
